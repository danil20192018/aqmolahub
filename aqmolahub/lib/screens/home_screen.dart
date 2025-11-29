import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feed_screen.dart';
import 'account_screen.dart';
import 'admin_panel_screen.dart';
import 'events_screen.dart';

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
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    
    setState(() {
      isAdmin = role == 'Админ';
      
      screens = [
        const FeedScreen(),
        const SizedBox(), // Placeholder for Menu
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
            const SizedBox(height: 20),
          ],
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
        }
      },
    );
  }

}
