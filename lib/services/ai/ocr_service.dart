// lib/services/ai/ocr_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_notes/widgets/cropper/image_cropper_screen.dart'; // Import the new screen
import 'package:path_provider/path_provider.dart'; // Add this import
import 'package:uuid/uuid.dart'; // Add this import

class OcrService {
  final ImagePicker _picker = ImagePicker();

  /// Processes an image for OCR using a specified language.
  /// NOTE: This now requires the BuildContext to navigate to the cropper screen.
  Future<String> processImageWithLanguage(
      BuildContext context, String language) async {
    // 1. Capture an image
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (imageFile == null) return '';

    final File rawImageFile = File(imageFile.path);

    // 2. Navigate to the cropper screen and wait for the result (Uint8List)
    final Uint8List? croppedBytes = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCropperScreen(imageFile: rawImageFile),
      ),
    );

    if (croppedBytes == null || !context.mounted) return '';

    // Save bytes to a temporary file for more reliable processing
    try {
      // 3. Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      // 4. Create a unique path for the temporary file
      final tempFilePath = '${tempDir.path}/${const Uuid().v4()}.jpg';
      final tempFile = File(tempFilePath);
      // 5. Write the cropped image bytes to the file
      await tempFile.writeAsBytes(croppedBytes);

      final script = _getScriptForLanguage(language);
      final textRecognizer = TextRecognizer(script: script);

      // 6. Use the much more reliable `InputImage.fromFilePath` method
      final inputImage = InputImage.fromFilePath(tempFile.path);

      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      // 7. Clean up the temporary file
      await tempFile.delete();

      return recognizedText.text;
    } catch (e) {
      print("Error during ML Kit OCR processing: $e");
      return 'Error: Could not process image.';
    }
  }

  /// Maps a language code to a supported ML Kit TextRecognitionScript.
  TextRecognitionScript _getScriptForLanguage(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'eng':
        return TextRecognitionScript.latin;
      case 'hin':
        return TextRecognitionScript.devanagiri; // Corrected spelling
      case 'chi':
        return TextRecognitionScript.chinese;
      case 'jpn':
        return TextRecognitionScript.japanese;
      case 'kor':
        return TextRecognitionScript.korean;
      default:
        return TextRecognitionScript.latin;
    }
  }
}
