import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/models/user.dart';

class SettingsPage extends StatefulWidget {
  final User user;

  const SettingsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  late User updatedUser;

  @override
  void initState() {
    super.initState();
    updatedUser = widget.user;
  }

  Future<void> _chooseImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    try {
      String base64Image = base64Encode(_image!.readAsBytesSync());
      String fileName = _image!.path.split('/').last;

      final response = await http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/upload_profile_picture.php"),
        body: {
          "user_id": widget.user.userid,
          "image": base64Image,
          "filename": fileName,
        },
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully!")),
        );
        setState(() {
          updatedUser.userprofileimage = data['image_path'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload profile picture.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture Display
            CircleAvatar(
              radius: 60,
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : updatedUser.userprofileimage != null
                      ? NetworkImage(
                          "${MyConfig.servername}/simple_app/assets/profileImage/${updatedUser.userprofileimage}",
                        ) as ImageProvider
                      : const AssetImage("assets/default_profile.png"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _chooseImage,
              icon: const Icon(Icons.image),
              label: const Text("Choose Image"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _uploadProfilePicture,
              icon: const Icon(Icons.upload),
              label: const Text("Upload Profile Picture"),
            ),
            const Divider(height: 30),
            // User Information Display
            _buildUserInfoRow("Name", updatedUser.username),
            _buildUserInfoRow("Email", updatedUser.useremail),
            _buildUserInfoRow("Phone", updatedUser.userphone),
            _buildUserInfoRow("Address", updatedUser.useraddress),
            _buildUserInfoRow("Role", updatedUser.userrole),
            _buildUserInfoRow("Ranking", updatedUser.userranking),
            _buildUserInfoRow("Date Registered", updatedUser.userdatereg),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? "Not provided"),
          ),
        ],
      ),
    );
  }
}
