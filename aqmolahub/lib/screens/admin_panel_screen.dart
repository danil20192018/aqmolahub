import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../config.dart';
import '../web_image.dart';
import '../web_circle_avatar.dart';
import 'admin_qr_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController tabCtrl;
  List usersList = [];
  List eventsList = [];
  List vacList = [];
  List newsList = [];
  List startupsList = [];
  List notifList = [];
  bool isLoading = false;
  
  final titleCtrl = TextEditingController();
  final descrCtrl = TextEditingController();
  String? newsImageUrl;

  final evTitleCtrl = TextEditingController();
  final evDescrCtrl = TextEditingController();
  final evDateCtrl = TextEditingController();
  final evTimeCtrl = TextEditingController();
  final evLocCtrl = TextEditingController();
  String? evImageUrl;

  final vacTitleCtrl = TextEditingController();
  final vacCompCtrl = TextEditingController();
  final vacSalCtrl = TextEditingController();
  final vacDescrCtrl = TextEditingController();

  final startupNameCtrl = TextEditingController();
  final startupDescrCtrl = TextEditingController();
  final startupFullDescrCtrl = TextEditingController();
  final startupFounderCtrl = TextEditingController();
  final startupWebsiteCtrl = TextEditingController();
  final startupStageCtrl = TextEditingController();
  final startupFundingCtrl = TextEditingController();
  final startupTeamSizeCtrl = TextEditingController();
  final startupEmailCtrl = TextEditingController();
  String? startupImageUrl;

  final notifTitleCtrl = TextEditingController();
  final notifMsgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabCtrl = TabController(length: 7, vsync: this);
    _fetchUsers();
    _fetchVacancies();
    _fetchNews();
    _fetchStartups();
    _fetchNotifications();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('${Cfg.url}admin.php?act=users'));
      if (response.statusCode == 200) {
        setState(() => usersList = jsonDecode(response.body));
      }
    } catch (e) {}
    setState(() => isLoading = false);
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('${Cfg.url}events.php?act=list'));
      if (response.statusCode == 200) {
        setState(() => eventsList = jsonDecode(response.body));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки мероприятий: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка сети: $e')));
    }
  }

  Future<void> _fetchVacancies() async {
    try {
      final response = await http.get(Uri.parse('${Cfg.url}vacancies.php?act=list'));
      if (response.statusCode == 200) {
        setState(() => vacList = jsonDecode(response.body));
      }
    } catch (e) {}
  }

  Future<void> _fetchNews() async {
    try {
      final response = await http.get(Uri.parse('${Cfg.url}admin.php?act=listnews'));
      if (response.statusCode == 200) {
        setState(() => newsList = jsonDecode(response.body));
      }
    } catch (e) {}
  }

  Future<void> _fetchStartups() async {
    try {
      final response = await http.get(Uri.parse('${Cfg.url}startups.php?act=list'));
      if (response.statusCode == 200) {
        setState(() => startupsList = jsonDecode(response.body));
      }
    } catch (e) {}
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('${Cfg.url}notifications.php?act=list'));
      if (response.statusCode == 200) {
        setState(() => notifList = jsonDecode(response.body));
      }
    } catch (e) {}
  }

  Future<void> _pickNewsImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => isLoading = true);
      try {
        final bytes = await image.readAsBytes();
        final request = http.MultipartRequest('POST', Uri.parse('${Cfg.url}upload.php?type=news'));
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'news_${DateTime.now().millisecondsSinceEpoch}.jpg'));
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        if (data['success'] == true) {
          setState(() => newsImageUrl = '${Cfg.url}${data['url']}');
        }
      } catch (e) {}
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickEventImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => isLoading = true);
      try {
        final bytes = await image.readAsBytes();
        final request = http.MultipartRequest('POST', Uri.parse('${Cfg.url}upload.php?type=event'));
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'event_${DateTime.now().millisecondsSinceEpoch}.jpg'));
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        if (data['success'] == true) {
          setState(() => evImageUrl = '${Cfg.url}${data['url']}');
        }
      } catch (e) {}
      setState(() => isLoading = false);
    }
  }

  Future<void> _createNews() async {
    if (titleCtrl.text.isEmpty || descrCtrl.text.isEmpty) return;
    setState(() => isLoading = true);
    try {
      await http.post(
        Uri.parse('${Cfg.url}admin.php?act=createnews'),
        body: jsonEncode({
          'title': titleCtrl.text,
          'descr': descrCtrl.text,
          'image': newsImageUrl,
        }),
      );
      titleCtrl.clear();
      descrCtrl.clear();
      setState(() => newsImageUrl = null);
      Navigator.pop(context);
      _fetchNews();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Новость создана')));
    } catch (e) {}
    setState(() => isLoading = false);
  }

  Future<void> _createEvent() async {
    if (evTitleCtrl.text.isEmpty) return;
    setState(() => isLoading = true);
    try {
      await http.post(
        Uri.parse('${Cfg.url}events.php?act=create'),
        body: jsonEncode({
          'title': evTitleCtrl.text,
          'descr': evDescrCtrl.text,
          'date': evDateCtrl.text,
          'time': evTimeCtrl.text,
          'location': evLocCtrl.text,
          'image': evImageUrl,
        }),
      );
      evTitleCtrl.clear();
      evDescrCtrl.clear();
      evDateCtrl.clear();
      evTimeCtrl.clear();
      evLocCtrl.clear();
      setState(() => evImageUrl = null);
      Navigator.pop(context);
      _fetchEvents();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Мероприятие создано')));
    } catch (e) {}
    setState(() => isLoading = false);
  }

  Future<void> _createVacancy() async {
    if (vacTitleCtrl.text.isEmpty) return;
    setState(() => isLoading = true);
    try {
      await http.post(
        Uri.parse('${Cfg.url}vacancies.php?act=create'),
        body: jsonEncode({
          'title': vacTitleCtrl.text,
          'company': vacCompCtrl.text,
          'salary': vacSalCtrl.text,
          'descr': vacDescrCtrl.text,
        }),
      );
      vacTitleCtrl.clear();
      vacCompCtrl.clear();
      vacSalCtrl.clear();
      vacDescrCtrl.clear();
      Navigator.pop(context);
      _fetchVacancies();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Вакансия создана')));
    } catch (e) {}
    setState(() => isLoading = false);
  }

  Future<void> _pickStartupImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => isLoading = true);
      try {
        final bytes = await image.readAsBytes();
        final request = http.MultipartRequest('POST', Uri.parse('${Cfg.url}upload.php?type=startup'));
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'startup_${DateTime.now().millisecondsSinceEpoch}.jpg'));
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        if (data['success'] == true) {
          setState(() => startupImageUrl = '${Cfg.url}${data['url']}');
        }
      } catch (e) {}
      setState(() => isLoading = false);
    }
  }

  Future<void> _createStartup() async {
    if (startupNameCtrl.text.isEmpty) return;
    setState(() => isLoading = true);
    try {
      await http.post(
        Uri.parse('${Cfg.url}startups.php?act=create'),
        body: jsonEncode({
          'name': startupNameCtrl.text,
          'description': startupDescrCtrl.text,
          'full_description': startupFullDescrCtrl.text,
          'founder': startupFounderCtrl.text,
          'website': startupWebsiteCtrl.text,
          'stage': startupStageCtrl.text,
          'funding': startupFundingCtrl.text,
          'team_size': startupTeamSizeCtrl.text,
          'contact_email': startupEmailCtrl.text,
          'image': startupImageUrl,
        }),
      );
      startupNameCtrl.clear();
      startupDescrCtrl.clear();
      startupFullDescrCtrl.clear();
      startupFounderCtrl.clear();
      startupWebsiteCtrl.clear();
      startupStageCtrl.clear();
      startupFundingCtrl.clear();
      startupTeamSizeCtrl.clear();
      startupEmailCtrl.clear();
      setState(() => startupImageUrl = null);
      Navigator.pop(context);
      _fetchStartups();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Стартап создан')));
    } catch (e) {}
    setState(() => isLoading = false);
  }

  Future<void> _sendNotification() async {
    if (notifTitleCtrl.text.isEmpty) return;
    setState(() => isLoading = true);
    try {
      await http.post(
        Uri.parse('${Cfg.url}notifications.php?act=send'),
        body: jsonEncode({
          'title': notifTitleCtrl.text,
          'message': notifMsgCtrl.text,
        }),
      );
      notifTitleCtrl.clear();
      notifMsgCtrl.clear();
      Navigator.pop(context);
      _fetchNotifications();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Уведомление отправлено')));
    } catch (e) {}
    setState(() => isLoading = false);
  }

  Future<void> _deleteEvent(int id) async {
    try {
      await http.post(
        Uri.parse('${Cfg.url}events.php?act=delete'),
        body: jsonEncode({'id': id}),
      );
      _fetchEvents();
    } catch (e) {}
  }

  Future<void> _deleteVacancy(int id) async {
    try {
      await http.post(
        Uri.parse('${Cfg.url}vacancies.php?act=delete'),
        body: jsonEncode({'id': id}),
      );
      _fetchVacancies();
    } catch (e) {}
  }

  Future<void> _deleteNews(int id) async {
    try {
      await http.post(
        Uri.parse('${Cfg.url}admin.php?act=deletenews'),
        body: jsonEncode({'id': id}),
      );
      _fetchNews();
    } catch (e) {}
  }

  Future<void> _deleteStartup(int id) async {
    try {
      await http.post(
        Uri.parse('${Cfg.url}startups.php?act=delete'),
        body: jsonEncode({'id': id}),
      );
      _fetchStartups();
    } catch (e) {}
  }

  Future<void> _deleteNotification(int id) async {
    try {
      await http.post(
        Uri.parse('${Cfg.url}notifications.php?act=delete'),
        body: jsonEncode({'id': id}),
      );
      _fetchNotifications();
    } catch (e) {}
  }

  Future<void> _deleteRegistration(int eventId, int userId) async {
    try {
      await http.post(
        Uri.parse('${Cfg.url}events.php?act=delete_registration'),
        body: jsonEncode({'event_id': eventId, 'user_id': userId}),
      );
      Navigator.pop(context);
      _showRegistrations(eventId);
    } catch (e) {}
  }

  Future<void> _deleteVacancyResponse(int vacancyId, int userId) async {
    try {
      await http.post(
        Uri.parse('${Cfg.url}vacancies.php?act=delete_response'),
        body: jsonEncode({'vacancy_id': vacancyId, 'user_id': userId}),
      );
      Navigator.pop(context);
      _showVacancyResponses(vacancyId);
    } catch (e) {}
  }

  Future<void> _showVacancyResponses(var vacancyId) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Отклики', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder(
            future: http.get(Uri.parse('${Cfg.url}vacancies.php?act=get_responses&vacancy_id=$vacancyId')),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }
              if (snapshot.hasData) {
                final List users = jsonDecode(snapshot.data!.body);
                if (users.isEmpty) return const Text('Нет откликов');
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: WebCircleAvatar(imageUrl: user['avatar']),
                      title: Text(user['name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                      subtitle: Text(user['email'], style: GoogleFonts.montserrat(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteVacancyResponse(int.parse(vacancyId.toString()), int.parse(user['id'].toString())),
                      ),
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
            child: Text('ЗАКРЫТЬ', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _showRegistrations(var eventId) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Участники', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder(
            future: http.get(Uri.parse('${Cfg.url}events.php?act=get_registrations&event_id=$eventId')),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }
              if (snapshot.hasData) {
                final List users = jsonDecode(snapshot.data!.body);
                if (users.isEmpty) return const Text('Нет участников');
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: WebCircleAvatar(imageUrl: user['avatar']),
                      title: Text(user['name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                      subtitle: Text(user['email'], style: GoogleFonts.montserrat(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRegistration(int.parse(eventId.toString()), int.parse(user['id'].toString())),
                      ),
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
            child: Text('ЗАКРЫТЬ', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddEventSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Создать мероприятие', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _pickEventImage().then((_) => _showAddEventSheet());
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: evImageUrl != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: WebImage(evImageUrl!, fit: BoxFit.cover))
                      : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(controller: evTitleCtrl, decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: evDescrCtrl, decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()), maxLines: 3),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: evDateCtrl, decoration: const InputDecoration(labelText: 'Дата', border: OutlineInputBorder()))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: evTimeCtrl, decoration: const InputDecoration(labelText: 'Время', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: evLocCtrl, decoration: const InputDecoration(labelText: 'Место', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: _createEvent,
                  child: const Text('СОЗДАТЬ'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddVacancySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Создать вакансию', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: vacTitleCtrl, decoration: const InputDecoration(labelText: 'Должность', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: vacCompCtrl, decoration: const InputDecoration(labelText: 'Компания', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: vacSalCtrl, decoration: const InputDecoration(labelText: 'Зарплата', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: vacDescrCtrl, decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()), maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: _createVacancy,
                  child: const Text('СОЗДАТЬ'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNewsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Создать новость', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _pickNewsImage().then((_) => _showAddNewsSheet());
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: newsImageUrl != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: WebImage(newsImageUrl!, fit: BoxFit.cover))
                      : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Заголовок', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: descrCtrl, decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()), maxLines: 5),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: _createNews,
                  child: const Text('СОЗДАТЬ'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showSendNotificationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Отправить уведомление', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: notifTitleCtrl, decoration: const InputDecoration(labelText: 'Заголовок', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: notifMsgCtrl, decoration: const InputDecoration(labelText: 'Сообщение', border: OutlineInputBorder()), maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: _sendNotification,
                  child: const Text('ОТПРАВИТЬ'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddStartupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Создать стартап', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _pickStartupImage().then((_) => _showAddStartupSheet());
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: startupImageUrl != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: WebImage(startupImageUrl!, fit: BoxFit.cover))
                      : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(controller: startupNameCtrl, decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: startupDescrCtrl, decoration: const InputDecoration(labelText: 'Краткое описание', border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: 12),
              TextField(controller: startupFullDescrCtrl, decoration: const InputDecoration(labelText: 'Полное описание', border: OutlineInputBorder()), maxLines: 5),
              const SizedBox(height: 12),
              TextField(controller: startupFounderCtrl, decoration: const InputDecoration(labelText: 'Основатель', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: startupStageCtrl, decoration: const InputDecoration(labelText: 'Стадия (Идея, MVP, Рост)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: startupTeamSizeCtrl, decoration: const InputDecoration(labelText: 'Размер команды', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: startupFundingCtrl, decoration: const InputDecoration(labelText: 'Финансирование', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: startupWebsiteCtrl, decoration: const InputDecoration(labelText: 'Веб-сайт', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: startupEmailCtrl, decoration: const InputDecoration(labelText: 'Email для связи', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: _createStartup,
                  child: const Text('СОЗДАТЬ'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
        title: Text('Админ панель', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: tabCtrl,
          isScrollable: true,
          labelColor: Colors.black,
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Пользователи'),
            Tab(text: 'Новости'),
            Tab(text: 'Мероприятия'),
            Tab(text: 'Вакансии'),
            Tab(text: 'Стартапы'),
            Tab(text: 'Уведомления'),
            Tab(text: 'HUB QR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabCtrl,
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: usersList.length,
                  itemBuilder: (context, index) {
                    final user = usersList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: WebCircleAvatar(
                          imageUrl: user['avatar'],
                          child: user['avatar'] == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(user['name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                        subtitle: Text('${user['email']}\nРоль: ${user['role']}', style: GoogleFonts.montserrat(fontSize: 12)),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
          Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: _showAddNewsSheet,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final item = newsList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: item['image'] != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(4), child: WebImage(item['image'], width: 50, height: 50, fit: BoxFit.cover))
                        : const Icon(Icons.article),
                    title: Text(item['title'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['descr'], maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNews(int.parse(item['id'].toString())),
                    ),
                  ),
                );
              },
            ),
          ),
          Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: _showAddEventSheet,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: eventsList.isEmpty 
                ? const Center(child: Text('Нет мероприятий'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: eventsList.length,
              itemBuilder: (context, index) {
                final item = eventsList[index];
                
                String? imageUrl = item['image'];
                if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                  imageUrl = '${Cfg.url}$imageUrl';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showRegistrations(item['id']),
                    leading: imageUrl != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(4), child: WebImage(imageUrl, width: 50, height: 50, fit: BoxFit.cover))
                        : const Icon(Icons.event),
                    title: Text(item['title'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['date']} ${item['time']}\n${item['location']}\nРегистраций: ${item['registration_count'] ?? 0}', style: GoogleFonts.montserrat(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEvent(int.parse(item['id'].toString())),
                    ),
                  ),
                );
              },
            ),
          ),
          Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: _showAddVacancySheet,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vacList.length,
              itemBuilder: (context, index) {
                final item = vacList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showVacancyResponses(item['id']),
                    title: Text(item['title'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['company']} | ${item['salary']}', style: GoogleFonts.montserrat(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteVacancy(int.parse(item['id'].toString())),
                    ),
                  ),
                );
              },
            ),
          ),
          Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: _showAddStartupSheet,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: startupsList.length,
              itemBuilder: (context, index) {
                final item = startupsList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: item['image'] != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(4), child: WebImage(item['image'], width: 50, height: 50, fit: BoxFit.cover))
                        : const Icon(Icons.rocket_launch),
                    title: Text(item['name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['description'], maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteStartup(int.parse(item['id'].toString())),
                    ),
                  ),
                );
              },
            ),
          ),
          Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: _showSendNotificationSheet,
              child: const Icon(Icons.send, color: Colors.white),
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifList.length,
              itemBuilder: (context, index) {
                final item = notifList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(item['title'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['message'], maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNotification(int.parse(item['id'].toString())),
                    ),
                  ),
                );
              },
            ),
          ),
          const AdminQRScreen(),
        ],
      ),
    );
  }
}
