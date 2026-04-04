import 'package:isar_community/isar.dart';

abstract class BaseRepository<T> {
  final Isar isar;
  BaseRepository(this.isar);
}
