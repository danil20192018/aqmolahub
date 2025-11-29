import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../web_image.dart';
import 'news_detail_screen.dart';
import 'notifications_screen.dart';
import '../widgets/animated_background.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List newsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final response = await http.get(Uri.parse('${Cfg.url}news.php?act=list'));
      if (response.statusCode == 200) {
        setState(() {
          newsList = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ЛЕНТА',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 24,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  final item = newsList[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 500 + (index * 100)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => NewsDetailScreen(news: item))),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item['image'] != null && item['image'].toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(10.5)),
                                child: WebImage(
                                  item['image'],
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'].toString().toUpperCase(),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item['descr'],
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.favorite_border, size: 18, color: Colors.black),
                                      const SizedBox(width: 6),
                                      Text('${item['likes_count']}',
                                          style: GoogleFonts.montserrat(
                                              fontSize: 13, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 24),
                                      const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.black),
                                      const SizedBox(width: 6),
                                      Text('${item['comments_count']}',
                                          style: GoogleFonts.montserrat(
                                              fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
