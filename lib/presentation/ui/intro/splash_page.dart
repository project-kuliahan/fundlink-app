import 'package:flutter/material.dart';
import 'package:fundlink_app/core/core.dart';
import 'package:fundlink_app/data/datasources/auth_local_datasource.dart';
import 'package:fundlink_app/presentation/ui/intro/login_page.dart';
import 'package:fundlink_app/presentation/ui/home/pages/main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _local = AuthLocalDatasource();
  String? _error;

  @override
  void initState() {
    super.initState();
    _authCheck();
  }

  Future<void> _authCheck() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final token = await _local.getToken();
      if (!mounted) return;
      if (token != null) {
        context.pushReplacement(const MainPage());
      } else {
        context.pushReplacement(const LoginPage());
      }
    } catch (e, stackTrace) {
      debugPrint('Auth Check Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'FundLink',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error: $_error',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Text(
          'FundLink',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
