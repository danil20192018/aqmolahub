import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../web_circle_avatar.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _offers = [];
  List<dynamic> _requests = [];
  bool _loading = false;
  int _myId = 0;
  int _myCoins = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    _myId = prefs.getInt('user_id') ?? 0;
    
    try {   
      final res = await http.post(
        Uri.parse('${Cfg.url}hubcoin.php?act=get_balance'),
        body: jsonEncode({'user_id': _myId}),
      );
      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        setState(() => _myCoins = d['coins']);
      }
    } catch (e) {}

    await _fetchListings('offer');
    await _fetchListings('request');
    setState(() => _loading = false);
  }

  Future<void> _fetchListings(String type) async {
    try {
      final res = await http.get(Uri.parse('${Cfg.url}market.php?act=list&type=$type'));
      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        setState(() {
          if (type == 'offer') _offers = d['data'];
          else _requests = d['data'];
        });
      }
    } catch (e) {}
  }

  Future<void> _createListing(String type, String title, String desc, int price) async {
    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}market.php?act=create'),
        body: jsonEncode({
          'user_id': _myId,
          'type': type,
          'title': title,
          'desc': desc,
          'price': price
        }),
      );
      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        Navigator.pop(context);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Объявление создано!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: ${d['err']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка сети')));
    }
  }

  Future<void> _buy(int listingId, int price) async {
    if (_myCoins < price) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Недостаточно HubCoins!')));
      return;
    }

    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Подтверждение', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text('Купить за $price HC? Комиссия системы 5% будет списана с продавца.', style: GoogleFonts.montserrat()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ОТМЕНА')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('КУПИТЬ'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}market.php?act=buy'),
        body: jsonEncode({
          'buyer_id': _myId,
          'listing_id': listingId
        }),
      );
      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(d['msg'])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: ${d['err']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка сети')));
    }
  }

  Future<void> _deleteListing(int listingId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Удалить?', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text('Вы уверены, что хотите удалить это объявление?', style: GoogleFonts.montserrat()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ОТМЕНА')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('УДАЛИТЬ'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}market.php?act=delete'),
        body: jsonEncode({
          'user_id': _myId,
          'listing_id': listingId
        }),
      );
      final d = jsonDecode(res.body);
      if (d['res'] == true) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Удалено')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: ${d['err']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка сети')));
    }
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String type = _tabController.index == 0 ? 'offer' : 'request';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == 'offer' ? 'Создать предложение' : 'Создать запрос', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Заголовок (напр. Сделаю лого)'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Описание'),
              maxLines: 3,
            ),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Цена (HubCoins)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ОТМЕНА')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              if (titleCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              _createListing(type, titleCtrl.text, descCtrl.text, int.parse(priceCtrl.text));
            },
            child: const Text('СОЗДАТЬ'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> items) {
    if (items.isEmpty) {
      return Center(child: Text('Нет объявлений', style: GoogleFonts.montserrat(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        final isMe = int.parse(item['user_id'].toString()) == _myId;
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    WebCircleAvatar(
                      imageUrl: item['author_avatar'],
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['author_name'] ?? 'Аноним', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                        Text(item['created_at'], style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item['price']} HC',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item['title'],
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (item['description'] != null) ...[
                  const SizedBox(height: 8),
                  Text(item['description'], style: GoogleFonts.montserrat(color: Colors.grey.shade700)),
                ],
                const SizedBox(height: 16),
                if (!isMe)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _buy(int.parse(item['id'].toString()), int.parse(item['price'].toString())),
                      child: Text('КУПИТЬ / ОТКЛИКНУТЬСЯ', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (isMe)
                  Row(
                    children: [
                      Text('Ваше объявление', style: GoogleFonts.montserrat(color: Colors.grey, fontStyle: FontStyle.italic)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteListing(int.parse(item['id'].toString())),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
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
        title: Text('БИРЖА ТАЛАНТОВ', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.w900)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_myCoins HC',
                  style: GoogleFonts.montserrat(color: Colors.amber, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'ПРЕДЛОЖЕНИЯ'),
            Tab(text: 'ЗАПРОСЫ'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_offers),
                _buildList(_requests),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
