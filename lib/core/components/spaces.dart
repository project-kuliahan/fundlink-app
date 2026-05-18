import 'package:flutter/material.dart';

class SpaceHeight extends StatelessWidget {
  final double? height;
  const SpaceHeight({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height ?? 0);
  }
}

class SpaceWidth extends StatelessWidget {
  final double? width;
  const SpaceWidth({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width ?? 0);
  }
}
