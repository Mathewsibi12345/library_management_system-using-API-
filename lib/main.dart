import 'package:flutter/material.dart';

import 'package:flutter_api_crud/view/home.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return 
       MaterialApp(
        title: 'EMS',
        routes: {
           '/':(context) =>  HomePage(),
          // '/add':(context) => const AddUser(),
          //  '/login': (context) => const LoginScreen(),
          // '/signup': (context) => const AddUser(),
          
        } ,
        initialRoute: '/',
      
      
    );
  }
}

