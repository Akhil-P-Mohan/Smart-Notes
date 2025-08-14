import 'package:hive/hive.dart';

part 'checklist_item_model.g.dart';

@HiveType(typeId: 1)
class ChecklistItem extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool isChecked;

  ChecklistItem({required this.text, this.isChecked = false});
}
