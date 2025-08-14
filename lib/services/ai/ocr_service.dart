import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final ImagePicker _picker = ImagePicker();

  /// Processes an image for OCR using a specified language for Tesseract.
  /// This works completely offline.
  Future<String> processImageWithLanguage(String language) async {
    // 1. Capture an image
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (imageFile == null) return '';

    // 2. Allow user to crop the image
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop to select text',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(title: 'Crop to select text'),
      ],
    );

    if (croppedFile == null) return '';

    // 3. Process the cropped image with Tesseract OCR
    try {
      // The `lang` argument must match the file name (e.g., "eng" for eng.traineddata)
      final extractedText = await FlutterTesseractOcr.extractText(
        croppedFile.path,
        language: language,
        args: {
          "psm": "4", // Page Segmentation Mode, 4 is a good default
          "preserve_interword_spaces": "1",
        },
      );
      return extractedText;
    } catch (e) {
      print("Error during Tesseract OCR processing: $e");
      return 'Error: Could not process image.';
    }
  }
}
