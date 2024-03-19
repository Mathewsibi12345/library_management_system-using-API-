class Author {
  final String authorName;
  final String dob;

  Author({
    required this.authorName,
    required this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'authorName': authorName,
      'dob': dob,
    };
  }
}
