import '../../render.dart';

class PngFormat extends ImageFormat {
  /// PNG (Portable Network Graphics) is a lossless image format that supports
  /// transparent backgrounds and a wide range of colors. It is commonly used
  /// for web and graphic design projects due to its high quality and small
  /// file size.
  ///
  /// In Flutter, PNG images can be easily integrated and used within the
  /// application. The "Image" widget is commonly used to display PNG images,
  /// and they can also be used as background images or in buttons and other
  /// UI elements. Additionally, the "AssetImage" class can be used to load
  /// PNG images from the application's asset folder. Overall, the PNG
  /// format is a popular choice for Flutter developers due to its high
  /// quality and compatibility with the framework.
  const PngFormat({
    super.quality = 95,
  }) : super(
          handling: FormatHandling.image,
        );

  @override
  PngFormat copyWith({
    int? quality,
  }) {
    return PngFormat(
      quality: quality ?? this.quality,
    );
  }

  @override
  Future<String> render() {
    throw UnimplementedError("PNG rendering not implemented, yet.");
  }

  @override
  String get extension => "png";
}

class JpgFormat extends ImageFormat {
  /// JPG, also known as JPEG, is a popular image file format that is widely
  /// used for digital photos and images. It uses a compression method that
  /// reduces the size of the file without significantly affecting the
  /// quality of the image.
  /// Does not support transparency.
  const JpgFormat({
    super.quality = 95,
  }) : super(
          handling: FormatHandling.image,
        );

  @override
  JpgFormat copyWith({
    int? quality,
  }) {
    return JpgFormat(
      quality: quality ?? this.quality,
    );
  }

  @override
  Future<String> render() {
    throw UnimplementedError("JPG rendering not implemented, yet.");
  }

  @override
  String get extension => "jpg";
}
