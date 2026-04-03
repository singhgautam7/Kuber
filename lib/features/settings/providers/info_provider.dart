import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final infoSeenProvider = AsyncNotifierProvider.family<InfoSeenNotifier, bool, String>(
  InfoSeenNotifier.new,
);

class InfoSeenNotifier extends FamilyAsyncNotifier<bool, String> {
  @override
  Future<bool> build(String arg) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(arg) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(arg, true);
    state = const AsyncData(true);
  }
}
