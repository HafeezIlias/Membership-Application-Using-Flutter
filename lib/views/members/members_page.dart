import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/models/user.dart';
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/views/members/add_member_page.dart';

class MembersPage extends StatefulWidget {
  final User user;
   const MembersPage({super.key, required  this.user});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  List<User> membersList = [];
  int currentPage = 1;
  int totalPages = 1;
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : membersList.isEmpty
                  ? const Expanded(
                      child: Center(child: Text('No members found')),
                    )
                  : _buildMembersList(),
          _buildPagination(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMemberPage(user: widget.user)),
          );
          loadMembers();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search Members...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: onSearch,
      ),
    );
  }

  Widget _buildMembersList() {
  return Expanded(
    child: ListView.builder(
      itemCount: membersList.length,
      itemBuilder: (context, index) {
        final member = membersList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              backgroundImage: member.userprofileimage != null
                  ? NetworkImage(
                      "${MyConfig.servername}/simple_app/assets/profileImage/${member.userprofileimage}")
                  : null,
              child: member.userprofileimage == null
                  ? Text(member.username != null && member.username!.isNotEmpty
                      ? member.username![0]
                      : '?')
                  : null,
            ),
            title: Text(
              member.username ?? 'No Name',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(member.userranking?? 'No Ranking'),
          ),
        );
      },
    ),
  );
}


  Widget _buildPagination() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: totalPages,
        itemBuilder: (context, index) {
          final isSelected = (currentPage == index + 1);
          return TextButton(
            onPressed: () => changePage(index + 1),
            child: Text(
              (index + 1).toString(),
              style: TextStyle(
                color: isSelected ? Colors.blueAccent : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> loadMembers() async {
  setState(() {
    isLoading = true;
  });
  try {
    final response = await http.get(
      Uri.parse(
          "${MyConfig.servername}/simple_app/api/load_member.php?pageno=$currentPage&search=$searchQuery"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        membersList = (data['data']['members'] as List)
            .map((member) => User.fromJson({
                  'userid': member['id'],
                  'useremail': member['email'],
                  'username': member['name'],
                  'userprofileimage': member['profileImage'],
                  'userranking': member['userranking'],
                }))
            .toList();
        totalPages = int.tryParse(data['numofpage'].toString()) ?? 1;
      } else {
        membersList = [];
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  setState(() {
    isLoading = false;
  });
}

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      currentPage = 1;
    });
    loadMembers();
  }

  void changePage(int page) {
    setState(() {
      currentPage = page;
    });
    loadMembers();
  }
}
