import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'dart:math' as math;

class QrArViewScreen extends StatefulWidget {
  final String qrCode;
  const QrArViewScreen({super.key, required this.qrCode});

  @override
  State<QrArViewScreen> createState() => _QrArViewScreenState();
}

class _QrArViewScreenState extends State<QrArViewScreen> with TickerProviderStateMixin {
  Map? _data;
  bool _load = true;
  late AnimationController _rotCtrl;
  late AnimationController _scaleCtrl;
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..forward();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await http.get(Uri.parse('${Cfg.url}qr_card.php?act=get&qr=${widget.qrCode}'));
      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        setState(() => _data = d['data']);
      }
    } catch (e) {}
    setState(() => _load = false);
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _scaleCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_load) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_data == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'QR не найден',
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final theme = _getColor(_data!['theme'] ?? 'blue');

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _rotCtrl,
            builder: (ctx, child) {
              return CustomPaint(
                painter: ParticlePainter(_rotCtrl.value, theme),
                size: Size.infinite,
              );
            },
          ),
          
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_scaleCtrl, _floatCtrl]),
              builder: (ctx, child) {
                return Transform.translate(
                  offset: Offset(0, math.sin(_floatCtrl.value * math.pi * 2) * 20),
                  child: Transform.scale(
                    scale: _scaleCtrl.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.withOpacity(0.3),
                      theme.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [theme, theme.withOpacity(0.5)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.withOpacity(0.6),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _data!['name'][0].toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _data!['name'].toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _data!['role'] ?? '',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: theme,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_data!['bio'] != null && _data!['bio'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _data!['bio'],
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (_data!['skills'] != null && _data!['skills'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: _data!['skills'].split(',').map<Widget>((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme),
                            ),
                            child: Text(
                              s.trim(),
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (_data!['contact'] != null && _data!['contact'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _data!['contact'],
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String t) {
    switch (t) {
      case 'blue': return Colors.blue;
      case 'purple': return Colors.purple;
      case 'green': return Colors.green;
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      default: return Colors.blue;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final double anim;
  final Color col;
  
  ParticlePainter(this.anim, this.col);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = col.withOpacity(0.3);
    
    for (int i = 0; i < 50; i++) {
      final x = (i * 37.5 + anim * 200) % size.width;
      final y = (i * 23.7 + anim * 150) % size.height;
      final r = 2 + math.sin(anim * math.pi * 2 + i) * 2;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
