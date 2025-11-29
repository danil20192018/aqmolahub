import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../config.dart';
import '../widgets/animated_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _e = TextEditingController();
  final _p = TextEditingController();
  bool _l = false;

  Future<void> _doLogin() async {
    setState(() => _l = true);
    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}auth.php?act=auth'),
        body: jsonEncode({'email': _e.text, 'pass': _p.text}),
      );
      
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        if (d['res'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', d['t']);
          await prefs.setString('email', _e.text);
          await prefs.setString('name', d['name'] ?? 'User');
          await prefs.setString('role', d['r'] ?? '');
          await prefs.setInt('user_id', d['user_id'] ?? 0);
          if (d['avatar'] != null) {
            await prefs.setString('avatar', d['avatar']);
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка входа')));
        }
      }
    } catch (e) {
       // err
    }
    setState(() => _l = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBackground(
        child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AQMOLA\nHUB',
                style: GoogleFonts.montserrat(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 0.9,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Добро пожаловать',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 64),
              _buildTextField(controller: _e, label: 'EMAIL'),
              const SizedBox(height: 24),
              _buildTextField(controller: _p, label: 'ПАРОЛЬ', isObscure: true),
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
                        onPressed: _doLogin,
                        child: Text(
                          'ВОЙТИ',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: Text(
                    'СОЗДАТЬ АККАУНТ',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
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
