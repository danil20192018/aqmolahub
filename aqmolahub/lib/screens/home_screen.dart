import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feed_screen.dart';
import 'account_screen.dart';
import 'admin_panel_screen.dart';
import 'events_screen.dart';
import 'startups_screen.dart';
import 'vacancies_screen.dart';
import 'networking_screen.dart';
import '../services/notification_service.dart';
import 'hub_qr_screen.dart';
import 'pitch_trainer_screen.dart';
import 'ai_mentor_screen.dart';
import 'ai_board_screen.dart';
import 'market_screen.dart';
import 'startup_generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool isAdmin = false;
  List<Widget> screens = [];
  List<BottomNavigationBarItem> navItems = [];

  @override
  void initState() {
    super.initState();
    _checkRole();
    _listenForNotifications();
  }

  void _listenForNotifications() {
    NotificationService().notificationStream.listen((notification) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.black),
              const SizedBox(width: 10),
              Expanded(child: Text(notification['title'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Text(
            notification['message'],
            style: GoogleFonts.montserrat(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ЗАКРЫТЬ', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    
    setState(() {
      isAdmin = role == 'Админ';
      
      screens = [
        const FeedScreen(),
        const SizedBox(),
        const AccountScreen(),
        if (isAdmin) const AdminPanelScreen(),
      ];
      
      navItems = [
        const BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Лента'),
        const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Меню'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Аккаунт'),
        if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Админ'),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (screens.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 1) {
            _showMenuBottomSheet(context);
          } else {
            setState(() => currentIndex = index);
          }
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.montserrat(),
        items: navItems,
      ),
    );
  }

  void _showMenuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildMenuItem(Icons.event, 'Мероприятия'),
              _buildMenuItem(Icons.rocket_launch, 'Стартапы'),
              _buildMenuItem(Icons.work_outline, 'Вакансии'),
              _buildMenuItem(Icons.people_outline, 'Нетворкинг'),
              _buildMenuItem(Icons.qr_code_scanner, 'HUB QR'),
              _buildMenuItem(Icons.mic, 'Питч-тренажер'),
              _buildMenuItem(Icons.smart_toy, 'AI Ментор'),
              _buildMenuItem(Icons.groups, 'AI Совет Директоров'),
              _buildMenuItem(Icons.shopping_cart, 'Биржа Талантов'),
              _buildMenuItem(Icons.lightbulb, 'Генератор Стартапов'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        if (title == 'Мероприятия') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen()));
        } else if (title == 'Стартапы') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StartupsScreen()));
        } else if (title == 'Вакансии') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const VacanciesScreen()));
        } else if (title == 'Нетворкинг') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NetworkingScreen()));
        } else if (title == 'HUB QR') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HubQRScreen()));
        } else if (title == 'Питч-тренажер') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PitchTrainerScreen()));
        } else if (title == 'AI Ментор') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AiMentorScreen()));
        } else if (title == 'AI Совет Директоров') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AiBoardScreen()));
        } else if (title == 'Биржа Талантов') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen()));
        } else if (title == 'Генератор Стартапов') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StartupGeneratorScreen()));
        }
      },
    );
  }

}
