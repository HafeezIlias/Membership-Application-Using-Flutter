import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/myconfig.dart';

class NewProductPage extends StatefulWidget {
  const NewProductPage({super.key});

  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  String productTypeValue = 'Electronics';
  File? _image;
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController productStockController = TextEditingController();

  final List<Map<String, dynamic>> productTypes = [
    {'label': 'Electronics', 'icon': Icons.electrical_services},
    {'label': 'Clothing', 'icon': Icons.checkroom},
    {'label': 'Furniture', 'icon': Icons.chair},
    {'label': 'Books', 'icon': Icons.book},
    {'label': 'Accessories', 'icon': Icons.accessibility},
    {'label': 'Others', 'icon': Icons.more_horiz}, // Icon for 'Others'
  ];

  @override
  Widget build(BuildContext context) {
    final double pageWidth = MediaQuery.of(context).size.width;
    final double pageHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Product"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image Picker
              GestureDetector(
                onTap: () => showImageSelectionDialog(context),
                child: Container(
                  height: pageHeight * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    image: _image == null
                        ? const DecorationImage(
                            image: AssetImage('assets/Camera.png'),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Product Title
              TextFormField(
                controller: titleController,
                validator: (value) =>
                    value!.isEmpty ? "Please enter product title" : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Product Title",
                ),
              ),
              const SizedBox(height: 10),

              // Product Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Product Type",
                ),
                value: productTypeValue,
                items: productTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['label'], // Only use the 'label' for the value
                    child: Row(
                      children: [
                        Icon(type['icon'],
                            color: Color.fromARGB(255, 253, 157, 2)),
                        const SizedBox(width: 10),
                        Text(type['label']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    productTypeValue = value!;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? "Please select a product type"
                    : null, // Add validation
              ),
              const SizedBox(height: 10),

              // Product Price
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Please enter product price" : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Product Price (RM)",
                ),
              ),
              const SizedBox(height: 10),

              // Product Stock
              TextFormField(
                controller: productStockController,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Please enter product stock" : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Product Stock",
                ),
              ),
              const SizedBox(height: 10),

              // Product Description
              TextFormField(
                controller: descriptionController,
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? "Please enter product description" : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Product Description",
                ),
              ),
              const SizedBox(height: 20),

              // Insert Button
              MaterialButton(
                minWidth: pageWidth,
                height: 50,
                color: Colors.orange,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select an image"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    insertProduct();
                  }
                },
                child: const Text(
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

  void showImageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Image From"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
                child: const Text("Gallery"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
                child: const Text("Camera"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      cropImage();
    }
  }

  Future<void> cropImage() async {
    if (_image == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          toolbarColor: Colors.orange,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: "Cropper",
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
      });
    }
  }

  void insertProduct() {
    String title = titleController.text;
    String description = descriptionController.text;
    String price = priceController.text;
    String producttype = productTypeValue;
    String productstock = productStockController.text;
    String image = base64Encode(_image!.readAsBytesSync());
    http.post(
      Uri.parse("${MyConfig.servername}/simple_app/api/insert_product.php"),
      body: {
        "title": title,
        "description": description,
        "price": price,
        "producttype": producttype,
        "stock": productstock,
        "image": image
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Product added successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to add product."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
}
