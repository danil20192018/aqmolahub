import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../widgets/animated_background.dart';
import 'event_detail_screen.dart';
import '../web_image.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('${Cfg.url}events.php?act=list'));
      if (response.statusCode == 200) {
        setState(() {
          events = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        _loadMockData();
      }
    } catch (e) {
      _loadMockData();
    }
  }

  void _loadMockData() {
    setState(() {
      events = [
        {
          'title': 'PIIZA PITCH',
          'date': '25 МАЯ',
          'time': '14:00',
          'location': 'Aqmola Hub, 6 ЭТАЖ АК ЖЕЛКЕН',
          'image': '',
        },
        {
          'title': 'HACKATHON: AI & WEB',
          'date': '10 ИЮНЯ',
          'time': '09:00',
          'location': 'Aqmola Hub, 6 ЭТАЖ АК ЖЕЛКЕН',
          'image': '',
        },
        {
          'title': 'ВСТРЕЧА С ИНВЕСТОРАМИ',
          'date': '15 ИЮНЯ',
          'time': '18:30',
          'location': 'Aqmola Hub, 6 ЭТАЖ АК ЖЕЛКЕН-зал',
          'image': '',
        },
      ];
      isLoading = false;
    });
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
          'МЕРОПРИЯТИЯ',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final item = events[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['image'] != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10.5)),
                            child: WebImage(
                              item['image'],
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item['date'] ?? '',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item['time'] ?? '',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                item['title'].toString().toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 18, color: Colors.black),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item['location'] ?? 'Aqmola Hub',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(color: Colors.black, width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: item)));
                                  },
                                  child: Text(
                                    'ПОДРОБНЕЕ',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
