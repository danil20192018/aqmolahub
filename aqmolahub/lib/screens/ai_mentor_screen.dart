import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class AiMentorScreen extends StatefulWidget {
  const AiMentorScreen({super.key});

  @override
  State<AiMentorScreen> createState() => _AiMentorScreenState();
}

class _AiMentorScreenState extends State<AiMentorScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final List<Map<String, String>> _msgs = [];
  bool _loading = false;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _msgs.add({
      'role': 'assistant',
      'content': 'Привет! Я твой AI Ментор. Готов помочь с твоим стартапом. Что обсудим? Могу составить Business Model Canvas, Roadmap или проанализировать конкурентов.'
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _msgs.add({'role': 'user', 'content': text});
      _loading = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}ai_mentor.php'),
        body: jsonEncode({'messages': _msgs}),
      );

      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        setState(() {
          _msgs.add({'role': 'assistant', 'content': d['reply']});
        });
      } else {
        _err('Ошибка AI');
      }
    } catch (e) {
      _err('Ошибка сети');
    }

    setState(() => _loading = false);
    _scrollToBottom();
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildBubble(Map<String, String> msg) {
    final isMe = msg['role'] == 'user';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          msg['content']!,
          style: GoogleFonts.montserrat(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12)),
        backgroundColor: Colors.amber.shade100,
        onPressed: () => _send(prompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI МЕНТОР',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Online',
                  style: GoogleFonts.montserrat(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _msgs.length,
              itemBuilder: (ctx, i) => _buildBubble(_msgs[i]),
            ),
          ),
          if (_loading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Text('Печатает...', style: GoogleFonts.montserrat(color: Colors.grey)),
                ],
              ),
            ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickAction('Business Model', 'Составь Business Model Canvas для моего стартапа'),
                _buildQuickAction('Roadmap', 'Составь Roadmap развития на 6 месяцев'),
                _buildQuickAction('Конкуренты', 'Проведи анализ потенциальных конкурентов'),
                _buildQuickAction('Инвесторы', 'Как найти инвестора для моего проекта?'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: 'Спроси что-нибудь...',
                      hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.black,
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: () => _send(_ctrl.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
