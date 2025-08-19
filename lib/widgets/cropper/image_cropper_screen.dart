// lib/widgets/cropper/image_cropper_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:cropperx/cropperx.dart';
import 'package:flutter/material.dart';

class ImageCropperScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropperScreen({super.key, required this.imageFile});

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  final GlobalKey _cropperKey = GlobalKey(debugLabel: 'cropperKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              // Get the cropped image bytes
              final Uint8List? croppedBytes = await Cropper.crop(
                cropperKey: _cropperKey,
              );
              // Pop the screen and return the bytes
              if (mounted && croppedBytes != null) {
                Navigator.pop(context, croppedBytes);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Cropper(
          cropperKey: _cropperKey,
          image: Image.file(widget.imageFile),
          // Optional: Add overlay, aspect ratio, etc.
          overlayType: OverlayType.rectangle,
        ),
      ),
    );
  }
}
