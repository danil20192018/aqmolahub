import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../web_image.dart';
import '../web_circle_avatar.dart';

class NewsDetailScreen extends StatefulWidget {
  final Map news;
  const NewsDetailScreen({super.key, required this.news});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  List commentsList = [];
  bool isLiked = false;
  int likesCount = 0;
  final commentCtrl = TextEditingController();
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    likesCount = int.parse(widget.news['likes_count'].toString());
    _loadUser();
    _fetchComments();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('user_id');
  }

  Future<void> _fetchComments() async {
    try {
      final response = await http.get(Uri.parse('${Cfg.url}news.php?act=comments&id=${widget.news['id']}'));
      print('Comments response: ${response.body}');
      if (response.statusCode == 200) {
        final allComments = jsonDecode(response.body) as List;
        allComments.sort((a, b) {
          if (a['user_id'] == currentUserId) return -1;
          if (b['user_id'] == currentUserId) return 1;
          return 0;
        });
        setState(() => commentsList = allComments);
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  Future<void> _addComment() async {
    if (commentCtrl.text.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('name') ?? 'User';
    final userId = prefs.getInt('user_id') ?? 0;
    
    try {
      await http.post(
        Uri.parse('${Cfg.url}news.php?act=comment'),
        body: jsonEncode({
          'news_id': widget.news['id'],
          'user_id': userId,
          'user_name': userName,
          'txt': commentCtrl.text
        }),
      );
      commentCtrl.clear();
      _fetchComments();
    } catch (e) {}
  }

  Future<void> _editComment(int commentId, String currentText) async {
    final editCtrl = TextEditingController(text: currentText);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Редактировать комментарий', style: GoogleFonts.montserrat()),
        content: TextField(
          controller: editCtrl,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, editCtrl.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('${Cfg.url}news.php?act=editcomment'),
          body: jsonEncode({
            'comment_id': commentId,
            'user_id': currentUserId,
            'txt': result,
          }),
        );
        _fetchComments();
      } catch (e) {}
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Удалить комментарий?', style: GoogleFonts.montserrat()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await http.post(
          Uri.parse('${Cfg.url}news.php?act=deletecomment'),
          body: jsonEncode({
            'comment_id': commentId,
            'user_id': currentUserId,
          }),
        );
        _fetchComments();
      } catch (e) {}
    }
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;
    try {
      await http.post(
        Uri.parse('${Cfg.url}news.php?act=like'),
        body: jsonEncode({'news_id': widget.news['id'], 'user_id': userId}),
      );
      setState(() {
        isLiked = !isLiked;
        likesCount += isLiked ? 1 : -1;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.news['image'] != null && widget.news['image'].toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: WebImage(
                        widget.news['image'],
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (widget.news['image'] != null && widget.news['image'].toString().isNotEmpty)
                    const SizedBox(height: 16),
                  Text(widget.news['title'], style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(widget.news['descr'], style: GoogleFonts.montserrat(fontSize: 16)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
                        onPressed: _toggleLike,
                      ),
                      Text('$likesCount', style: GoogleFonts.montserrat()),
                    ],
                  ),
                  const Divider(),
                  Text('Комментарии', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...commentsList.map((comment) {
                    final isOwn = comment['user_id'] == currentUserId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isOwn ? Colors.blue.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WebCircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade300,
                            imageUrl: comment['user_avatar'],
                            child: comment['user_avatar'] == null
                                ? const Icon(Icons.person, size: 20, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment['user_name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(comment['txt'], style: GoogleFonts.montserrat()),
                              ],
                            ),
                          ),
                          if (isOwn)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editComment(comment['id'], comment['txt']);
                                } else if (value == 'delete') {
                                  _deleteComment(comment['id']);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                                const PopupMenuItem(value: 'delete', child: Text('Удалить')),
                              ],
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(hintText: 'Добавить комментарий', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
