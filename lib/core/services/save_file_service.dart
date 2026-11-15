import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

// Owned by B. The one way to save a file the user keeps: the system "Save to"
// picker (Storage Access Framework on Android), so no storage permission and
// no fixed public path.

enum SaveFileResult { saved, cancelled, failed }

/// Asks where to save [bytes] as [fileName]. Shows the friendly error snackbar
/// on failure (B adds it); returns the outcome so callers can show success.
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
    return path == null ? SaveFileResult.cancelled : SaveFileResult.saved;
  } catch (_) {
    return SaveFileResult.failed;
  }
}
