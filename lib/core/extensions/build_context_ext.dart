import 'package:flutter/material.dart';

extension NavigatorExt on BuildContext {
  Future<T?> push<T extends Object?>(Widget pageWidget) async =>
      Navigator.push<T>(
        this,
        MaterialPageRoute(builder: (_) => pageWidget),
      );

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Widget pageWidget,
  ) async => Navigator.pushReplacement<T, TO>(
    this,
    MaterialPageRoute(builder: (_) => pageWidget),
  );
}
