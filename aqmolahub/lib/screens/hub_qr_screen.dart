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
    setState(() => scanning = true);

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
      }
    } catch (e) {
      _showError('ошибка сети');
    }

    setState(() => scanning = false);
  }

  void _showSuccess(int earned) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            child: Text('КРУТО!', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
