import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/myconfig.dart';

class NewNewsScreen extends StatefulWidget {
  const NewNewsScreen({super.key});

  @override
  State<NewNewsScreen> createState() => _NewNewsScreenState();
}

class _NewNewsScreenState extends State<NewNewsScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  late double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Newsletter"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintText: "News Title")),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: screenHeight * 0.7,
              child: TextField(
                controller: detailsController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintText: "News Details"),
                maxLines: screenHeight ~/ 35,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              elevation: 10,
              onPressed: onInsertNewsDialog,
              minWidth: screenWidth,
              height: 50,
              color: const Color.fromARGB(255, 253, 157, 2), // Uses primary color from theme
              child: const Text(
                "Insert",
                style: TextStyle(
                  color: Colors.white, // Text color matches onPrimary color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onInsertNewsDialog() {
    if (titleController.text.isEmpty || detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter title and details"),
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Insert this newsletter?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                insertNews();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Insert News Canceled"),
                   backgroundColor: Colors.red,
               ));
              },
            ),
          ],
        );
      },
    );
  }

  void insertNews() async {
  String title = titleController.text.trim();
  String details = detailsController.text.trim();

  try {
    var response = await http.post(
      Uri.parse("${MyConfig.servername}/simple_app/api/insert_news.php"),
      body: {"title": title, "details": details},
    );
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          var data = jsonDecode(response.body);

          if (data['status'] == "success") {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Insert Success"),
              backgroundColor: Colors.green,
            ));
            titleController.clear();
            detailsController.clear();
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Insert Failed"),
              backgroundColor: Colors.red,
            ));
          }
        } catch (e) {
          print("Error decoding JSON: $e");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Unexpected server response"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Empty response from server"),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: HTTP ${response.statusCode}"),
        backgroundColor: Colors.red,
      ));
    }
  } catch (e) {
    print("Error during insertNews: $e");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Error connecting to the server"),
      backgroundColor: Colors.red,
    ));
  }
}

}