import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class HubQRScreen extends StatefulWidget {
  const HubQRScreen({super.key});

  @override
  State<HubQRScreen> createState() => _HubQRScreenState();
}

class _HubQRScreenState extends State<HubQRScreen> {
  int coins = 0;
  bool scanning = false;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('user_id');
    try {
      final res = await http.get(Uri.parse('${Cfg.url}hubcoin.php?act=get_balance&user_id=$uid'));
      final d = jsonDecode(res.body);
      setState(() => coins = d['coins'] ?? 0);
    } catch (e) {}
  }

  Future<void> _scanQR(String code) async {
    if (scanning) return;
    await cameraController.stop();
    setState(() => scanning = true);

    if (code.startsWith('QR_')) {
      await _handleVRCard(code);
    } else {
      await _handleMoney(code);
    }

    setState(() => scanning = false);
  }

  Future<void> _handleMoney(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('user_id');

    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}hubcoin.php?act=scan_qr'),
        body: jsonEncode({'code': code, 'user_id': uid}),
      );
      final d = jsonDecode(res.body);
      
      if (d['res'] == true) {
        setState(() => coins += (d['coins'] as int));
        _showSuccess(d['coins']);
      } else {
        _showError(d['err'] ?? 'ошибка');
        await cameraController.start();
      }
    } catch (e) {
      _showError('ошибка сети');
      await cameraController.start();
    }
  }

  Future<void> _handleVRCard(String code) async {
    try {
      final res = await http.get(Uri.parse('${Cfg.url}qr_card.php?act=get&qr=$code'));
      final d = jsonDecode(res.body);

      if (d['res'] == true) {
        _showHologram(d['data']);
      } else {
        _showError(d['err'] ?? 'карточка не найдена');
        await cameraController.start();
      }
    } catch (e) {
      _showError('ошибка загрузки карты');
      await cameraController.start();
    }
  }

  void _showHologram(Map<String, dynamic> data) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
                  const BoxShadow(color: Colors.blueAccent, blurRadius: 50, spreadRadius: 1, offset: Offset(0, 0)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.nfc, color: Colors.cyanAccent, size: 20),
                      Text('HOLOGRAM ID', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 10, letterSpacing: 2)),
                      const Icon(Icons.battery_charging_full, color: Colors.cyanAccent, size: 20),
                    ],
                  ),
                  const Divider(color: Colors.cyanAccent, thickness: 1),
                  const SizedBox(height: 20),
                  
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.cyanAccent, width: 3),
                      boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20)],
                      image: data['avatar'] != null && data['avatar'].toString().isNotEmpty
                          ? DecorationImage(image: NetworkImage(data['avatar']), fit: BoxFit.cover)
                          : null,
                    ),
                    child: data['avatar'] == null || data['avatar'].toString().isEmpty
                        ? const Icon(Icons.person, color: Colors.cyanAccent, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    (data['name'] ?? 'UNKNOWN').toUpperCase(),
                    style: GoogleFonts.orbitron(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    (data['role'] ?? 'NO DATA').toUpperCase(),
                    style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 14, letterSpacing: 1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  if (data['bio'] != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                      ),
                      child: Text(
                        data['bio'],
                        style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.cyanAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'SCANS: ${data['scans']}',
                        style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.cyanAccent),
                        backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('TERMINATE LINK', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    ).then((_) {
      setState(() => scanning = false);
      cameraController.start();
    });
  }

  void _showSuccess(int earned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),
            Text(
              '+$earned HubCoins!',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Баланс: $coins',
              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('КРУТО!', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    ).then((_) {
      setState(() => scanning = false);
      cameraController.start();
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'HUB QR',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _scanQR(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.monetization_on, color: Colors.amber.shade700, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Баланс',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$coins',
                        style: GoogleFonts.montserrat(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HubCoins',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'Наведи на QR',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}