import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Appends timestamped lines to a `logs/app.log` file.
///
/// Resolution order for the `logs/` folder (first writable wins):
///   1. Next to the executable (desktop — the "bin/windows" case).
///   2. The current working directory.
///   3. The platform app-support directory (mobile / sandboxed apps).
///
/// If none are writable the logger silently becomes a no-op, so it never
/// breaks app startup.
class FileLogger {
  FileLogger._();
  static final FileLogger instance = FileLogger._();

  IOSink? _sink;

  /// Opens the log file for appending. Safe to call more than once.
  Future<void> init() async {
    if (_sink != null) return;
    final file = await _resolveLogFile();
    if (file == null) return;
    _sink = file.openWrite(mode: FileMode.append);
    info('═══════════ ScanCo session start ═══════════');
  }

  /// Mirrors a raw line (used by the zone `print` interceptor).
  void write(String line) {
    final sink = _sink;
    if (sink == null) return;
    sink.writeln('${DateTime.now().toIso8601String()}  $line');
  }

  void info(String message) => write('INFO  $message');

  void error(String message) => write('ERROR $message');

  Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
  }

  Future<File?> _resolveLogFile() async {
    final candidates = <String>[];

    // 1) Next to the executable (desktop).
    try {
      candidates.add(File(Platform.resolvedExecutable).parent.path);
    } catch (_) {}

    // 2) Current working directory.
    try {
      candidates.add(Directory.current.path);
    } catch (_) {}

    // 3) App-support directory (mobile / sandbox).
    try {
      final support = await getApplicationSupportDirectory();
      candidates.add(support.path);
    } catch (_) {}

    for (final base in candidates) {
      try {
        final logsDir = Directory('$base${Platform.pathSeparator}logs');
        await logsDir.create(recursive: true);
        // Probe writability before committing to this location.
        final probe = File('${logsDir.path}${Platform.pathSeparator}.probe');
        await probe.writeAsString('ok');
        await probe.delete();
        return File('${logsDir.path}${Platform.pathSeparator}app.log');
      } catch (_) {
        // Try the next candidate.
      }
    }
    return null;
  }
}
