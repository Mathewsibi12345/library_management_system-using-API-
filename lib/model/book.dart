


import 'author.dart';

class Book {
  final String id;
  final String bookName;
  final String year;
  final List<Author> authors;

  Book({
    required this.id,
    required this.bookName,
    required this.year,
    required this.authors,
  });

  String? get title => null;

  String? get author => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'year': year,
      'authors': authors.map((author) => author.toJson()).toList(),
    };
  }

  static fromJson(item) {}
}
