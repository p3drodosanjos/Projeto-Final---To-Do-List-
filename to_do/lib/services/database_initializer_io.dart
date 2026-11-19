import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeSqliteFactory() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
