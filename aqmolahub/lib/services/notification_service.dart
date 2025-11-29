import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Timer? _timer;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream => _controller.stream;

  Future<void> init() async {
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkNotifications();
    });
  }

  Future<void> _checkNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      
      if (!notificationsEnabled) return;

      final response = await http.get(Uri.parse('${Cfg.url}notifications.php?act=list'));
      if (response.statusCode == 200) {
        final List notifications = jsonDecode(response.body);
        if (notifications.isEmpty) return;

        final lastId = prefs.getInt('last_notification_id') ?? 0;
        final latest = notifications.first;
        final latestId = int.parse(latest['id'].toString());

        if (latestId > lastId) {
          _controller.add(latest); 
          await prefs.setInt('last_notification_id', latestId);
        }
      }
    } catch (e) {
     
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
