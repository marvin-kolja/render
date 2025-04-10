import 'dart:io';

import 'package:render_native/src/formats/abstract.dart';
import 'package:render_native/src/service/notifier.dart';
import 'package:render_native/src/service/session.dart';
import 'package:render_native/src/service/settings.dart';
import 'service/exception.dart';

abstract class RenderProcessor<T extends RenderFormat> {
  final RenderSession<T, RealRenderSettings> session;

  RenderProcessor(this.session);

  bool _processing = false;

  ///Converts saved frames from temporary directory to output file
  Future<void> process() async {
    if (_processing) {
      throw const RenderException(
          "Cannot start new process, during an active one.");
    }
    _processing = true;
    try {
      final output = await _processTask();
      session.recordResult(output);
      _processing = false;
    } on RenderException catch (error, stackTrace) {
      session.recordError(error, stackTrace);
    }
  }

  /// Processes task frames and writes the output with the specific format
  /// Returns the process output file.
  Future<File> _processTask() async {
    session.recordActivity(RenderState.processing, 1,
        message: "Finalizing video encoder...");

    try {
      final outputPath = await session.format.render();
      return File(outputPath);
    } on Exception catch (error, stackTrace) {
      session.recordError(
        RenderException(
          "[Quick video encoder] $error",
          fatal: true,
        ),
        stackTrace,
      );
      rethrow;
    }
  }
}

class ImageProcessor extends RenderProcessor<ImageFormat> {
  ImageProcessor(super.session);
}

class MotionProcessor extends RenderProcessor<MotionFormat> {
  MotionProcessor(super.session);
}
