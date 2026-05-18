import 'package:fundlink_app/domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    return remoteDatasource.login(email, password);
  }
}
