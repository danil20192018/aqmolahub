import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../config.dart';
import '../web_circle_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameCtrl = TextEditingController();
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  String? avatarUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameCtrl.text = prefs.getString('name') ?? '';
      avatarUrl = prefs.getString('avatar');
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => isLoading = true);
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      
      try {
        final bytes = await image.readAsBytes();
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${Cfg.url}upload.php?type=avatar'),
        );
        request.fields['user_id'] = userId.toString();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
        
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        
        if (data['success'] == true) {
          setState(() => avatarUrl = '${Cfg.url}${data['url']}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка загрузки')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;
    
    try {
      final response = await http.post(
        Uri.parse('${Cfg.url}profile.php?act=update'),
        body: jsonEncode({
          'user_id': userId,
          'name': nameCtrl.text,
          'avatar': avatarUrl,
        }),
      );
      
      if (response.statusCode == 200) {
        await prefs.setString('name', nameCtrl.text);
        if (avatarUrl != null) {
          await prefs.setString('avatar', avatarUrl!);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль обновлен')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка сохранения')),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _changePassword() async {
    if (oldPassCtrl.text.isEmpty || newPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;
    
    try {
      final response = await http.post(
        Uri.parse('${Cfg.url}profile.php?act=changepass'),
        body: jsonEncode({
          'user_id': userId,
          'old_pass': oldPassCtrl.text,
          'new_pass': newPassCtrl.text,
        }),
      );
      
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароль изменен')),
        );
        oldPassCtrl.clear();
        newPassCtrl.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Неверный старый пароль')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка')),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text('Редактировать профиль', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: WebCircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                imageUrl: avatarUrl,
                child: avatarUrl == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text('Нажмите для изменения', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 32),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Имя',
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
                onPressed: isLoading ? null : _saveProfile,
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('СОХРАНИТЬ'),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text('Изменить пароль', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: oldPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Старый пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Новый пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isLoading ? null : _changePassword,
                child: const Text('ИЗМЕНИТЬ ПАРОЛЬ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
