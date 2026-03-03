import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tutorial_service.dart';

final aiTutorialDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(tutorialServiceProvider);
  return await service.fetchAiTutorials();
});

class TutorialAiNotifier extends StateNotifier<AsyncValue<void>> {
  final TutorialService _service;

  TutorialAiNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> generateTutorial(String type, String language) async {
    state = const AsyncValue.loading();
    try {
      await _service.generateAiTutorial({
        'demo_type': type,
        'language': language,
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final tutorialAiNotifierProvider = StateNotifierProvider<TutorialAiNotifier, AsyncValue<void>>((ref) {
  return TutorialAiNotifier(ref.read(tutorialServiceProvider));
});
