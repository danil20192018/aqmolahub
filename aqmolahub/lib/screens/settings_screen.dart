import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/animated_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value) {
      final granted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.black),
              const SizedBox(width: 10),
              Expanded(child: Text('Разрешить уведомления?', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Text(
            'Приложение запрашивает разрешение на отправку уведомлений о новых стартапах, мероприятиях и новостях.',
            style: GoogleFonts.montserrat(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('ЗАПРЕТИТЬ', style: GoogleFonts.montserrat(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text('РАЗРЕШИТЬ', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (granted == true) {
        setState(() => _notificationsEnabled = true);
        await prefs.setBool('notifications_enabled', true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Уведомления включены! 🔔')),
          );
        }
      } else {
        setState(() => _notificationsEnabled = false);
      }
    } else {
      setState(() => _notificationsEnabled = false);
      await prefs.setBool('notifications_enabled', false);
    }
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
          'НАСТРОЙКИ',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
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
              child: SwitchListTile(
                activeColor: Colors.black,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  'Получать уведомления',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Новости, обновления и события',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
