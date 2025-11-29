import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../web_image.dart';
import '../widgets/animated_background.dart';

class EventDetailScreen extends StatefulWidget {
  final Map event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool isLoading = false;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return;

    try {
      final res = await http.get(Uri.parse('${Cfg.url}events.php?act=check_registration&user_id=$userId&event_id=${widget.event['id']}'));
      final data = jsonDecode(res.body);
      if (data['registered'] == true) {
        setState(() => isRegistered = true);
      }
    } catch (e) {}
  }

  Future<void> _register() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сначала войдите в аккаунт')));
        setState(() => isLoading = false);
        return;
      }

      final res = await http.post(
        Uri.parse('${Cfg.url}events.php?act=register'),
        body: jsonEncode({'user_id': userId, 'event_id': widget.event['id']}),
      );
      
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        setState(() => isRegistered = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Вы успешно зарегистрированы!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Вы уже зарегистрированы')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка сети')));
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
        title: Text(
          'МЕРОПРИЯТИЕ',
          style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.event['image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(4, 4))],
                    ),
                    child: WebImage(widget.event['image'], height: 250, width: double.infinity, fit: BoxFit.cover),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                widget.event['title'].toString().toUpperCase(),
                style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text('${widget.event['date']} в ${widget.event['time']}', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Text(widget.event['location'], style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                widget.event['descr'],
                style: GoogleFonts.montserrat(fontSize: 16, height: 1.6, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegistered ? Colors.grey : Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                    elevation: 10,
                  ),
                  onPressed: (isLoading || isRegistered) ? null : _register,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isRegistered ? 'ВЫ ЗАРЕГИСТРИРОВАНЫ' : 'ЗАРЕГИСТРИРОВАТЬСЯ',
                          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
