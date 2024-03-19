
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Author {
  final String authorName;
  final String dob;

  Author({
    required this.authorName,
    required this.dob,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      authorName: json['authorName'],
      dob: json['dob'],
    );
  }
}

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

  factory Book.fromJson(Map<String, dynamic> json) {
    List<dynamic> authorsList = json['authors'];
    List<Author> authors = authorsList.map((authorJson) => Author.fromJson(authorJson)).toList();

    return Book(
      id: json['_id'],
      bookName: json['bookName'],
      year: json['year'],
      authors: authors,
    );
  }
}

class UpdateBooks extends StatefulWidget {
  final String bookId;
  final Map<String, dynamic> initialBook;

  const UpdateBooks({Key? key, required this.bookId, required this.initialBook})
      : super(key: key);

  @override
  _UpdateBooksState createState() => _UpdateBooksState();
}

class _UpdateBooksState extends State<UpdateBooks> {
  late TextEditingController _bookNameController;
  late TextEditingController _yearController;
  List<Map<String, TextEditingController>> _authorControllers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bookNameController =
        TextEditingController(text: widget.initialBook['bookName']);
    _yearController = TextEditingController(text: widget.initialBook['year']);
    final List<dynamic>? authors = widget.initialBook['authors'];
    if (authors != null) {
      _authorControllers = authors.map((author) {
        return {
          'authorName': TextEditingController(text: author['authorName']),
          'dob': TextEditingController(text: author['dob']),
        };
      }).toList();
    }
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    _yearController.dispose();
    _authorControllers.forEach((author) {
      author['authorName']?.dispose();
      author['dob']?.dispose();
    });
    super.dispose();
  }

  void _addAuthorField() {
    setState(() {
      _authorControllers.add({
        'authorName': TextEditingController(),
        'dob': TextEditingController(),
      });
    });
  }

  Future<void> _updateBook() async {
    final bookName = _bookNameController.text;
    final year = _yearController.text;
    final List<Map<String, dynamic>> authors = _authorControllers.map((author) {
      return {
        'authorName': author['authorName']?.text,
        'dob': author['dob']?.text,
      };
    }).toList();

    if (bookName.isEmpty || year.isEmpty || authors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
            'https://crudcrud.com/api/268f8960b7784fb8965902ae2764824e/unicorns/${widget.bookId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'bookName': bookName,
          'year': year,
          'authors': authors,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book updated successfully.'),
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(
          'Failed to update book. Status code: ${response.statusCode}',
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update book: $error'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Book'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _bookNameController,
                decoration: const InputDecoration(labelText: 'Book name'),
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < _authorControllers.length; i++) ...[
                TextFormField(
                  controller: _authorControllers[i]['authorName'],
                  decoration: InputDecoration(
                    labelText: 'Author ${i + 1} name',
                  ),
                ),
                TextFormField(
                  controller: _authorControllers[i]['dob'],
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                ),
              ],
              ElevatedButton(
                onPressed: _addAuthorField,
                child: const Text('Add Author'),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateBook,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



