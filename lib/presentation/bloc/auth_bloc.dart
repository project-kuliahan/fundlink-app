import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fundlink_app/data/datasources/auth_local_datasource.dart';
import 'package:fundlink_app/data/datasources/auth_remote_datasource.dart';
import 'package:fundlink_app/data/models/user_model.dart';
import 'package:fundlink_app/domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final AuthLocalDatasource authLocalDatasource;
  final AuthRemoteDatasource authRemoteDatasource;

  AuthBloc(
    this.loginUseCase,
    this.authLocalDatasource,
    this.authRemoteDatasource,
  ) : super(AuthInitial()) {
    on<CheckAuthEvent>((event, emit) async {
      final token = await authLocalDatasource.getToken();
      if (token == null || token.isEmpty) return;
      try {
        // Always fetch fresh user data from server
        final user = await authRemoteDatasource.getMe();
        await authLocalDatasource.saveUser(user.toJson());
        emit(AuthSuccess(user, token));
      } catch (_) {
        // Fallback to cached data if network fails
        final userJson = await authLocalDatasource.getUser();
        if (userJson != null) {
          emit(AuthSuccess(UserModel.fromJson(userJson), token));
        }
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await loginUseCase(event.email, event.password);
        await authLocalDatasource.saveToken(result['token']);
        await authLocalDatasource.saveUser(
          (result['user'] as dynamic).toJson(),
        );
        emit(AuthSuccess(result['user'], result['token']));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRemoteDatasource.logout();
      } catch (_) {}
      await authLocalDatasource.clearAll();
      emit(AuthLogout());
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authRemoteDatasource.register(
          event.name,
          event.email,
          event.password,
        );
        await authLocalDatasource.saveToken(result['token']);
        await authLocalDatasource.saveUser(
          (result['user'] as dynamic).toJson(),
        );
        emit(RegisterSuccess(result['user'], result['token']));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
