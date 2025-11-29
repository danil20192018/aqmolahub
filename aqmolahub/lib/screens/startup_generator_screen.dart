import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class StartupGeneratorScreen extends StatefulWidget {
  const StartupGeneratorScreen({super.key});

  @override
  State<StartupGeneratorScreen> createState() => _StartupGeneratorScreenState();
}

class _StartupGeneratorScreenState extends State<StartupGeneratorScreen> {
  final _industryCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _teamCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  
  List<dynamic> _ideas = [];
  bool _loading = false;
  int? _expandedIndex;

  Future<void> _generate() async {
    if (_industryCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполни индустрию')));
      return;
    }

    setState(() {
      _loading = true;
      _ideas = [];
    });

    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}ai_generator.php'),
        body: jsonEncode({
          'industry': _industryCtrl.text,
          'budget': _budgetCtrl.text,
          'team': _teamCtrl.text,
          'region': _regionCtrl.text,
          'experience': _experienceCtrl.text,
          'goal': _goalCtrl.text,
        }),
      );
      
      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        setState(() => _ideas = d['ideas']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: ${d['err']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка сети')));
    }
    
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('ГЕНЕРАТОР СТАРТАПОВ', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Параметры генерации', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _industryCtrl,
                    decoration: InputDecoration(
                      labelText: 'Индустрия *',
                      hintText: 'Например: FinTech, EdTech, HealthTech',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _budgetCtrl,
                    decoration: InputDecoration(
                      labelText: 'Бюджет',
                      hintText: 'Например: 500к тенге, 10к долларов',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _teamCtrl,
                    decoration: InputDecoration(
                      labelText: 'Размер команды',
                      hintText: 'Например: Solo, 2-3 человека, 5+',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _regionCtrl,
                    decoration: InputDecoration(
                      labelText: 'Регион',
                      hintText: 'Например: Казахстан, СНГ, Global',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _experienceCtrl,
                    decoration: InputDecoration(
                      labelText: 'Опыт',
                      hintText: 'Например: Новичок, 2 года, Эксперт',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _goalCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Цель',
                      hintText: 'Например: Заработать, Решить проблему, Изменить мир',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _loading ? null : _generate,
                      child: _loading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('СГЕНЕРИРОВАТЬ ИДЕИ', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            if (_ideas.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Сгенерированные идеи', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...List.generate(_ideas.length, (i) {
                final idea = _ideas[i];
                final isExpanded = _expandedIndex == i;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(idea['name'] ?? 'Идея ${i + 1}', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(idea['problem'] ?? '', style: GoogleFonts.montserrat(fontSize: 14)),
                        trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                        onTap: () => setState(() => _expandedIndex = isExpanded ? null : i),
                      ),
                      if (isExpanded) ...[
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildField('Решение', idea['solution']),
                              _buildField('Аудитория', idea['audience']),
                              _buildField('Бизнес-модель', idea['model']),
                              _buildField('MVP за 2 недели', idea['mvp']),
                              _buildField('Главный риск', idea['risk']),
                              _buildField('Рынок', idea['market']),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value ?? '-', style: GoogleFonts.montserrat(fontSize: 14)),
        ],
      ),
    );
  }
}
