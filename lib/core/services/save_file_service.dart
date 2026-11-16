import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../shared/widgets/timed_snackbar.dart';
import '../utils/l10n_ext.dart';

// Owned by B. The one way to save a file the user keeps: the system "Save to"
// picker (Storage Access Framework on Android, download on web), so no storage
// permission and no fixed public path.

enum SaveFileResult { saved, cancelled, failed }

/// Asks where to save [bytes] as [fileName]. Shows the friendly error snackbar
/// on failure; cancel is silent. Callers show their own success message.
Future<SaveFileResult> saveUserFile(
  BuildContext context, {
  required Uint8List bytes,
  required String fileName,
  required List<String> extensions,
  String? dialogTitle,
}) async {
  try {
    final path = await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    // Web returns null even after a successful download, so treat a null as
    // cancelled only off web.
    return path == null && !kIsWeb
        ? SaveFileResult.cancelled
        : SaveFileResult.saved;
  } catch (e) {
    debugPrint('saveUserFile failed: $e');
    if (context.mounted) {
      showKuberSnackBar(context, context.l10n.saveFileFailed, isError: true);
    }
    return SaveFileResult.failed;
  }
}
