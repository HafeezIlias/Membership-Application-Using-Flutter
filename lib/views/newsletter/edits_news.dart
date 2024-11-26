import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:my_member_link/models/news.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/models/news.dart';
import 'package:simple_app/myconfig.dart';
//import 'package:my_member_link/myconfig.dart';

class EditNewsScreen extends StatefulWidget {
  final News news;
  const EditNewsScreen({super.key, required this.news});

  @override
  State<EditNewsScreen> createState() => _EditNewsState();
}

class _EditNewsState extends State<EditNewsScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController.text = widget.news.newsTitle.toString();
    detailsController.text = widget.news.newsDetails.toString();
  }

  late double screenWidth, screenHeight;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Newsletter"),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  onPressed: onUpdateNewsDialog,
                  minWidth: screenWidth,
                  height: 50,
                  color: Theme.of(context).colorScheme.secondary,
                  // color: Colors.blueAccent,
                  child: const Text("Update News",
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }

  void onUpdateNewsDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Update News?"),
            content: const Text("Are you sure you want to update this news?"),
            actions: [
              TextButton(
                  onPressed: () {
                    updateNews();
                    Navigator.pop(context);
                  },
                  child: const Text("Yes")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"))
            ],
          );
        });
  }

  void updateNews() {
    String title = titleController.text.toString();
    String details = detailsController.text.toString();

    http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/update_news.php"),
        body: {
          "newsid": widget.news.newsId.toString(),
          "title": title,
          "details": details
        }).then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status'] == "success") {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Update Success"),
                backgroundColor: Colors.green,
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Update Failed"),
                backgroundColor: Colors.red,
              ));
            }
          }
        });
  }
}