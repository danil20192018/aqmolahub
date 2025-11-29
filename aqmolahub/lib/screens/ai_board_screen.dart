import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../web_circle_avatar.dart';

class AiBoardScreen extends StatefulWidget {
  const AiBoardScreen({super.key});

  @override
  State<AiBoardScreen> createState() => _AiBoardScreenState();
}

class _AiBoardScreenState extends State<AiBoardScreen> {
  final _textCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _history = [];
  bool _loading = false;
  final ScrollController _scrollCtrl = ScrollController();

  Future<void> _sendMessage() async {
    if (_textCtrl.text.isEmpty) return;

    final userText = _textCtrl.text;
    setState(() {
      _textCtrl.clear();
      _messages.add({'speaker': 'Me', 'text': userText, 'isUser': true});
      _history.add({'speaker': 'Me', 'text': userText, 'isUser': true});
      _loading = true;
    });
    _scrollToBottom();

    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}ai_board.php'),
        body: jsonEncode({'history': _history}),
      );
      final d = jsonDecode(res.body);
      
      if (d['res'] == true) {
        final dialog = List<Map<String, dynamic>>.from(d['dialog']);
        
        for (var msg in dialog) {
          await Future.delayed(const Duration(milliseconds: 1500));
          if (!mounted) return;
          setState(() {
            _messages.add({
              'speaker': msg['speaker'], 
              'text': msg['text'], 
              'isUser': false
            });
            _history.add({
              'speaker': msg['speaker'], 
              'text': msg['text'], 
              'isUser': false
            });
          });
          _scrollToBottom();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: ${d['err']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка сети')));
    }
    setState(() => _loading = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildAvatar(String speaker) {
    Color color;
    IconData icon;
    
    if (speaker == 'Elon') {
      color = Colors.blue;
      icon = Icons.rocket_launch;
    } else if (speaker == 'Steve') {
      color = Colors.grey.shade800;
      icon = Icons.apple;
    } else if (speaker == 'Skeptic') {
      color = Colors.green;
      icon = Icons.attach_money;
    } else {
      color = Colors.black;
      icon = Icons.person;
    }

    return CircleAvatar(
      backgroundColor: color,
      child: Icon(icon, color: Colors.white, size: 20),
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
        title: Text('СОВЕТ ДИРЕКТОРОВ', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.groups, size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Расскажите свою идею,\nи Совет Директоров обсудит её.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == _messages.length) {
                        return const Center(child: Padding(padding: EdgeInsets.all(10), child: Text('Совет совещается...', style: TextStyle(color: Colors.grey))));
                      }
                      
                      final msg = _messages[i];
                      final isUser = msg['isUser'] == true;
                      final speaker = msg['speaker'];
                      
                      if (isUser) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  msg['text'],
                                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAvatar(speaker),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      speaker,
                                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      msg['text'],
                                      style: GoogleFonts.montserrat(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ваш ответ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: _loading ? null : _sendMessage,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
