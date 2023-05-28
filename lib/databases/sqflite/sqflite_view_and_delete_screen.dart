import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:untitled1/databases/sqflite/sqflite_create_and_update_screen.dart';

import '../../helpers/sqflite_database_helper.dart';

class SQLFLiteViewAndDeleteScreen extends StatefulWidget {
  const SQLFLiteViewAndDeleteScreen({Key? key}) : super(key: key);

  @override
  State<SQLFLiteViewAndDeleteScreen> createState() =>
      _SQLFLiteViewAndDeleteScreenState();
}

class _SQLFLiteViewAndDeleteScreenState
    extends State<SQLFLiteViewAndDeleteScreen> {
  final SQFLiteDatabaseHelper _databaseHelper = SQFLiteDatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const SQLFLiteCreateAndUpdateScreen();
          }));
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _databaseHelper.getUserDataFromSQFLITE(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> userDetails =
                snapshot.data as List<Map<String, dynamic>>;
            if (userDetails.isEmpty) {
              return Center(
                child: Text(
                  "No Data Added",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            } else {
              return ListView.separated(
                itemBuilder: (context, index) => ListTile(
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) {
                      return SQLFLiteCreateAndUpdateScreen(
                        userData: userDetails[index],
                      );
                    }));
                    setState(() {});
                  },
                  title: Text("${userDetails[index]["name"]}"),
                  subtitle: Text(userDetails[index]["filePath"]
                      .toString()
                      .split("/")
                      .last),
                  trailing: IconButton(
                    onPressed: () async {
                      await _databaseHelper
                          .deleteUserData(userDetails[index]["srn"]);
                      setState(() {});
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 16,
                ),
                itemCount: userDetails.length,
              );
            }
          } else {
            return Center(
              child: Text(
                "Something Went Wrong!",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
        },
      ),
    );
  }
}
