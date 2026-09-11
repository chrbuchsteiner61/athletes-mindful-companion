import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class JsonStore {
  JsonStore();

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    final storeDir = Directory(p.join(dir.path, 'amc_store'));
    if (!storeDir.existsSync()) {
      await storeDir.create(recursive: true);
    }
    return File(p.join(storeDir.path, 'store.json'));
  }

  Future<Map<String, dynamic>> _readRoot() async {
    final f = await _file();
    if (!f.existsSync()) return {};
    try {
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) return {};
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeRoot(Map<String, dynamic> root) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(root));
  }

  Future<List<Map<String, dynamic>>> readList(String key) async {
    final root = await _readRoot();
    final v = root[key];
    if (v is List) return v.cast<Map<String, dynamic>>();
    return [];
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> rows) async {
    final root = await _readRoot();
    root[key] = rows;
    await _writeRoot(root);
  }

  Future<String?> readString(String key) async {
    final root = await _readRoot();
    final v = root[key];
    return v is String ? v : null;
  }

  Future<void> writeString(String key, String value) async {
    final root = await _readRoot();
    root[key] = value;
    await _writeRoot(root);
  }

  Future<void> clear() async {
    final f = await _file();
    if (f.existsSync()) await f.delete();
  }
}
