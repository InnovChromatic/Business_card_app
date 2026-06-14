import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  Future<String> extractText(String imagePath) async {
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (error) {
      throw OcrException('Unable to extract text from the image.', error);
    } finally {
      await textRecognizer.close();
    }
  }
}

class OcrException implements Exception {
  const OcrException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
