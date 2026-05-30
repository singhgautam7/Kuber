import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class SafBackupStore {
  static const _channel = MethodChannel('com.grs.kuber/saf_backups');

  Future<String?> pickFolder() async {
    if (Platform.isAndroid) {
      return _channel.invokeMethod<String>('pickFolder');
    }
    return FilePicker.getDirectoryPath();
  }

  Future<void> writeText({
    required String folderUri,
    required String fileName,
    required String contents,
  }) async {
    if (Platform.isAndroid && folderUri.startsWith('content://')) {
      await _channel.invokeMethod<void>('writeText', {
        'folderUri': folderUri,
        'fileName': fileName,
        'contents': contents,
      });
      return;
    }
    final file = File(p.join(folderUri, fileName));
    await file.writeAsString(contents);
  }

  Future<List<String>> listFileNames(String folderUri) async {
    if (Platform.isAndroid && folderUri.startsWith('content://')) {
      final names = await _channel.invokeListMethod<String>(
        'listFileNames',
        folderUri,
      );
      return names ?? const [];
    }
    final dir = Directory(folderUri);
    if (!await dir.exists()) return const [];
    return dir
        .list()
        .where((entity) => entity is File)
        .map((entity) => p.basename(entity.path))
        .toList();
  }

  Future<void> deleteFile({
    required String folderUri,
    required String fileName,
  }) async {
    if (Platform.isAndroid && folderUri.startsWith('content://')) {
      await _channel.invokeMethod<void>('deleteFile', {
        'folderUri': folderUri,
        'fileName': fileName,
      });
      return;
    }
    final file = File(p.join(folderUri, fileName));
    if (await file.exists()) await file.delete();
  }
}
