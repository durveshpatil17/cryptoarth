import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/models/user_model.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';

// Since the AuthProvider already fetches the user's profile during login and initial auth check,
// we can expose the user's profile directly from the AuthProvider state.

final profileProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
