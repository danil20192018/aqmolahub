import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    for (int i = 0; i < 15; i++) {
      _bubbles.add(Bubble(_rnd));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: BubblePainter(_bubbles, _controller.value),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class Bubble {
  late double x;
  late double y;
  late double radius;
  late double speed;
  late double theta;

  Bubble(Random rnd) {
    reset(rnd);
  }

  void reset(Random rnd) {
    x = rnd.nextDouble();
    y = rnd.nextDouble();
    radius = rnd.nextDouble() * 30 + 10;
    speed = rnd.nextDouble() * 0.001 + 0.0005;
    theta = rnd.nextDouble() * 2 * pi;
  }

  void update() {
    x += speed * cos(theta);
    y += speed * sin(theta);

    if (x < -0.1 || x > 1.1 || y < -0.1 || y > 1.1) {
      x = (x + 1.2) % 1.2 - 0.1;
      y = (y + 1.2) % 1.2 - 0.1;
    }
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double animationValue;

  BubblePainter(this.bubbles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      bubble.update();
      canvas.drawCircle(
        Offset(bubble.x * size.width, bubble.y * size.height),
        bubble.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
