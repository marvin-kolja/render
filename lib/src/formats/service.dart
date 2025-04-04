import 'dart:typed_data';

/// How the format can be handled. This is important for handling the file later
/// (eg. displaying the file). Some file types might be [FormatType.motion] but
/// still should be handled like an image (eg. apng, gif, etc.).
enum FormatHandling {
  /// Handling like an image (everything from png, jpeg to gif)
  image,

  ///Handling like a video (everything from mp4 to mov)
  video,

  /// Unknown handling are files that usually cannot be opened by a default
  /// image or video reader (eg. psd)
  unknown;

  bool get isVideo => this == FormatHandling.video;

  bool get isImage => this == FormatHandling.image;

  bool get isUnknown => this == FormatHandling.unknown;
}

/// Class containing an audio stream that can be used for motion formats.
///
/// The audio stream must be in PCM format and must match the video stream's
/// bitrate, sample rate, and number of channels.
class AudioStream {
  /// The audio stream that should be used for the video.
  ///
  /// Must be in pcm format.
  final Stream<Uint8List> stream;

  /// Bitrate of the audio stream in bits per second.
  final int bitRate;

  /// Sample rate of the audio stream in samples per second.
  final int sampleRate;

  /// Number of channels of the audio stream.
  final int numChannels;

  AudioStream({
    required this.stream,
    this.bitRate = 128000,
    this.sampleRate = 44100,
    this.numChannels = 2,
  });
}
