
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';

class AuthService {
  final AuthRepository _authRepository = AuthRepository();


  Future<void> logout() async {
    await _authRepository.logout();
  }
}
