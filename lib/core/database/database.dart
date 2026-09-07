import 'package:athletes_mindful_companion/core/models/session.dart';
import 'package:athletes_mindful_companion/core/models/user_settings.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// Database service for Isar
class DatabaseService {
  static Isar? _isar;

  /// Initialize the database
  static Future<Isar> initialize() async {
    if (_isar != null) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      schemas: [
        SessionSchema,
        KeyMomentSchema,
        MentalTrendSchema,
        UserSettingsSchema,
      ],
      directory: dir.path,
      inspector: true,
    );

    return _isar!;
  }

  /// Get the database instance
  static Isar get instance {
    if (_isar == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  /// Close the database
  static Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
    }
  }
}