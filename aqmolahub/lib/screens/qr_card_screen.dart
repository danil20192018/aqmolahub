import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'qr_ar_view_screen.dart';

class QrCardScreen extends StatefulWidget {
  const QrCardScreen({super.key});

  @override
  State<QrCardScreen> createState() => _QrCardScreenState();
}

class _QrCardScreenState extends State<QrCardScreen> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  String _theme = 'blue';
  Map? _card;
  bool _load = false;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    setState(() => _load = true);
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('user_id');
    
    try {
      final res = await http.get(Uri.parse('${Cfg.url}qr_card.php?act=my&user_id=$uid'));
      final d = jsonDecode(res.body);
      
      if (d['res'] == true) {
        setState(() {
          _card = d['data'];
          _nameCtrl.text = _card!['name'] ?? '';
          _roleCtrl.text = _card!['role'] ?? '';
          _bioCtrl.text = _card!['bio'] ?? '';
          _skillsCtrl.text = _card!['skills'] ?? '';
          _contactCtrl.text = _card!['contact'] ?? '';
          _theme = _card!['theme'] ?? 'blue';
        });
      }
    } catch (e) {}
    setState(() => _load = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('user_id');
    final name = prefs.getString('name');
    final avatar = prefs.getString('avatar');
    
    setState(() => _load = true);
    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}qr_card.php?act=create'),
        body: jsonEncode({
          'user_id': uid,
          'name': _nameCtrl.text.isEmpty ? name : _nameCtrl.text,
          'role': _roleCtrl.text,
          'bio': _bioCtrl.text,
          'skills': _skillsCtrl.text,
          'contact': _contactCtrl.text,
          'avatar': avatar,
          'theme': _theme,
        }),
      );
      
      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        setState(() => _card = d['data']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Визитка сохранена!')),
        );
      }
    } catch (e) {}
    setState(() => _load = false);
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
          'МОЯ QR ВИЗИТКА',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_card != null)
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QrArViewScreen(qrCode: _card!['qr_code']),
                  ),
                );
              },
            ),
        ],
      ),
      body: _load
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_card != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: _card!['qr_code'],
                            size: 200,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Сканов: ${_card!['scans']}',
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  _field('Имя', _nameCtrl),
                  _field('Роль/Должность', _roleCtrl),
                  _field('О себе', _bioCtrl, lines: 3),
                  _field('Навыки', _skillsCtrl, hint: 'Python, Flutter, AI'),
                  _field('Контакт', _contactCtrl, hint: 'email или telegram'),
                  
                  const SizedBox(height: 16),
                  Text(
                    'ТЕМА',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['blue', 'purple', 'green', 'red', 'orange'].map((t) {
                      return ChoiceChip(
                        label: Text(t.toUpperCase()),
                        selected: _theme == t,
                        onSelected: (v) => setState(() => _theme = t),
                        selectedColor: _getColor(t),
                        labelStyle: GoogleFonts.montserrat(
                          color: _theme == t ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _save,
                      child: Text(
                        'СОХРАНИТЬ',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int lines = 1, String hint = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            maxLines: lines,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String t) {
    switch (t) {
      case 'blue': return Colors.blue;
      case 'purple': return Colors.purple;
      case 'green': return Colors.green;
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      default: return Colors.blue;
    }
  }
}
