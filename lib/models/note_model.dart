// lib/models/note_model.dart

import 'package:hive/hive.dart';
import 'package:smart_notes/models/checklist_item_model.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime dateCreated;

  @HiveField(4)
  DateTime dateModified;

  @HiveField(5)
  bool isPinned;

  @HiveField(6)
  List<ChecklistItem> checklist;

  @HiveField(7)
  String? imageUrl;

  @HiveField(8)
  String? audioPath;

  @HiveField(9)
  String? summarizedText;

  @HiveField(10)
  String? translatedText;

  @HiveField(11)
  bool isArchived;

  @HiveField(12)
  bool isDeleted;

  @HiveField(13)
  DateTime? reminderDate;

  // The colorValue field has been removed.

  Note({
    required this.id,
    this.title = '',
    this.content = '',
    required this.dateCreated,
    required this.dateModified,
    this.isPinned = false,
    this.checklist = const [],
    this.imageUrl,
    this.audioPath,
    this.summarizedText,
    this.translatedText,
    this.isArchived = false,
    this.isDeleted = false,
    this.reminderDate,
    // The colorValue property has been removed from the constructor.
  });

  /// Creates a copy of this Note but with the given fields replaced with new values.
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? dateCreated,
    DateTime? dateModified,
    bool? isPinned,
    List<ChecklistItem>? checklist,
    String? imageUrl,
    String? audioPath,
    String? summarizedText,
    String? translatedText,
    bool? isArchived,
    bool? isDeleted,
    DateTime? reminderDate,
    // The colorValue property has been removed from copyWith.
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      isPinned: isPinned ?? this.isPinned,
      checklist: checklist ?? this.checklist,
      imageUrl: imageUrl ?? this.imageUrl,
      audioPath: audioPath ?? this.audioPath,
      summarizedText: summarizedText ?? this.summarizedText,
      translatedText: translatedText ?? this.translatedText,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      reminderDate: reminderDate ?? this.reminderDate,
    );
  }
}
