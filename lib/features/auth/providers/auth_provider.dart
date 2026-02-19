import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/features/auth/repositories/auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRepository(apiClient);
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<Map<String, dynamic>?>>(
        (ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final result = await repository.login(
        email: email,
        password: password,
      );

      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
