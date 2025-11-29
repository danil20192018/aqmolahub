import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

class WebCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final Widget? child;
  final double? radius;
  final Color? backgroundColor;

  const WebCircleAvatar({
    super.key,
    this.imageUrl,
    this.child,
    this.radius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      final String viewId = 'web-avatar-${imageUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
      
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
        final div = web.document.createElement('div') as web.HTMLDivElement;
        final img = web.document.createElement('img') as web.HTMLImageElement;
        
        img.src = imageUrl!;
        img.style.width = '100%';
        img.style.height = '100%';
        img.style.objectFit = 'cover';
        img.style.borderRadius = '50%';
        
        div.style.width = '100%';
        div.style.height = '100%';
        div.style.borderRadius = '50%';
        div.style.overflow = 'hidden';
        div.appendChild(img);
        
        return div;
      });

      return SizedBox(
        width: radius != null ? radius! * 2 : 40,
        height: radius != null ? radius! * 2 : 40,
        child: ClipOval(
          child: HtmlElementView(viewType: viewId),
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: child,
      );
    }
  }
}
