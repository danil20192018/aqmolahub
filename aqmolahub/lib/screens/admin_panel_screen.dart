import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../config.dart';
import '../web_image.dart';
import '../web_circle_avatar.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController tabCtrl;
  List usersList = [];
  bool isLoading = false;
  
  final titleCtrl = TextEditingController();
  final descrCtrl = TextEditingController();
  String? newsImageUrl;

  @override
  void initState() {
    super.initState();
    tabCtrl = TabController(length: 2, vsync: this);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('${Cfg.url}admin.php?act=users'));
      if (response.statusCode == 200) {
        setState(() => usersList = jsonDecode(response.body));
      }
    } catch (e) {}
    setState(() => isLoading = false);
  }

  Future<void> _pickNewsImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => isLoading = true);
      
      try {
        print('Uploading image: ${image.path}');
        final bytes = await image.readAsBytes();
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${Cfg.url}upload.php?type=news'),
        );
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'news_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
        
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        print('Upload response: $responseData');
        final data = jsonDecode(responseData);
        
        if (data['success'] == true) {
          setState(() => newsImageUrl = '${Cfg.url}${data['url']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Изображение загружено: ${data['url']}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: ${data['error']}')),
          );
        }
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _createNews() async {
    if (titleCtrl.text.isEmpty || descrCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${Cfg.url}admin.php?act=createnews'),
        body: jsonEncode({
          'title': titleCtrl.text,
          'descr': descrCtrl.text,
          'image': newsImageUrl,
        }),
      );
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Новость создана')),
        );
        titleCtrl.clear();
        descrCtrl.clear();
        setState(() => newsImageUrl = null);
      }
    } catch (e) {}
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Админ панель', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: tabCtrl,
          labelColor: Colors.black,
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Пользователи'),
            Tab(text: 'Создать новость'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabCtrl,
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: usersList.length,
                  itemBuilder: (context, index) {
                    final user = usersList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: WebCircleAvatar(
                          imageUrl: user['avatar'],
                          child: user['avatar'] == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(user['name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                        subtitle: Text('${user['email']}\nРоль: ${user['role']}', style: GoogleFonts.montserrat(fontSize: 12)),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (newsImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: WebImage(newsImageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickNewsImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Выбрать изображение'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Заголовок',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descrCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: isLoading ? null : _createNews,
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('СОЗДАТЬ НОВОСТЬ'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
