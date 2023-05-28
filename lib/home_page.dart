import 'package:flutter/material.dart';
import 'databases/sqflite/sqflite_view_and_delete_screen.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Database",
        ),
      ),
      body: SQLFLiteViewAndDeleteScreen(),
    );
  }
}
