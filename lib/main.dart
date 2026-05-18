import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fundlink_app/data/datasources/auth_local_datasource.dart';
import 'package:fundlink_app/data/datasources/auth_remote_datasource.dart';
import 'package:fundlink_app/data/repositories/auth_repository_impl.dart';
import 'package:fundlink_app/domain/usecases/login_usecase.dart';
import 'package:fundlink_app/presentation/bloc/app_settings_cubit.dart';
import 'package:fundlink_app/presentation/bloc/auth_bloc.dart';
import 'package:fundlink_app/presentation/bloc/dashboard_bloc.dart';
import 'package:fundlink_app/presentation/bloc/transaction_bloc.dart';
import 'package:fundlink_app/presentation/ui/intro/splash_page.dart';

void main() {
  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
    debugPrintStack(stackTrace: details.stack);
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppSettingsCubit()),
        BlocProvider(
          create: (_) => AuthBloc(
            LoginUseCase(AuthRepositoryImpl(AuthRemoteDatasource())),
            AuthLocalDatasource(),
            AuthRemoteDatasource(),
          ),
        ),
        BlocProvider(create: (_) => DashboardBloc()),
        BlocProvider(create: (_) => TransactionBloc()),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettings>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'FundLink',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff3660e0)),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff3660e0),
                brightness: Brightness.dark,
              ),
              brightness: Brightness.dark,
            ),
            themeMode: settings.themeMode,
            locale: settings.locale,
            home: const SplashPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
