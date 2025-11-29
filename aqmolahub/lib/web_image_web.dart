import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

class WebImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const WebImage(this.url, {super.key, this.width, this.height, this.fit});

  @override
  Widget build(BuildContext context) {
    final String viewId = 'web-image-${url.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final img = web.document.createElement('img') as web.HTMLImageElement;
      img.src = url;
      img.style.width = '100%';
      img.style.height = '100%';
      
      String objectFit = 'cover';
      if (fit == BoxFit.contain) objectFit = 'contain';
      if (fit == BoxFit.fill) objectFit = 'fill';
      if (fit == BoxFit.fitWidth) objectFit = 'cover';
      if (fit == BoxFit.fitHeight) objectFit = 'cover';
      if (fit == BoxFit.none) objectFit = 'none';
      if (fit == BoxFit.scaleDown) objectFit = 'scale-down';
      
      img.style.objectFit = objectFit;
      img.style.border = 'none';
      return img;
    });

    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewId),
    );
  }
}
