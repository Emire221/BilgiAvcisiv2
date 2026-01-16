import 'package:sqflite/sqflite.dart';
import '../../domain/entities/mascot.dart';
import '../../domain/repositories/mascot_repository.dart';
import '../../../../services/database_helper.dart';

class MascotRepositoryImpl implements MascotRepository {
  final DatabaseHelper _dbHelper;

  MascotRepositoryImpl(this._dbHelper);

  @override
  Future<Mascot?> getUserMascot() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'UserPets',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Mascot.fromMap(maps.first);
  }

  @override
  Future<void> createMascot(Mascot mascot) async {
    final db = await _dbHelper.database;
    final mascotMap = Map<String, dynamic>.from(mascot.toMap());
    
    await db.insert(
      'UserPets',
      mascotMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateMascot(Mascot mascot) async {
    final db = await _dbHelper.database;
    await db.update(
      'UserPets',
      mascot.toMap(),
      where: 'id = ?',
      whereArgs: [mascot.id],
    );
  }

  @override
  Future<Mascot> addXp(int amount) async {
    final mascot = await getUserMascot();
    if (mascot == null) {
      throw Exception('Maskot bulunamadı');
    }

    final newXp = mascot.currentXp + amount;
    final updatedMascot = mascot.copyWith(currentXp: newXp);

    await updateMascot(updatedMascot);
    return updatedMascot;
  }

  @override
  Future<void> updateMood(int mood) async {
    final mascot = await getUserMascot();
    if (mascot == null) return;

    final updatedMascot = mascot.copyWith(mood: mood.clamp(0, 100));
    await updateMascot(updatedMascot);
  }

  @override
  Future<bool> hasMascot() async {
    final mascot = await getUserMascot();
    return mascot != null;
  }
}
