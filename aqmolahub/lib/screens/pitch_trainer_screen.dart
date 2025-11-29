import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config.dart';

class PitchTrainerScreen extends StatefulWidget {
  const PitchTrainerScreen({super.key});

  @override
  State<PitchTrainerScreen> createState() => _PitchTrainerScreenState();
}

class _PitchTrainerScreenState extends State<PitchTrainerScreen> {
  late stt.SpeechToText _speech;
  late AudioPlayer _player;
  
  bool _isListening = false;
  bool _analyzing = false;
  String _text = '';
  String _evaluation = '';
  
  int _timerSeconds = 180;
  int _remainingSeconds = 180;
  Timer? _timer;
  bool _timerRunning = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerRunning = true;
      _remainingSeconds = _timerSeconds;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _timerRunning = false;
          _playAlarm();
          if (_isListening) {
            _stopListening();
          }
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _timerRunning = false;
      _remainingSeconds = _timerSeconds;
    });
  }

  Future<void> _playAlarm() async {
    try {
      await _player.play(UrlSource('https://aqmolarp.kz/backendapplication/music/pitch.mp3'));
    } catch (e) {}
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _text = '';
        _evaluation = '';
      });
      
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
        localeId: 'ru-RU',
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _analyze() async {
    if (_text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала запишите питч')),
      );
      return;
    }

    setState(() => _analyzing = true);

    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}pitch_analyze.php'),
        body: jsonEncode({'text': _text}),
      );
      
      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        setState(() => _evaluation = d['eval']);
      } else {
        setState(() => _evaluation = 'Ошибка анализа');
      }
    } catch (e) {
      setState(() => _evaluation = 'Ошибка сети');
    }

    setState(() => _analyzing = false);
  }

  void _showTimerSettings() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Таймер', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Выбери время для питча:', style: GoogleFonts.montserrat()),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [60, 120, 180, 300].map((sec) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _timerSeconds == sec ? Colors.black : Colors.grey.shade200,
                    foregroundColor: _timerSeconds == sec ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _timerSeconds = sec;
                      _remainingSeconds = sec;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    '${sec ~/ 60} мин',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'ПИТЧ-ТРЕНАЖЕР',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer, color: Colors.white),
            onPressed: _showTimerSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: GoogleFonts.montserrat(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: _remainingSeconds < 30 ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_timerRunning)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          onPressed: _startTimer,
                          icon: const Icon(Icons.play_arrow),
                          label: Text('СТАРТ', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                        ),
                      if (_timerRunning)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          onPressed: _stopTimer,
                          icon: const Icon(Icons.stop),
                          label: Text('СТОП', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    _isListening ? 'ГОВОРИТЕ...' : 'НАЖМИТЕ ДЛЯ ЗАПИСИ',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _isListening ? Colors.red : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red : Colors.black,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_isListening)
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                  if (_text.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _text,
                        style: GoogleFonts.montserrat(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _analyzing ? null : _analyze,
                        icon: _analyzing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.analytics),
                        label: Text(
                          _analyzing ? 'АНАЛИЗИРУЮ...' : 'АНАЛИЗИРОВАТЬ',
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_evaluation.isNotEmpty) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.green, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'ОЦЕНКА AI',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _evaluation,
                      style: GoogleFonts.montserrat(fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
