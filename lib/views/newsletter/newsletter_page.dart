import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:simple_app/models/news.dart';
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/views/newsletter/edits_news.dart';
import 'package:simple_app/views/newsletter/new_news.dart';
import 'package:simple_app/views/shared/mydrawer.dart';

class NewsletterPage extends StatefulWidget {
  const NewsletterPage({super.key});

  @override
  State<NewsletterPage> createState() => _NewsletterPageState();
}

class _NewsletterPageState extends State<NewsletterPage> {
  List<News> newsList = [];
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;
  late double screenWidth, screenHeight;
  var color;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadNewsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Newsletter"),
          actions: [
            IconButton(
                onPressed: () {
                  loadNewsData();
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: newsList.isEmpty
            ? const Center(
                child: Text("Loading..."),
              )
            : Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.05,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: numofpage,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        // Highlight the current page
                        color =
                            (curpage - 1 == index) ? Colors.red : Colors.black;
                        return TextButton(
                          onPressed: () {
                            setState(() {
                              curpage =
                                  index + 1; // Update to the selected page
                            });
                            loadNewsData(); // Reload data for the selected page
                          },
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(color: color, fontSize: 18),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: newsList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: const Color.fromARGB(185, 251, 218, 1),
                            elevation: 7,
                            child: ListTile(
                              onLongPress: () {
                                deleteDialog(index);
                              },
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    truncateString(
                                        newsList[index].newsTitle.toString(),
                                        30),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    df.format(DateTime.parse(
                                        newsList[index].newsDate.toString())),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                truncateString(
                                    newsList[index].newsDetails.toString(),
                                    100),
                                textAlign: TextAlign.justify,
                              ),

                             //leading: const Icon(Icons.article),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward,
                                ),
                                onPressed: () {
                                  showNewsDetailsDialog(index);
                                },
                              ),
                            ),
                          );
                        }),
                  ),
                ],
             ),
        drawer: const MyDrawer(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 255, 213, 75),
          elevation: 7,
          onPressed: () async {
            loadNewsData();
            await Navigator.push(context,
                MaterialPageRoute(builder: (content) => const NewNewsScreen()));
            loadNewsData();
          },
          child: const Icon(Icons.add),
        ));
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }

  void loadNewsData() {
    int limit = 10; // Maximum number of news per page
    http
        .get(Uri.parse(
            "${MyConfig.servername}/simple_app/api/load_news.php?pageno=$curpage&limit=$limit"))
        .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['news'];
          newsList.clear();
          for (var item in result) {
            News news = News.fromJson(item);
            newsList.add(news);
          }
          numofpage = int.tryParse(data['numofpage'].toString()) ?? 0;
          numofresult = int.tryParse(data['numberofresult'].toString()) ?? 0;
          print("Number of Pages: $numofpage");
          print("Number of Results: $numofresult");
          setState(() {}); // Update UI after loading data
        } else {
          print(
              "Failed to load news data: ${data['message'] ?? 'Unknown error'}");
          newsList.clear();
          setState(() {}); // Update UI to reflect empty state
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    }).catchError((error) {
      print("Error fetching news data: $error");
    });
  }

  void showNewsDetailsDialog(int index) {
    // Ensure index is within bounds
    if (index < 0 || index >= newsList.length) {
      print("Error: Index $index is out of bounds for newsList");
      return;
    }
    News news = newsList[index];
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(news.newsTitle ?? "No Title"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    news.newsDetails ?? "No Details",
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: news.isLiked ? Colors.green : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                if (news.isLiked) {
                                  // Undo like
                                  news.isLiked = false;
                                  news.likes--;
                                } else {
                                  // Like and undo dislike if needed
                                  news.isLiked = true;
                                  news.likes++;
                                  if (news.isDisliked) {
                                    news.isDisliked = false;
                                    news.dislikes--;
                                  }
                                }
                              });
                              updateLikesDislikes(
                                  news.newsId!, news.likes, news.dislikes);
                            },
                          ),
                          Text('${news.likes} Likes'),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_down,
                              color: news.isDisliked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                if (news.isDisliked) {
                                  // Undo dislike
                                  news.isDisliked = false;
                                  news.dislikes--;
                                } else {
                                  // Dislike and undo like if needed
                                  news.isDisliked = true;
                                  news.dislikes++;
                                  if (news.isLiked) {
                                    news.isLiked = false;
                                    news.likes--;
                                  }
                                }
                              });
                              updateLikesDislikes(
                                  news.newsId!, news.likes, news.dislikes);
                            },
                          ),
                          Text('${news.dislikes} Dislikes'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNewsScreen(news: news),
                      ),
                    );
                    loadNewsData();
                  },
                  child: const Text("Edit?"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Delete \"${truncateString(newsList[index].newsTitle.toString(), 20)}\"",
              style: const TextStyle(fontSize: 18),
            ),
            content: const Text("Are you sure you want to delete this news?"),
            actions: [
              TextButton(
                  onPressed: () {
                    deleteNews(index);
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

  void deleteNews(int index) {
    http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/delete_news.php"),
        body: {"newsid": newsList[index].newsId.toString()}).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log(data.toString());
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Success"),
            backgroundColor: Colors.green,
          ));
          loadNewsData(); //reload data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }

  Future<void> updateLikesDislikes(
      String newsId, int likes, int dislikes) async {
    try {
      var response = await http.post(
        Uri.parse(
            "${MyConfig.servername}/simple_app/api/update_likes_dislikes.php"),
        body: {
          'news_id': newsId,
          'likes': likes.toString(),
          'dislikes': dislikes.toString(),
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          print("Likes and dislikes updated successfully.");
        } else {
          print("Failed to update likes and dislikes.");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating likes and dislikes: $e");
    }
  }
}
