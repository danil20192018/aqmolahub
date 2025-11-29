import 'package:flutter/material.dart';

class WebImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const WebImage(this.url, {super.key, this.width, this.height, this.fit});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}
