import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../config.dart';
import '../web_circle_avatar.dart';
import '../widgets/animated_background.dart';

class NetworkingScreen extends StatefulWidget {
  const NetworkingScreen({super.key});

  @override
  State<NetworkingScreen> createState() => _NetworkingScreenState();
}

class _NetworkingScreenState extends State<NetworkingScreen> {
  List cards = [];
  bool isLoading = true;
  int currentIndex = 0;
  int? currentUserId;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchCards();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('user_id');
      userRole = prefs.getString('role');
    });
  }

  Future<void> _fetchCards() async {
    try {
      final response = await http.get(Uri.parse('${Cfg.url}networking.php?act=list'));
      if (response.statusCode == 200) {
        setState(() {
          cards = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _nextCard() {
    if (currentIndex < cards.length - 1) {
      setState(() => currentIndex++);
    } else {
      setState(() => currentIndex = 0); 
    }
  }

  String? uploadedImageUrl;
  bool isUploading = false;

  void _showCreateCardSheet() {
    final roleCtrl = TextEditingController();
    final descrCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    uploadedImageUrl = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickImage() async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              setModalState(() => isUploading = true);
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
                  filename: 'card_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                ));
                
                final response = await request.send();
                final responseData = await response.stream.bytesToString();
                final data = jsonDecode(responseData);
                
                if (data['success'] == true) {
                  setModalState(() => uploadedImageUrl = '${Cfg.url}${data['url']}');
                }
              } catch (e) {
                
              }
              setModalState(() => isUploading = false);
            }
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Создать карточку', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: pickImage,
                    child: FutureBuilder(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final avatar = snapshot.data!.getString('avatar');
                        final displayImage = uploadedImageUrl ?? avatar;
                        
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: displayImage != null ? NetworkImage(displayImage) : null,
                              child: displayImage == null ? const Icon(Icons.person, color: Colors.grey, size: 40) : null,
                            ),
                            if (isUploading)
                              const CircularProgressIndicator(color: Colors.black),
                            if (!isUploading)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Нажми чтобы изменить фото', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 24),
                  TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'Кого ищете? (напр. Разработчик)', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: descrCtrl, decoration: const InputDecoration(labelText: 'Описание задачи / проекта', border: OutlineInputBorder()), maxLines: 3),
                  const SizedBox(height: 12),
                  TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Контакты (Telegram, телефон)', border: OutlineInputBorder())),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      onPressed: () async {
                        if (roleCtrl.text.isEmpty || descrCtrl.text.isEmpty) return;
                        
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getInt('user_id');
                        final userName = prefs.getString('name') ?? 'User';
                        final userAvatar = uploadedImageUrl ?? prefs.getString('avatar');

                        try {
                          await http.post(
                            Uri.parse('${Cfg.url}networking.php?act=create'),
                            body: jsonEncode({
                              'user_id': userId,
                              'user_name': userName,
                              'user_avatar': userAvatar,
                              'role_needed': roleCtrl.text,
                              'description': descrCtrl.text,
                              'contact_info': contactCtrl.text,
                            }),
                          );
                          Navigator.pop(ctx);
                          _fetchCards();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Карточка создана!')));
                        } catch (e) {}
                      },
                      child: const Text('ОПУБЛИКОВАТЬ'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'NETWORKING',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _showCreateCardSheet,
          ),
        ],
      ),
      body: AnimatedBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : cards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Пока нет карточек',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                          onPressed: _showCreateCardSheet,
                          child: const Text('СОЗДАТЬ ПЕРВУЮ'),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 500,
                          width: 340,
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      color: Colors.grey.shade200,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: cards[currentIndex]['user_avatar'] == null
                                        ? const Center(child: Icon(Icons.person, size: 64, color: Colors.grey))
                                        : Image.network(
                                            cards[currentIndex]['user_avatar'],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey));
                                            },
                                          ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                cards[currentIndex]['user_name'],
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (currentUserId == int.tryParse(cards[currentIndex]['user_id'].toString()) || userRole == 'Админ')
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () async {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) => AlertDialog(
                                                      title: const Text('Удалить карточку?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(ctx, false),
                                                          child: const Text('ОТМЕНА'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(ctx, true),
                                                          child: const Text('УДАЛИТЬ', style: TextStyle(color: Colors.red)),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirm == true) {
                                                    try {
                                                      await http.post(
                                                        Uri.parse('${Cfg.url}networking.php?act=delete'),
                                                        body: jsonEncode({'id': cards[currentIndex]['id']}),
                                                      );
                                                      _fetchCards();
                                                      setState(() {
                                                        if (currentIndex >= cards.length - 1) currentIndex = 0;
                                                      });
                                                    } catch (e) {}
                                                  }
                                                },
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'ИЩЕТ: ${cards[currentIndex]['role_needed']}'.toUpperCase(),
                                            style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Text(
                                              cards[currentIndex]['description'],
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton(
                              heroTag: 'pass',
                              backgroundColor: Colors.white,
                              onPressed: _nextCard,
                              child: const Icon(Icons.close, color: Colors.red, size: 30),
                            ),
                            const SizedBox(width: 32),
                            FloatingActionButton(
                              heroTag: 'connect',
                              backgroundColor: Colors.black,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Контакты'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Свяжитесь с пользователем:', style: GoogleFonts.montserrat()),
                                        const SizedBox(height: 10),
                                        SelectableText(
                                          cards[currentIndex]['contact_info'],
                                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Icon(Icons.favorite, color: Colors.white, size: 30),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
