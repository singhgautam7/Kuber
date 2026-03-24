import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/services/data_service.dart';

enum DataOpStatus { initial, loading, success, error }

class DataState {
  final DataOpStatus status;
  final String? message;
  final int? successCount;
  final int? failureCount;

  DataState({
    this.status = DataOpStatus.initial,
    this.message,
    this.successCount,
    this.failureCount,
  });

  DataState copyWith({
    DataOpStatus? status,
    String? message,
    int? successCount,
    int? failureCount,
  }) {
    return DataState(
      status: status ?? this.status,
      message: message, // Allow nulling out
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
    );
  }
}

final dataServiceProvider = Provider<DataService>((ref) {
  final isar = ref.watch(isarProvider);
  return DataService(isar);
});

final dataControllerProvider = StateNotifierProvider<DataController, DataState>((ref) {
  final service = ref.watch(dataServiceProvider);
  return DataController(service);
});

class DataController extends StateNotifier<DataState> {
  final DataService _service;

  DataController(this._service) : super(DataState());

  Future<void> exportData() async {
    state = state.copyWith(status: DataOpStatus.loading);
    try {
      await _service.exportData();
      state = state.copyWith(status: DataOpStatus.success, message: 'Data exported successfully');
    } catch (e) {
      state = state.copyWith(status: DataOpStatus.error, message: 'Export failed: $e');
    }
  }

  Future<void> downloadTemplate() async {
    state = state.copyWith(status: DataOpStatus.loading);
    try {
      await _service.downloadTemplate();
      state = state.copyWith(status: DataOpStatus.success, message: 'Template downloaded successfully');
    } catch (e) {
      state = state.copyWith(status: DataOpStatus.error, message: 'Download failed: $e');
    }
  }

  Future<void> importData() async {
    state = state.copyWith(status: DataOpStatus.loading);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        state = state.copyWith(status: DataOpStatus.initial);
        return;
      }

      final file = File(result.files.first.path!);
      final csvContent = await file.readAsString();
      
      final importResult = await _service.importData(csvContent);

      if (importResult.error != null) {
        state = state.copyWith(status: DataOpStatus.error, message: importResult.error);
      } else {
        state = state.copyWith(
          status: DataOpStatus.success,
          message: 'Import completed',
          successCount: importResult.successCount,
          failureCount: importResult.failureCount,
        );
      }
    } catch (e) {
      state = state.copyWith(status: DataOpStatus.error, message: 'Import failed: $e');
    }
  }

  Future<void> generateMockData() async {
    state = state.copyWith(status: DataOpStatus.loading);
    try {
      await _service.generateMockData();
      state = state.copyWith(status: DataOpStatus.success, message: 'Mock data generated successfully');
    } catch (e) {
      state = state.copyWith(status: DataOpStatus.error, message: 'Generation failed: $e');
    }
  }

  Future<void> clearAllData() async {
    state = state.copyWith(status: DataOpStatus.loading);
    try {
      await _service.clearAllData();
      state = state.copyWith(status: DataOpStatus.success, message: 'All data cleared successfully');
    } catch (e) {
      state = state.copyWith(status: DataOpStatus.error, message: 'Clear failed: $e');
    }
  }

  void reset() {
    state = DataState();
  }
}
