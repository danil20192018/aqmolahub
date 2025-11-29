import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../widgets/animated_background.dart';

class VacanciesScreen extends StatefulWidget {
  const VacanciesScreen({super.key});

  @override
  State<VacanciesScreen> createState() => _VacanciesScreenState();
}

class _VacanciesScreenState extends State<VacanciesScreen> {
  List list = [];
  bool isLoading = true;
  Map<int, bool> respondedVacancies = {};

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await http.get(Uri.parse('${Cfg.url}vacancies.php?act=list'));
      if (res.statusCode == 200) {
        setState(() => list = jsonDecode(res.body));
        await _checkAllResponses();
      }
    } catch (e) {}
    setState(() => isLoading = false);
  }

  Future<void> _checkAllResponses() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return;

    for (var vacancy in list) {
      try {
        final res = await http.get(Uri.parse('${Cfg.url}vacancies.php?act=check_response&user_id=$userId&vacancy_id=${vacancy['id']}'));
        final data = jsonDecode(res.body);
        if (data['responded'] == true) {
          setState(() => respondedVacancies[int.parse(vacancy['id'].toString())] = true);
        }
      } catch (e) {}
    }
  }

  Future<void> _respond(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сначала войдите в аккаунт')));
      return;
    }
    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}vacancies.php?act=respond'),
        body: jsonEncode({'user_id': userId, 'vacancy_id': id}),
      );

      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        setState(() => respondedVacancies[id] = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Вы успешно откликнулись!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Вы уже откликнулись')));
      }
    } catch (e) {}
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
          'ВАКАНСИИ',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['title'].toString().toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['salary'] ?? '',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['company'] ?? '',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['descr'] ?? '',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: respondedVacancies[int.parse(item['id'].toString())] == true ? Colors.grey : Colors.black,
                              side: BorderSide(color: respondedVacancies[int.parse(item['id'].toString())] == true ? Colors.grey : Colors.black, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: respondedVacancies[int.parse(item['id'].toString())] == true ? null : () => _respond(int.parse(item['id'].toString())),
                            child: Text(
                              respondedVacancies[int.parse(item['id'].toString())] == true ? 'ВЫ ОТКЛИКНУЛИСЬ' : 'ОТКЛИКНУТЬСЯ',
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
