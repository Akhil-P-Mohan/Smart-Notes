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
  String? imageUrl; // For image notes

  @HiveField(8)
  String? audioPath; // For voice notes

  @HiveField(9)
  String? summarizedText; // For AI summarization

  @HiveField(10)
  String? translatedText; // For AI translation

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
  });
}
