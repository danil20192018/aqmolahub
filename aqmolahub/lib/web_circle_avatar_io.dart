import 'package:flutter/material.dart';

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
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: child,
    );
  }
}
