import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class AdminQRScreen extends StatefulWidget {
  const AdminQRScreen({super.key});

  @override
  State<AdminQRScreen> createState() => _AdminQRScreenState();
}

class _AdminQRScreenState extends State<AdminQRScreen> {
  List qrList = [];
  bool _l = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _l = true);
    try {
      final res = await http.get(Uri.parse('${Cfg.url}hubcoin.php?act=list_qr'));
      if (res.statusCode == 200) {
        setState(() => qrList = jsonDecode(res.body));
      }
    } catch (e) {}
    setState(() => _l = false);
  }

  Future<void> _create(int coins, String label) async {
    final prefs = await SharedPreferences.getInstance();
    final aid = prefs.getInt('user_id');
    
    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}hubcoin.php?act=create_qr'),
        body: jsonEncode({'coins': coins, 'label': label.isEmpty ? null : label, 'admin_id': aid}),
      );
      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        _showQR(d['code'], coins);
        _fetch();
      }
    } catch (e) {}
  }

  void _showQR(String code, int coins) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HUB QR CODE',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$coins HubCoins',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: QrImageView(
                data: code,
                version: QrVersions.auto,
                size: 250,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Распечатай и раздай участникам!',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ЗАКРЫТЬ', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCreate() {
    final labelCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Создать QR', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: InputDecoration(
                labelText: 'Название (необязательно)',
                hintText: 'Например: Питч-сессия',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.montserrat(),
              ),
            ),
            const SizedBox(height: 20),
            Text('Выбери количество монет:', style: GoogleFonts.montserrat()),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [5, 10, 25, 50, 100].map((coins) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade100,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _create(coins, labelCtrl.text);
                  },
                  child: Text(
                    '$coins',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showScans(var qrId, String label) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(label.isEmpty ? 'Кто отсканировал' : label, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder(
            future: http.get(Uri.parse('${Cfg.url}hubcoin.php?act=get_scans&qr_id=$qrId')),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }
              if (snapshot.hasData) {
                final List scans = jsonDecode(snapshot.data!.body);
                if (scans.isEmpty) return const Text('Никто не сканировал');
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: scans.length,
                  itemBuilder: (context, index) {
                    final scan = scans[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber.shade100,
                        child: Text(
                          scan['name'][0].toUpperCase(),
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(scan['name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                      subtitle: Text(scan['scanned_at'], style: GoogleFonts.montserrat(fontSize: 12)),
                    );
                  },
                );
              }
              return const Text('Ошибка загрузки');
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ЗАКРЫТЬ', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQR(var qrId) async {
    try {
      await http.post(
        Uri.parse('${Cfg.url}hubcoin.php?act=delete_qr'),
        body: jsonEncode({'qr_id': qrId}),
      );
      _fetch();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR удален')));
    } catch (e) {}
  }

  Future<void> _toggleActive(var qrId, int currentActive) async {
    try {
      await http.post(
        Uri.parse('${Cfg.url}hubcoin.php?act=toggle_active'),
        body: jsonEncode({'qr_id': qrId, 'active': currentActive == 1 ? 0 : 1}),
      );
      _fetch();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentActive == 1 ? 'QR деактивирован' : 'QR активирован')),
      );
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
          'HUB QR АДМИН',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: _showCreate,
        icon: const Icon(Icons.qr_code),
        label: Text('СОЗДАТЬ QR', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
      ),
      body: _l
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: qrList.length,
              itemBuilder: (context, index) {
                final qr = qrList[index];
                final scanCount = int.parse((qr['scan_count'] ?? 0).toString());
                final scannedBy = qr['scanned_by']?.toString() ?? '';
                final label = qr['label']?.toString() ?? '';
                final active = int.parse((qr['active'] ?? 1).toString());
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: active == 0 ? Colors.grey.shade100 : Colors.white,
                    border: Border.all(
                      color: active == 0 ? Colors.grey.shade400 : Colors.black,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: active == 0 ? Colors.grey.shade300 : Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.qr_code,
                              color: active == 0 ? Colors.grey : Colors.amber.shade900,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (label.isNotEmpty)
                                  Text(
                                    label,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Text(
                                      '${qr['coins']} HubCoins',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (active == 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'ВЫКЛЮЧЕН',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade900,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: scanCount > 0 ? Colors.green.shade100 : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '$scanCount сканов',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: scanCount > 0 ? Colors.green.shade900 : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Создан: ${qr['created_at']}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.black),
                              ),
                              onPressed: () => _showQR(qr['code'], int.parse(qr['coins'].toString())),
                              icon: const Icon(Icons.qr_code, size: 18),
                              label: Text('QR', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                              ),
                              onPressed: () => _showScans(qr['id'], label),
                              icon: const Icon(Icons.people, size: 18),
                              label: Text('$scanCount', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              active == 1 ? Icons.toggle_on : Icons.toggle_off,
                              color: active == 1 ? Colors.green : Colors.grey,
                              size: 32,
                            ),
                            onPressed: () => _toggleActive(qr['id'], active),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteQR(qr['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
