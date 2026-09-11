import 'package:record/record.dart';

class SpeechToTextService {
  SpeechToTextService({AudioRecorder? recorder}) : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  bool _recording = false;
  String? _currentPath;

  bool get isRecording => _recording;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<String?> start() async {
    if (_recording) return _currentPath;
    if (!await _recorder.hasPermission()) return null;
    _currentPath = '/tmp/amc_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(),
      path: _currentPath!,
    );
    _recording = true;
    return _currentPath;
  }

  Future<String?> stop() async {
    if (!_recording) return null;
    final path = await _recorder.stop();
    _recording = false;
    _currentPath = null;
    return path;
  }

  Future<void> dispose() async {
    if (_recording) await _recorder.stop();
    await _recorder.dispose();
  }
}
