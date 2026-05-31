
/// Converts a raw SAF tree URI into a human-readable folder path.
///
/// SAF URIs look like:
///   content://com.android.externalstorage.documents/tree/primary%3ADownloads%2FKuber
///
/// This extracts the path portion after the volume prefix and displays it
/// as "Downloads / Kuber". Falls back to the last path segment if parsing
/// fails for any reason.
String formatBackupFolderUri(String? uri) {
  if (uri == null || uri.isEmpty) return 'Not selected';
  try {
    final decoded = Uri.decodeFull(uri);
    final treeIndex = decoded.indexOf('/tree/');
    if (treeIndex == -1) return _lastSegment(decoded);
    final treePath = decoded.substring(treeIndex + 6);
    final colonIndex = treePath.indexOf(':');
    if (colonIndex == -1) return _lastSegment(treePath);
    final path = treePath.substring(colonIndex + 1);
    if (path.isEmpty) return _lastSegment(decoded);
    return path.replaceAll('/', ' / ');
  } catch (_) {
    return _lastSegment(uri);
  }
}

String _lastSegment(String path) {
  final parts = path.split('/').where((p) => p.isNotEmpty).toList();
  return parts.isEmpty ? 'Unknown folder' : Uri.decodeFull(parts.last);
}
