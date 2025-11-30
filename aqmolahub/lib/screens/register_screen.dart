import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../widgets/animated_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _n = TextEditingController();
  final _e = TextEditingController();
  final _p = TextEditingController();
  String _r = 'Стартап';
  bool _l = false;

  Future<void> _doReg() async {
    setState(() => _l = true);
    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}auth.php?act=reg'),
        body: jsonEncode({'name': _n.text, 'email': _e.text, 'pass': _p.text, 'role': _r}),
      );
      
      if (res.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Аккаунт создан')));
      }
    } catch (e) {
    }
    setState(() => _l = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'РЕГИСТРАЦИЯ',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 48),
            _buildTextField(controller: _n, label: 'ИМЯ'),
            const SizedBox(height: 24),
            _buildTextField(controller: _e, label: 'EMAIL'),
            const SizedBox(height: 24),
            _buildTextField(controller: _p, label: 'ПАРОЛЬ', isObscure: true),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'РОЛЬ',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField(
                  value: _r,
                  items: ['Стартап', 'Специалист', 'Команда', 'Мероприятие']
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600))))
                      .toList(),
                  onChanged: (v) => setState(() => _r = v.toString()),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 48),
            _l
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _doReg,
                      child: Text(
                        'СОЗДАТЬ',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
