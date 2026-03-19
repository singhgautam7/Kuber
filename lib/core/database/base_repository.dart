import 'package:isar/isar.dart';

abstract class BaseRepository<T> {
  final Isar isar;
  BaseRepository(this.isar);
}
