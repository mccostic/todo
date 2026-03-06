import 'package:flutter/foundation.dart';

class DatabaseService{
  static DatabaseService? _instance;

  DatabaseService._internal();

  factory DatabaseService(){
    _instance ??= DatabaseService._internal();
    return _instance!;
  }
}

void main(){
  final db1 = DatabaseService();
  final db2 = DatabaseService();
  debugPrint('${identical(db1, db2)}');
}