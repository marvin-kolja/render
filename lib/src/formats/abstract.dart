import 'dart:typed_data';

import 'package:render/src/formats/image.dart';
import 'package:render/src/formats/service.dart';

import 'motion.dart';

abstract class RenderFormat {
  /// How the format can be handled. This is important for handling the file later
  /// (eg. displaying the file). Some file types might be [FormatType.motion] but
  /// still should be handled like an image (eg. apng, gif, etc.).
  final FormatHandling handling;

  /// A class that defines the format of the output file.
  const RenderFormat({
    required this.handling,
  });

  /// A function that reflects the rendering process of the file.
  ///
  /// Returns the path to the output file.
  Future<String> render();

  /// The extension of this file format (eg. "mp4").
  String get extension;

  bool get isMotion => this is MotionFormat;

  bool get isImage => this is ImageFormat;

  MotionFormat? get asMotion => isMotion ? this as MotionFormat : null;

  ImageFormat? get asImage => isImage ? this as ImageFormat : null;
}

abstract class MotionFormat extends RenderFormat {
  /// Additional audio stream that can be used for the video.
  final AudioStream? audio;

  /// Formats that include some sort of motion and have multiple frames.
  const MotionFormat({
    required this.audio,
    required super.handling,
  });

  /// A function that allows you to copy the format with new parameters.
  /// This is useful for creating a new format with the same base but different
  /// parameters. Alternatively you can call the Format directly (eg. [MovFormat]).
  MotionFormat copyWith();

  /// A function that allows you to setup the encoder with the given parameters.
  ///
  /// * [width] - The width of the video.
  /// * [height] - The height of the video.
  /// * [frameRate] - The frame rate of the video.
  /// * [outputPath] - The path to the output file.
  Future<void> setupEncoder({
    required int width,
    required int height,
    required int frameRate,
    required String outputPath,
  });

  Future<void> addVideoFrame(Uint8List data);

  Future<void> addAudioFrame(Uint8List data);

  static Mp4Format get mp4 => const Mp4Format();
}

abstract class ImageFormat extends RenderFormat {
  final int quality;

  /// Formats that are static images with one single frame.
  const ImageFormat({
    required this.quality,
    required super.handling,
  });

  /// A function that allows you to copy the format with new parameters.
  /// This is useful for creating a new format with the same base but different
  /// parameters. Alternatively you can call the Format directly (eg. [PngFormat]).
  ImageFormat copyWith();

  static ImageFormat get png => const PngFormat();

  static ImageFormat get jpg => const JpgFormat();
}
