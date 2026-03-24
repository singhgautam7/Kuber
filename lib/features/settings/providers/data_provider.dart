import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/services/data_service.dart';
import '../../../core/services/notification_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../recurring/providers/recurring_provider.dart';

enum DataOpStatus { initial, loading, success, error }

class DataState {
  final DataOpStatus status;
  final String? message;
  final int? successCount;
  final int? failureCount;
  final String? filePath; // Main file for "Open"
  final List<String>? filePaths; // All files for "Share"
  final String? loadingMessage;

  DataState({
    this.status = DataOpStatus.initial,
    this.message,
    this.successCount,
    this.failureCount,
    this.filePath,
    this.filePaths,
    this.loadingMessage,
  });

  DataState copyWith({
    DataOpStatus? status,
    String? message,
    int? successCount,
    int? failureCount,
    String? filePath,
    List<String>? filePaths,
    String? loadingMessage,
  }) {
    return DataState(
      status: status ?? this.status,
      message: message, // Allow nulling out
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      filePath: filePath ?? this.filePath,
      filePaths: filePaths ?? this.filePaths,
      loadingMessage: loadingMessage ?? this.loadingMessage,
    );
  }
}

final dataServiceProvider = Provider<DataService>((ref) {
  final isar = ref.watch(isarProvider);
  return DataService(isar);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final dataControllerProvider = StateNotifierProvider<DataController, DataState>((ref) {
  final service = ref.watch(dataServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return DataController(service, notificationService, ref);
});

class DataController extends StateNotifier<DataState> {
  final DataService _service;
  final NotificationService _notificationService;
  final Ref _ref;

  static const notificationId = 1001;
  DataController(this._service, this._notificationService, this._ref) : super(DataState());

  Future<void> exportData() async {
    state = state.copyWith(status: DataOpStatus.loading, filePath: null);
    
    try {
      await _notificationService.init();
      await _notificationService.requestPermission();
      
      // Non-awaited to avoid blocking the main flow
      _notificationService.showExportNotification(
        id: notificationId,
        title: 'Exporting data...',
        body: 'Preparing your file',
        isProgress: true,
      );

      final exports = await _service.exportData();
      final entry = exports.entries.first;
      final timestamp = DateFormat('yyyy_MM_dd_HHmm').format(DateTime.now());
      final fileName = 'kuber_backup_$timestamp.csv';
      
      final path = await _saveFile(entry.value, fileName);
      
      if (path != null) {
        state = state.copyWith(
          status: DataOpStatus.success,
          message: 'Data exported successfully',
          filePath: path,
          filePaths: [path],
        );

        _notificationService.showExportNotification(
          id: notificationId,
          title: 'Export Complete',
          body: 'Saved to Downloads/$fileName',
          isSuccess: true,
          payload: path,
        );
      }
    } catch (e) {
      state = state.copyWith(status: DataOpStatus.error, message: 'Export failed: $e');
      
      _notificationService.showExportNotification(
        id: notificationId,
        title: 'Export Failed',
        body: e.toString(),
      );
    }
  }

  Future<String?> _saveFile(String content, String fileName) async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        try {
          await directory.create(recursive: true);
        } catch (_) {}
      }
    } else {
      directory = await getDownloadsDirectory();
    }
    
    directory ??= await getExternalStorageDirectory();
    directory ??= await getApplicationDocumentsDirectory();
    
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  Future<void> downloadTemplate() async {
    state = state.copyWith(status: DataOpStatus.loading, filePath: null);
    
    await _notificationService.init();
    await _notificationService.requestPermission();
    
    const notificationId = 1002;
    await _notificationService.showExportNotification(
      id: notificationId,
      title: 'Downloading template...',
      body: 'Preparing CSV template',
      isProgress: true,
    );

    try {
      final path = await _service.downloadTemplate();
      state = state.copyWith(status: DataOpStatus.success, message: 'Template downloaded successfully', filePath: path);
      
      final fileName = path?.split('/').last ?? 'template.csv';
      await _notificationService.showExportNotification(
        id: notificationId,
        title: 'Download Complete',
        body: 'Saved to Downloads/$fileName',
        isSuccess: true,
        payload: path,
      );
    } catch (e) {
      state = state.copyWith(status: DataOpStatus.error, message: 'Download failed: $e');
      await _notificationService.showExportNotification(
        id: notificationId,
        title: 'Download Failed',
        body: e.toString(),
      );
    }
  }

  Future<void> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      state = state.copyWith(
        status: DataOpStatus.loading,
        loadingMessage: 'Importing data...',
      );

      int totalSuccess = 0;
      int totalFailure = 0;

      for (final fileData in result.files) {
        final file = File(fileData.path!);
        final csvContent = await file.readAsString();
        final importResult = await _service.importData(csvContent);
        
        if (importResult.error != null) {
           // Skip or handle individual file error
        } else {
          totalSuccess += importResult.successCount;
          totalFailure += importResult.failureCount;
        }
      }

      _refreshData();
      final msg = totalFailure > 0 
        ? 'Imported $totalSuccess records, $totalFailure failed'
        : 'Imported $totalSuccess records successfully';
        
      state = state.copyWith(
        status: DataOpStatus.success,
        message: msg,
        successCount: totalSuccess,
        failureCount: totalFailure,
      );
    } catch (e) {
      state = state.copyWith(status: DataOpStatus.error, message: 'Import failed: $e');
    }
  }

  Future<void> generateMockData() async {
    state = state.copyWith(
      status: DataOpStatus.loading,
      loadingMessage: 'Generating mock data...',
    );
    try {
      await _service.generateMockData();
      _refreshData();
      state = state.copyWith(status: DataOpStatus.success, message: 'Mock data generated successfully');
    } catch (e) {
      state = state.copyWith(status: DataOpStatus.error, message: 'Generation failed: $e');
    }
  }

  Future<void> clearAllData() async {
    state = state.copyWith(
      status: DataOpStatus.loading,
      loadingMessage: 'Clearing all data...',
    );
    try {
      await _service.clearAllData();
      _refreshData();
      state = state.copyWith(status: DataOpStatus.success, message: 'All data cleared successfully');
    } catch (e) {
      state = state.copyWith(status: DataOpStatus.error, message: 'Clear failed: $e');
    }
  }

  void _refreshData() {
    _ref.invalidate(transactionListProvider);
    _ref.invalidate(accountListProvider);
    _ref.invalidate(categoryListProvider);
    _ref.invalidate(recurringListProvider);
    // These derived providers will automatically update because they watch transactionListProvider
  }

  void reset() {
    state = DataState();
  }
}
