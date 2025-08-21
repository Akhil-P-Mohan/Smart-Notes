// lib/services/ai/ocr_service.dart

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class OcrService {
  final ImagePicker _picker = ImagePicker();

  Future<String> processImageWithLanguage(
      BuildContext context, String language) async {
    final ImageSource? source = await _showImageSourceDialog(context);
    if (source == null || !context.mounted) return '';

    final XFile? imageFile = await _picker.pickImage(source: source);
    if (imageFile == null) return '';

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop to select text',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      ],
    );

    if (croppedFile == null) return '';

    try {
      final script = _getScriptForLanguage(language);
      final textRecognizer = TextRecognizer(script: script);
      final inputImage = InputImage.fromFilePath(croppedFile.path);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      textRecognizer.close();
      return recognizedText.text;
    } catch (e) {
      print("Error during ML Kit OCR processing: $e");
      return 'Error: Could not process image.';
    }
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            child: const Text('Camera'),
            // *** FIX: Corrected "Image - Source" to "ImageSource" ***
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          TextButton(
            child: const Text('Gallery'),
            // *** FIX: Corrected "Image - Source" to "ImageSource" ***
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  TextRecognitionScript _getScriptForLanguage(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'eng':
        return TextRecognitionScript.latin;
      case 'hin':
        return TextRecognitionScript.devanagiri;
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
