class TodoItem {
  final int? id;
  final String title;
  final String description;
  final bool isDone;

  TodoItem({
    this.id,
    required this.title,
    required this.description,
    this.isDone = false,
  });

  // key=column in database, value=field value
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone ? 1 : 0, // sqlite does not have boolean type
    };
  }
}