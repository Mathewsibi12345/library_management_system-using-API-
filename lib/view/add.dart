



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddBooks extends StatefulWidget {
  const AddBooks({Key? key}) : super(key: key);

  @override
  _AddBooksState createState() => _AddBooksState();
}

class _AddBooksState extends State<AddBooks> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final List<TextEditingController> _authorNameControllers = [];
  final List<TextEditingController> _authorDOBControllers = [];
  bool _isLoading = false; // Add this variable to track loading state
 // Method to add a new author field
  void _addAuthorField() {
    setState(() {
      _authorNameControllers.add(TextEditingController());
      _authorDOBControllers.add(TextEditingController());
    });
  }

  Future<void> _addBook() async {
    final bookName = _bookNameController.text;
    final year = _yearController.text;
    final List<Map<String, dynamic>> authors = [];
    // Iterate over author controllers to collect author information
    for (int i = 0; i < _authorNameControllers.length; i++) {
      authors.add({
        'authorName': _authorNameControllers[i].text,
        'dob': _authorDOBControllers[i].text,
      });
    }

    if (bookName.isEmpty || year.isEmpty || authors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state to true when button is pressed
    });

    try {
      final response = await http.post(
        Uri.parse('https://crudcrud.com/api/268f8960b7784fb8965902ae2764824e/unicorns'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'bookName': bookName,
          'year': year,
          'authors': authors,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book added successfully.'),
          ),       
        );
        _bookNameController.clear();
        _yearController.clear();
        _authorNameControllers.forEach((controller) => controller.clear());
        _authorDOBControllers.forEach((controller) => controller.clear());
        Navigator.pop(context);
      } else {
        throw Exception(
          'Failed to add book. Status code: ${response.statusCode}',
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add book: $error'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading state back to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Books'),
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
              for (int i = 0; i < _authorNameControllers.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _authorNameControllers[i],
                      decoration: InputDecoration(
                        labelText: 'Author ${i + 1} name',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              _authorNameControllers.removeAt(i);
                              _authorDOBControllers.removeAt(i);
                            });
                          },
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _authorDOBControllers[i],
                      decoration: const InputDecoration(labelText: 'Date of Birth'),
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _addAuthorField,
                child: _isLoading
                    ? CircularProgressIndicator() // Show loading indicator when loading
                    : const Text('Add Author'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _addBook, // Disable button when loading
                child: _isLoading
                    ? CircularProgressIndicator() // Show loading indicator when loading
                    : const Text('Add Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

