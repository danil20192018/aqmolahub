import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:math';
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
            String avatar = d['avatar'];
            if (!avatar.startsWith('http')) {
              avatar = '${Cfg.url}$avatar';
            }
            await prefs.setString('avatar', avatar);
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка входа')));
        }
      }
    } catch (e) {
       
    }
    setState(() => _l = false);
  }

  Future<void> _loginWithTelegram() async {
    final code = (100000 + Random().nextInt(900000)).toString();
    
    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}telegram_code.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );
    } catch (e) {
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Вход через Telegram', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ваш код для входа:', style: GoogleFonts.montserrat(fontSize: 14)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                code,
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Напишите боту:', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
            Text('/code $code', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
            const SizedBox(height: 8),
            Text('Ожидание подтверждения...', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ОТМЕНА', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    int attempts = 0;
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      attempts++;
      if (attempts > 60 || !mounted) {
        timer.cancel();
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        return;
      }

      try {
        final res = await http.get(Uri.parse('${Cfg.url}telegram_code.php?code=$code'));
        if (res.statusCode == 200) {
          final d = jsonDecode(res.body);
          if (d['res'] == true) {
            timer.cancel();
            if (mounted && Navigator.canPop(context)) Navigator.pop(context);
            
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', d['t']);
            await prefs.setString('name', d['name'] ?? 'User');
            await prefs.setString('email', d['email'] ?? '');
            await prefs.setString('role', d['r'] ?? '');
            await prefs.setInt('user_id', d['user_id'] ?? 0);
            if (d['avatar'] != null) {
              String avatar = d['avatar'];
              if (!avatar.startsWith('http')) {
                avatar = '${Cfg.url}$avatar';
              }
              await prefs.setString('avatar', avatar);
            }
            
            if (mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            }
          }
        }
      } catch (e) {
      }
    });
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _l ? null : _doLogin,
                  child: _l
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('ВОЙТИ', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _l ? null : _loginWithTelegram,
                  icon: const Icon(Icons.telegram, color: Colors.blue),
                  label: Text('ВОЙТИ ЧЕРЕЗ TELEGRAM', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
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
