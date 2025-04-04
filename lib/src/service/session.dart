import 'dart:async';
import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:render/src/service/settings.dart';
import 'package:render/src/service/task_identifier.dart';
import 'package:uuid/uuid.dart';
import '../formats/abstract.dart';
import 'exception.dart';
import 'notifier.dart';

/// A detached render session is a render session that is not attached to a view
class DetachedRenderSession<T extends RenderFormat, K extends RenderSettings> {
  /// Pointer to session files and operation.
  final String sessionId;

  /// Directory of a temporary storage, where files can be used for processing.
  /// This should be somewhere in a RAM location for fast processing.
  final String temporaryDirectory;

  /// Where result files are being written
  final String outputDirectory;

  /// All render related settings
  final K settings;

  final T format;

  /// What notifications should be displayed
  final LogLevel logLevel;

  /// Binding to the Context of the [Render] widget.
  final SchedulerBinding binding;

  /// A class that holds information about the current detached session. Ranging
  /// from directories to session identification.
  DetachedRenderSession({
    required this.logLevel,
    required this.binding,
    required this.outputDirectory,
    required this.sessionId,
    required this.temporaryDirectory,
    required this.settings,
    required this.format,
  });

  /// Creates a detached render session from default values (paths & session syntax)
  /// Attach a session by initializing RenderPaint and Context values by
  /// extending with [RenderSession]
  static Future<DetachedRenderSession<T, K>>
      create<T extends RenderFormat, K extends RenderSettings>(
          T format, K settings, LogLevel logLevel) async {
    final tempDir = await getTemporaryDirectory();
    final sessionId = const Uuid().v4();
    return DetachedRenderSession<T, K>(
      logLevel: logLevel,
      binding: SchedulerBinding.instance,
      outputDirectory: "${tempDir.path}/render/$sessionId/output",
      sessionId: sessionId,
      temporaryDirectory: tempDir.path,
      settings: settings,
      format: format,
    );
  }

  ///Creates a new file path if not present and returns the file as directory
  File _createFile(String path) {
    final outputFile = File(path);
    if (!outputFile.existsSync()) outputFile.createSync(recursive: true);
    return outputFile;
  }

  /// Creating a file in the output directory.
  File createOutputFile(String subPath) =>
      _createFile("$outputDirectory/$subPath");
}

class RenderSession<T extends RenderFormat, K extends RenderSettings>
    extends DetachedRenderSession<T, K> {
  /// Used to identify the tasks that should be rendered. This must include
  /// a main rendering task.
  final TaskIdentifier task;

  /// Session notifier to all activity in this session.
  final StreamController<RenderNotifier> _notifier;

  /// Start time of session. Is the reference for timestamps and
  /// remaining time calculation.
  final DateTime startTime;

  final VoidCallback onDispose;

  /// A class that holds all the information about the current session.
  /// used to pass information between the different parts of the rendering
  /// process.
  RenderSession({
    required super.logLevel,
    required super.settings,
    required super.outputDirectory,
    required super.sessionId,
    required super.temporaryDirectory,
    required super.format,
    required super.binding,
    required this.task,
    required this.onDispose,
    required StreamController<RenderNotifier> notifier,
    DateTime? startTime,
  })  : _notifier = notifier,
        startTime = startTime ?? DateTime.now();

  RenderState? _currentState;

  /// A constructor that takes a `DetachedRenderSession` and creates a
  /// `RenderSession` from it.
  RenderSession.fromDetached({
    required DetachedRenderSession<T, K> detachedSession,
    required StreamController<RenderNotifier> notifier,
    required this.task,
    required this.onDispose,
    DateTime? startTime,
  })  : _notifier = notifier,
        startTime = DateTime.now(),
        super(
          logLevel: detachedSession.logLevel,
          binding: detachedSession.binding,
          format: detachedSession.format,
          settings: detachedSession.settings,
          outputDirectory: detachedSession.outputDirectory,
          sessionId: detachedSession.sessionId,
          temporaryDirectory: detachedSession.temporaryDirectory,
        );

  /// Upgrade the current renderSession to a real session
  RenderSession<T, RealRenderSettings> upgrade(
      Duration capturingDuration, int frameAmount) {
    return RenderSession<T, RealRenderSettings>(
      settings: RealRenderSettings(
        pixelRatio: settings.pixelRatio,
        processTimeout: settings.processTimeout,
        capturingDuration: capturingDuration,
        frameAmount: frameAmount,
      ),
      onDispose: onDispose,
      startTime: startTime,
      logLevel: logLevel,
      outputDirectory: outputDirectory,
      sessionId: sessionId,
      temporaryDirectory: temporaryDirectory,
      format: format,
      binding: binding,
      task: task,
      notifier: _notifier,
    );
  }

  /// Returns the duration from the start of the session until now.
  Duration get currentTimeStamp {
    return Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch -
          startTime.millisecondsSinceEpoch,
    );
  }

  /// A method that is used to record activity in the session.
  void recordActivity(RenderState state, double? stateProgression,
      {String? message, String? details}) {
    if (logLevel == LogLevel.none || _notifier.isClosed) return;
    if (_currentState != state) _currentState = state;
    _notifier.add(
      RenderActivity(
        session: this,
        timestamp: currentTimeStamp,
        state: state,
        currentStateProgression: stateProgression ?? 0.5,
        message: message,
        details: details,
      ),
    );
  }

  /// Used to record log messages in the session.
  void recordLog(String message) {
    if (logLevel != LogLevel.debug || _notifier.isClosed) return;
    _notifier.add(
      RenderLog(
        timestamp: currentTimeStamp,
        message: message,
      ),
    );
  }

  /// A method that is used to record errors in the session.
  void recordError(RenderException exception) {
    if (_notifier.isClosed) return;
    _notifier.add(
      RenderError(
        timestamp: currentTimeStamp,
        fatal: exception.fatal,
        exception: exception,
      ),
    );
    if (exception.fatal) {
      dispose();
    }
  }

  /// Recording the result of the render session.
  void recordResult(File output, {String? message, String? details}) {
    if (_notifier.isClosed) return;
    _notifier.add(
      RenderResult(
        session: this,
        format: format,
        timestamp: currentTimeStamp,
        usedSettings: settings as RealRenderSettings,
        output: output,
        message: message,
        details: details,
      ),
    );
    dispose();
  }

  /// Disposing the current render session.
  Future<void> dispose() async {
    onDispose();
    await _notifier.close();
  }
}
