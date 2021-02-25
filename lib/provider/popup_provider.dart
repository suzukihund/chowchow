import 'package:hooks_riverpod/all.dart';

final StateNotifierProvider<PopupNotifier> popupProvider =
    StateNotifierProvider<PopupNotifier>((_) => PopupNotifier());

class PopupNotifier extends StateNotifier<String> {
  PopupNotifier() : super(null);

  void showSnackBar(String message) {
    state = message;
  }

  void hideSnackBar() {
    state = null;
  }
}
