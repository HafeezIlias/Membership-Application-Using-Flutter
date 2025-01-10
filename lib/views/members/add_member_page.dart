import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/views/members/members_page.dart';
import 'package:simple_app/models/user.dart';
import '../shared/mydrawer.dart';

class AddMemberPage extends StatefulWidget {
  final User user;
  const AddMemberPage({super.key, required this.user});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _role = 'User';
  String _userranking = 'Member';
  bool isLoading = false;
  File? _image;
  late double pageWidth, pageHeight;

  final List<Map<String, dynamic>> roles = [
    {'label': 'User', 'icon': Icons.person},
    {'label': 'Admin', 'icon': Icons.admin_panel_settings},
  ];

  final List<Map<String, dynamic>> rankings = [
    {'label': 'Member'},
    {'label': 'High Council'},
    {'label': 'President'},
  ];

  @override
  Widget build(BuildContext context) {
    pageHeight = MediaQuery.of(context).size.height;
    pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Member'),
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
      ),
      drawer: MyDrawer(user: widget.user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showSelectionDialog();
                },
                child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: _image == null
                            ? const AssetImage(
                                'assets/Camera.png',
                              ) // Correct usage of AssetImage
                            : FileImage(_image!)
                                as ImageProvider, // Correct usage of FileImage
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey),
                    ),
                    height: pageHeight * 0.4),
              ),
              const SizedBox(
                height: 16,
              ),
              // Member Name Field
              TextFormField(
                controller: _nameController,
                validator: (value) =>
                    value!.isEmpty ? "Enter Member Name" : null,
                decoration: const InputDecoration(
                  labelText: "Member Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                validator: (value) => value!.isEmpty || !value.contains('@')
                    ? "Enter a valid Email"
                    : null,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (value) => value!.isEmpty || value.length < 6
                    ? "Enter a valid Password"
                    : null,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField(
                value: _role,
                items: roles.map((item) {
                  return DropdownMenuItem(
                    value: item['label'],
                    child: Row(
                      children: [
                        Icon(item['icon'], color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(item['label']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _role = value.toString()),
                decoration: const InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              
              // Ranking Dropdown
              DropdownButtonFormField(
                value: _userranking,
                items: rankings.map((item) {
                  return DropdownMenuItem(
                    value: item['label'],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['label'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _userranking = value.toString()),
                decoration: const InputDecoration(
                  labelText: "Ranking",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Submit Button
              MaterialButton(
                elevation: 10,
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    print("STILL HERE");
                    return;
                  }
                  if (_image == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please take a photo"),
                      backgroundColor: Colors.red,
                    ));
                    return;
                  }
                  // double filesize = getFileSize(_image!);
                  // print(filesize);

                  // if (filesize > 100) {
                  //   ScaffoldMessenger.of(context)
                  //       .showSnackBar(const SnackBar(
                  //     content: Text("Image size too large"),
                  //     backgroundColor: Colors.red,
                  //   ));
                  //   return;
                  // }

                  insertMemberDialog();
                },
                minWidth: pageWidth,
                height: 50,
                color: const Color.fromARGB(255, 253, 157, 2),
                child: Text(
                  "Insert",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("${MyConfig.servername}/api/add_member.php"),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _role,
        'userranking': _userranking,
      },
    );

    setState(() => isLoading = false);

    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data['message']),
        backgroundColor:
            data['status'] == 'success' ? Colors.green : Colors.red,
      ),
    );

    if (data['status'] == 'success') {
      Navigator.pop(context);
    }
  }

  void showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select from",
              style: TextStyle(),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(pageWidth / 4, pageHeight / 8)),
                  child: const Text('Gallery'),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                    _selectfromGallery(),
                  },
                ),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(pageWidth / 4, pageHeight / 8)),
                  child: const Text('Camera'),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                    _selectFromCamera(),
                  },
                ),
              ],
            ));
      },
    );
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    // print("BEFORE CROP: ");
    // print(getFileSize(_image!));
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {
        _image = File(pickedFile.path);
      });
      cropImage();
    } else {}
  }

  Future<void> _selectfromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    // print("BEFORE CROP: ");
    // print(getFileSize(_image!));
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      // setState(() {
      //   _image = File(pickedFile.path);
      // });
      cropImage();
    } else {}
  }

  Future<void> cropImage() async {
    if (_image == null) {
      print("No image to crop.");
      return; // Exit if no image is set
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Please Crop Your Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedFile != null) {
      // If cropping is successful
      File imageFile = File(croppedFile.path);
      setState(() {
        _image = imageFile; // Update the _image with the cropped image
      });

      //print("Cropped Image Size: ${await getFileSize(_image!)}"); // Print image size after cropping
    } else {
      print("Image cropping failed.");
    }
  }

  void insertMemberDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: const Text(
              "Insert Event",
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
                  addMember();
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MembersPage(user: widget.user,)),
                  );
                },
              ),
              TextButton(
                child: const Text(
                  "No",
                  style: TextStyle(),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }
}
