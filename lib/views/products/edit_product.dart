import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/models/products.dart';

class EditProduct extends StatefulWidget {
  final Myproduct product;
  const EditProduct({super.key, required this.product});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  String productTypeValue = 'Electronics';
  File? _image;
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController StockController = TextEditingController();

  final List<Map<String, dynamic>> productTypes = [
    {'label': 'Electronics', 'icon': Icons.electrical_services},
    {'label': 'Clothing', 'icon': Icons.checkroom},
    {'label': 'Furniture', 'icon': Icons.chair},
    {'label': 'Books', 'icon': Icons.book},
    {'label': 'Accessories', 'icon': Icons.accessibility},
    {'label': 'Others', 'icon': Icons.more_horiz}, // Icon for 'Others'
  ];

  @override
  void initState() {
    super.initState();
    // Set initial values for the controllers from the widget's passed data
    titleController.text = widget.product.productTitle ?? '';
    descriptionController.text = widget.product.productDescription ?? '';
    priceController.text = widget.product.productPrice?.toString() ?? '';
    productTypeValue = widget.product.productType ?? 'Electronics';
    StockController.text = widget.product.productStock?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final double pageWidth = MediaQuery.of(context).size.width;
    final double pageHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
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
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: _image == null
                                ? NetworkImage(
                                    "${MyConfig.servername}/simple_app/assets/products/${widget.product.productFilename}")
                                : const AssetImage("assets/Not Found Image.png")
                                    as ImageProvider,
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
              DropdownButtonFormField(
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
                    productTypeValue =
                        value as String; // Set the selected value
                  });
                },
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
              TextFormField(
                controller: StockController,
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

              // Update Button
              MaterialButton(
                minWidth: pageWidth,
                height: 50,
                color: Colors.orange,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateProduct();
                  }
                },
                child: const Text(
                  "Update",
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

  void updateProduct() {
    String image;
    String title = titleController.text;
    String description = descriptionController.text;

    // Check if the image has been changed
    if (_image == null) {
      // Image not changed, use the existing filename
      image = "NA"; // You can send a flag like 'NA' or 'no_image'
    } else {
      // Image changed, convert it to base64
      image = base64Encode(_image!.readAsBytesSync());
    }

    http.post(
      Uri.parse("${MyConfig.servername}/simple_app/api/update_product.php"),
      body: {
        "Productid": widget.product.productId.toString(),
        "title": title,
        "description": description,
        "producttype": productTypeValue,
        "filename": widget.product.productFilename ??
            'NA', // Send existing filename if image is not changed
        "price": priceController.text,
        "stock": StockController.text,
        "image": image,
      },
    ).then((response) {
      print("Response body: ${response.body}"); // Log the response body
      if (response.statusCode == 200) {
  try {
    var data = jsonDecode(response.body);
    if (data['status'] == "success") {
      Navigator.pop(context, Myproduct(
        productId: widget.product.productId,
        productTitle: title,
        productDescription: description,
        productPrice: double.tryParse(priceController.text),
        productType: productTypeValue,
        productStock: int.tryParse(StockController.text),
        productFilename: image != "NA" ? widget.product.productFilename : widget.product.productFilename,

      ));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Update Successful"),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['data']),
        backgroundColor: Colors.red,
      ));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error decoding response: $e"),
      backgroundColor: Colors.red,
    ));
  }
} else {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Network error: ${response.statusCode}"),
    backgroundColor: Colors.red,
  ));
}
});
  }}
