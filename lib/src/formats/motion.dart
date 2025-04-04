import 'dart:typed_data';

import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:render_native/src/formats/service.dart';

import 'abstract.dart';

class Mp4Format extends MotionFormat {
  /// MP4 (MPEG-4 Part 14) is a digital multimedia container format most
  /// commonly used to store video and audio, but can also be used to store
  /// other data such as subtitles and still images. It is a standard format
  /// used by many devices and platforms to play videos, and is known for
  /// its high compression rate and good quality. MP4 files typically have
  /// the file extension ".mp4".
  /// Transparency is not supported.
  const Mp4Format({
    super.audio,
  }) : super(
          handling: FormatHandling.video,
        );

  @override
  Mp4Format copyWith() {
    return Mp4Format(
      audio: audio,
    );
  }

  @override
  String get extension => "mp4";

  @override
  Future<void> setupEncoder({
    required int width,
    required int height,
    required int frameRate,
    required String outputPath,
  }) async {
    await FlutterQuickVideoEncoder.setup(
      width: width,
      height: height,
      fps: frameRate,
      videoBitrate: 2500000,
      profileLevel: ProfileLevel.highAutoLevel,
      audioChannels: audio?.numChannels ?? 0,
      audioBitrate: audio?.bitRate ?? 0,
      sampleRate: audio?.sampleRate ?? 0,
      filepath: outputPath,
    );
  }

  @override
  Future<void> addVideoFrame(Uint8List data) async {
    await FlutterQuickVideoEncoder.appendVideoFrame(data);
  }

  @override
  Future<void> addAudioFrame(Uint8List data) async {
    await FlutterQuickVideoEncoder.appendAudioFrame(data);
  }

  @override
  Future<String> render() async {
    await FlutterQuickVideoEncoder.finish();
    return FlutterQuickVideoEncoder.filepath;
  }
}
