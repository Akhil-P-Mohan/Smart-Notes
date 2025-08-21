// lib/widgets/reusable/color_picker_dialog.dart

import 'package:flutter/material.dart';
import 'package:smart_notes/utils/constants.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});

  // Using the color list you provided
  final List<Color> _colorOptions = const [
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.indigo,
    Colors.purple,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Note Color'),
      content: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: [
          // "No Color" / Reset option
          InkWell(
            onTap: () => Navigator.pop(context, kDefaultNoteColor),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
              child:
                  const Center(child: Icon(Icons.format_color_reset, size: 20)),
            ),
          ),
          ..._colorOptions.map((color) {
            return InkWell(
              onTap: () => Navigator.pop(context, color),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
