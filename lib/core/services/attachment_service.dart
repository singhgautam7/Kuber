import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AttachmentException implements Exception {
  final String message;
  AttachmentException(this.message);

  @override
  String toString() => message;
}

class AttachmentService {
  static const int maxAttachments = 5;
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  Future<Directory> _attachmentDir(int transactionId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(
        p.join(appDir.path, 'kuber_attachments', transactionId.toString()));
  }

  /// Save a file as an attachment for a transaction.
  /// Returns the absolute path of the saved file.
  Future<String> saveAttachment(
    int transactionId,
    String sourcePath,
    int currentCount,
  ) async {
    if (currentCount >= maxAttachments) {
      throw AttachmentException(
          'Maximum $maxAttachments attachments allowed per transaction');
    }

    final sourceFile = File(sourcePath);
    final fileSize = await sourceFile.length();
    if (fileSize > maxFileSizeBytes) {
      throw AttachmentException('File size exceeds 5MB limit');
    }

    final dir = await _attachmentDir(transactionId);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = '${timestamp}_${p.basename(sourcePath)}';
    final destPath = p.join(dir.path, filename);

    await sourceFile.copy(destPath);
    return destPath;
  }

  /// Delete a single attachment file by its absolute path.
  Future<void> deleteAttachment(String absolutePath) async {
    final file = File(absolutePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Delete all attachment files for a transaction.
  Future<void> deleteAllForTransaction(int transactionId) async {
    final dir = await _attachmentDir(transactionId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Return 'image' or 'pdf' based on file extension.
  static String getFileType(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext == '.pdf') return 'pdf';
    return 'image';
  }
}

final attachmentServiceProvider = Provider<AttachmentService>((ref) {
  return AttachmentService();
});
