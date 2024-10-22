import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'aquarium.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE settings(id INTEGER PRIMARY KEY, fishCount INTEGER, speed REAL, color INTEGER)",
        );
      },
      version: 1,
    );
  }

  static Future<void> saveConfig(int fishCount, double speed, int color) async {
    final db = await getDatabase();
    await db.insert(
      'settings',
      {'id': 1, 'fishCount': fishCount, 'speed': speed, 'color': color},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>> loadConfig() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> records = await db.query('settings', where: 'id = ?', whereArgs: [1]);

    if (records.isNotEmpty) {
      return records.first;
    } else {
      return {
        'fishCount': 0,
        'speed': 1.0,
        'color': 0xFF00FFFF
      }; 
    }
  }
}
