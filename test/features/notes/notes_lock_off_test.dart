import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/services/biometric_service.dart';
import 'package:kuber/features/notes/providers/notes_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Bio extends BiometricService {
  final bool ok;
  _Bio(this.ok);
  @override
  Future<bool> authenticate() async => ok;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('turning the Notes lock off needs the check; on does not', () async {
    final n = NotesBiometricRequiredNotifier();
    expect(await n.setChecked(true, biometric: _Bio(false)), isTrue);
    expect(n.state, isTrue);
    expect(await n.setChecked(false, biometric: _Bio(false)), isFalse);
    expect(n.state, isTrue);
    expect(await n.setChecked(false, biometric: _Bio(true)), isTrue);
    expect(n.state, isFalse);
  });
}
