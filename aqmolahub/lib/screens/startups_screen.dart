import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../widgets/animated_background.dart';
import '../web_circle_avatar.dart';
import 'startup_detail_screen.dart';

class StartupsScreen extends StatefulWidget {
  const StartupsScreen({super.key});

  @override
  State<StartupsScreen> createState() => _StartupsScreenState();
}

class _StartupsScreenState extends State<StartupsScreen> {
  List startups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStartups();
  }

  Future<void> _fetchStartups() async {
    try {
      final res = await http.get(Uri.parse('${Cfg.url}startups.php?act=list'));
      if (res.statusCode == 200) {
        setState(() {
          startups = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
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
          'СТАРТАПЫ',
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
                itemCount: startups.length,
                itemBuilder: (context, index) {
                  final item = startups[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StartupDetailScreen(startup: item),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: WebCircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey.shade200,
                              imageUrl: item['image'],
                              child: item['image'] == null
                                  ? const Icon(Icons.rocket_launch, size: 30, color: Colors.black)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'].toString().toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['description'] ?? '',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: _showAIEvaluator,
        icon: const Icon(Icons.psychology),
        label: Text('AI ОЦЕНКА', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAIEvaluator() {
    final ideaController = TextEditingController();
    bool isLoading = false;
    String? evaluation;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.psychology, color: Colors.black),
              const SizedBox(width: 8),
              Text('AI Оценка Идеи', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Опишите вашу стартап-идею, и AI даст профессиональную оценку',
                    style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ideaController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Например: Мобильное приложение для аренды велосипедов в городе...',
                      border: const OutlineInputBorder(),
                      hintStyle: GoogleFonts.montserrat(fontSize: 12),
                    ),
                  ),
                  if (evaluation != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, size: 20),
                              const SizedBox(width: 8),
                              Text('Оценка AI', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            evaluation!,
                            style: GoogleFonts.montserrat(fontSize: 13, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            if (!isLoading)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('ЗАКРЫТЬ', style: GoogleFonts.montserrat(color: Colors.grey)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (ideaController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Введите описание идеи')),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        final response = await http.post(
                          Uri.parse('${Cfg.url}ai_evaluate.php'),
                          body: jsonEncode({'idea': ideaController.text}),
                        );

                        final data = jsonDecode(response.body);
                        if (data['success'] == true) {
                          setDialogState(() {
                            evaluation = data['evaluation'];
                            isLoading = false;
                          });
                        } else {
                          setDialogState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(data['error'] ?? 'Ошибка')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ошибка сети')),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('ОЦЕНИТЬ', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
