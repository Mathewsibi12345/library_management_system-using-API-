


import 'package:flutter/material.dart';
import 'package:flutter_api_crud/view/add.dart';
import 'package:flutter_api_crud/view/update.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _books = [];
// List to store fetched books from API
  @override
  void initState() {
    super.initState();
    _fetchBooks();// Fetch books when the widget is initialized
  }


  Future<void> _fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('https://crudcrud.com/api/268f8960b7784fb8965902ae2764824e/unicorns'),
      );

      if (response.statusCode == 200) {
         // Parse and update the _books list if the response is successful
        if (response.body != null) {
          setState(() {
            _books = json.decode(response.body);
          });
        } else {
          throw Exception('Response body is null');
        }
      } else {
        throw Exception('Failed to load books from API');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _deleteBook(String bookId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://crudcrud.com/api/268f8960b7784fb8965902ae2764824e/unicorns/$bookId'),
      );

      if (response.statusCode == 200) {
          
        setState(() {
          _books.removeWhere((book) => book['_id'] == bookId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book deleted successfully.'),
          ),
        );
      } else {
        throw Exception(
            'Failed to delete book. Status code: ${response.statusCode}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete book: $error'),
        ),
      );
    }
  }
 // Method to show a confirmation dialog before deleting a book
  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String bookId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                _deleteBook(bookId);
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateConfirmationDialog(
      BuildContext context, String bookId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Update'),
          content: Text('Are you sure you want to update this book?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToUpdatePage(bookId);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
// Method to navigate to the update screen with the selected book's data
void _navigateToUpdatePage(String bookId) {
  final book = _books.firstWhere((element) => element['_id'] == bookId);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UpdateBooks(bookId: bookId, initialBook: book,), // Pass bookId here
    ),
  ).then((_) {
    _fetchBooks(); // Refresh books after updating
  });
}



  // void _navigateToUpdatePage(String bookId) {
  //   final book = _books.firstWhere((element) => element['_id'] == bookId);
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => UpdateBooks(initialBook: book,),
  //     ),
  //   ).then((_) {
  //     _fetchBooks(); // Refresh books after updating
  //   });
  // }

  
  // Method to show author details in an alert dialog

  void _showAuthorDetails(
      BuildContext context, List<dynamic>? authors, List<dynamic>? dobs) {
    if (authors == null ||
        authors.isEmpty ||
        dobs == null ||
        dobs.isEmpty) {
      // Handle case where authors or dobs are null or empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Author Details'),
            content: Text('No author details available.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
      return;
    }

    List<Widget> authorWidgets = [];
    for (int i = 0; i < authors.length; i++) {
      authorWidgets.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Author ${i + 1} Name: ${authors[i]['authorName']}'),
          SizedBox(height: 8),
        ],
      ));

      if (i < dobs.length) {
        authorWidgets.add(Text('Date of Birth: ${dobs[i]}'));
        authorWidgets.add(SizedBox(height: 8));
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Author Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: authorWidgets,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Management'),
      ),
      body: _books.isEmpty
          ? Center(
              child: Text(
                'No books added yet.',
                style: TextStyle(fontSize: 20.0),
              ),
            )
          : ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                final authors = book['authors'];
                final dobs = (authors != null && authors is List)
                    ? authors.map((author) => author['dob']).toList()
                    : <String>[];

                return ListTile(
                  title: Text('Book Name: ${book['bookName']}'),
                  subtitle: Text('Year: ${book['year']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showUpdateConfirmationDialog(context, book['_id']);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, book['_id']);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showAuthorDetails(context, authors, dobs);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBooks()),
          );
          _fetchBooks();
        },
    
        
        
        child: Icon(Icons.add),
      ),
    );
  }
}



