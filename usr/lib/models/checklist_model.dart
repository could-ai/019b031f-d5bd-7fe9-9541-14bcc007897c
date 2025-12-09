class ChecklistItem {
  String id;
  String title;
  bool isChecked;
  String? comment;
  String? imagePath; // Path to the local image file

  ChecklistItem({
    required this.id,
    required this.title,
    this.isChecked = false,
    this.comment,
    this.imagePath,
  });

  // Create a copy for a new inspection
  ChecklistItem clone() {
    return ChecklistItem(
      id: id,
      title: title,
      isChecked: false,
      comment: null,
      imagePath: null,
    );
  }
}
