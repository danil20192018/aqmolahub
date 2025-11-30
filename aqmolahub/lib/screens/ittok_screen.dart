import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class IttokScreen extends StatefulWidget {
  const IttokScreen({super.key});

  @override
  State<IttokScreen> createState() => _IttokScreenState();
}

class _IttokScreenState extends State<IttokScreen> {
  List vids = [];
  bool load = false;
  int offset = 0;
  final PageController _pg = PageController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => load = true);
    try {
      final res = await http.get(Uri.parse('${Cfg.url}ittok.php?act=list&offset=$offset'));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        setState(() {
          vids.addAll(d['data']);
          offset += 10;
        });
      }
    } catch (e) {}
    setState(() => load = false);
  }

  Future<void> _upload() async {
    final src = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Выбери источник', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text('Камера', style: GoogleFonts.montserrat()),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: Text('Галерея', style: GoogleFonts.montserrat()),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    
    if (src == null) return;

    final picker = ImagePicker();
    final vid = await picker.pickVideo(source: src);
    if (vid == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final bytes = await vid.readAsBytes();
      final req = http.MultipartRequest('POST', Uri.parse('${Cfg.url}upload_video.php'));
      req.files.add(http.MultipartFile.fromBytes('video', bytes, filename: 'video.mp4'));
      
      final resp = await req.send();
      final body = await resp.stream.bytesToString();
      final data = jsonDecode(body);

      if (data['res'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final uid = prefs.getInt('user_id');
        
        await http.post(
          Uri.parse('${Cfg.url}ittok.php?act=upload'),
          body: jsonEncode({
            'user_id': uid,
            'title': 'Новое видео',
            'description': '',
            'video_url': data['url'],
          }),
        );
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Видео загружено!')),
        );
        vids.clear();
        offset = 0;
        _fetch();
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['err'] ?? 'Ошибка загрузки')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'АЙТТОК',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
            onPressed: _upload,
          ),
        ],
      ),
      body: load && vids.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : PageView.builder(
              controller: _pg,
              scrollDirection: Axis.vertical,
              itemCount: vids.length,
              onPageChanged: (idx) {
                if (idx == vids.length - 2) _fetch();
              },
              itemBuilder: (ctx, idx) => VideoCard(video: vids[idx]),
            ),
    );
  }
}

class VideoCard extends StatefulWidget {
  final Map video;
  const VideoCard({super.key, required this.video});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController? _ctrl;
  bool liked = false;
  int likes = 0;

  @override
  void initState() {
    super.initState();
    likes = int.parse(widget.video['likes_count'].toString());
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.video['video_url']));
    await _ctrl!.initialize();
    _ctrl!.setLooping(true);
    _ctrl!.play();
    setState(() {});
    
    await http.post(
      Uri.parse('${Cfg.url}ittok.php?act=view'),
      body: jsonEncode({'video_id': widget.video['id']}),
    );
  }

  Future<void> _like() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('user_id');
    
    try {
      final res = await http.post(
        Uri.parse('${Cfg.url}ittok.php?act=like'),
        body: jsonEncode({'user_id': uid, 'video_id': widget.video['id']}),
      );
      final d = jsonDecode(res.body);
      setState(() {
        liked = d['action'] == 'liked';
        likes += liked ? 1 : -1;
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_ctrl != null && _ctrl!.value.isInitialized)
          GestureDetector(
            onTap: () {
              setState(() {
                _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play();
              });
            },
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _ctrl!.value.size.width,
                height: _ctrl!.value.size.height,
                child: VideoPlayer(_ctrl!),
              ),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              IconButton(
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : Colors.white,
                  size: 32,
                ),
                onPressed: _like,
              ),
              Text(
                '$likes',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              IconButton(
                icon: const Icon(Icons.remove_red_eye, color: Colors.white, size: 32),
                onPressed: () {},
              ),
              Text(
                '${widget.video['views']}',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        Positioned(
          left: 16,
          bottom: 80,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Text(
                      widget.video['author_name'][0].toUpperCase(),
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.video['author_name'],
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (widget.video['title'] != null && widget.video['title'].toString().isNotEmpty)
                Text(
                  widget.video['title'],
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
