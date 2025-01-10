import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:simple_app/models/user.dart';
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/views/events/events_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewEventsPage extends StatefulWidget {
  final User user;
  const NewEventsPage({super.key, required this.user});

  @override
  State<NewEventsPage> createState() => _NewEventsPageState();
}

class _NewEventsPageState extends State<NewEventsPage> {
  String startDateTime = "", endDateTime = "";
  String eventtypevalue = 'Conference';
  var selectedStartDateTime, selectedEndDateTime;
  String? selectedValue;

  final List<Map<String, dynamic>> items = [
    {'label': 'Conference', 'icon': Icons.people_alt},
    {'label': 'Exhibition', 'icon': Icons.art_track},
    {'label': 'Seminar', 'icon': Icons.school},
    {'label': 'Hackathon', 'icon': Icons.computer},
  ];
  late double pageWidth, pageHeight;

  File? _image;

  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    pageHeight = MediaQuery.of(context).size.height;
    pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text("New Event"),
          backgroundColor: const Color.fromARGB(255, 253, 157, 2),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Form(
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
                      height: 10,
                    ),
                    TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? "Please Enter Title" : null,
                        controller: titleController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            labelText: "Event Title")),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          child: Column(
                            children: [
                              const Text("Select Start Date"),
                              Text(startDateTime)
                            ],
                          ),
                          onTap: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2030),
                            ).then((selectedDate) {
                              if (selectedDate != null) {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((selectTime) {
                                  if (selectTime != null) {
                                    selectedStartDateTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectTime.hour,
                                      selectTime.minute,
                                    );
                                    print(selectedStartDateTime.toString());
                                    var formatter =
                                        DateFormat('dd-MM-yyyy hh:mm a');
                                    String formattedDate =
                                        formatter.format(selectedStartDateTime);
                                    startDateTime = formattedDate.toString();
                                    setState(() {});
                                  }
                                });
                              }
                            });
                          },
                        ),
                        GestureDetector(
                          child: Column(
                            children: [
                              const Text("Select End Date"),
                              Text(endDateTime)
                            ],
                          ),
                          onTap: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2030),
                            ).then((selectedDate) {
                              if (selectedDate != null) {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((selectTime) {
                                  if (selectTime != null) {
                                    selectedEndDateTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectTime.hour,
                                      selectTime.minute,
                                    );
                                    var formatter =
                                        DateFormat('dd-MM-yyyy hh:mm a');
                                    String formattedDate =
                                        formatter.format(selectedEndDateTime);
                                    endDateTime = formattedDate.toString();
                                    print(endDateTime);
                                    setState(() {});
                                  }
                                });
                              }
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? "Enter Location" : null,
                        controller: locationController,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  getPositionDialog();
                                },
                                icon: Icon(Icons.location_on)),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            labelText: "Event Location")),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        labelText: 'Event Type',
                      ),
                      value: selectedValue,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: items.map((item) {
                        return DropdownMenuItem(
                          value: item['label'], // Use the label as the value
                          child: Row(
                            children: [
                              Icon(
                                item['icon'], // Icon from the list
                                color: const Color.fromARGB(255, 253, 157, 2),
                              ),
                              const SizedBox(
                                  width: 8), // Space between the icon and text
                              Text(item['label']), // Display the label
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue =
                              newValue as String?; // Update the selected value
                        });
                        print('Selected: $selectedValue');
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? "Enter Description" : null,
                        controller: descriptionController,
                        maxLines: 10,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            labelText: "Event Description")),
                    const SizedBox(height: 10),
                    MaterialButton(
                      elevation: 10,
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          print("STILL HERE");
                          return;
                        }
                        if (_image == null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Please take a photo"),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }
                        double filesize = getFileSize(_image!);
                        print(filesize);

                        if (filesize > 100) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Image size too large"),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }

                        if (startDateTime == "" || endDateTime == "") {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Please select start/end date"),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }

                        insertEventDialog();
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
              )
            ])));
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
                      fixedSize: Size(pageWidth / 4,
                          pageHeight / 8)),
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
                      fixedSize: Size(pageWidth / 4,
                          pageHeight / 8)),
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

  double getFileSize(File file) {
    int sizeInBytes = file.lengthSync();
    double sizeInKB = (sizeInBytes / (1024 * 1024)) * 1000;
    return sizeInKB;
  }

  void insertEventDialog() {
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
                  insertEvent();
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EventsPage(user: widget.user)),
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

  void insertEvent() {
    String title = titleController.text;
    String location = locationController.text;
    String description = descriptionController.text;
    String start = selectedStartDateTime.toString();
    String end = selectedEndDateTime.toString();
    String image = base64Encode(_image!.readAsBytesSync());
    // log(image);
    http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/insert_event.php"),
        body: {
          "title": title,
          "location": location,
          "description": description,
          "eventtype": eventtypevalue,
          "start": start,
          "end": end,
          "image": image
        }).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // log(response.body);
        if (data['status'] == "success") {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Insert Success"),
            backgroundColor: Colors.green,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Insert Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Location not found"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    String address = "${placemarks[0].name}, ${placemarks[0].country}";
    print(address);
    locationController.text = address;
    setState(() {
      print(position.latitude);
      print(position.longitude);
    });
  }

  void getPositionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text(
            "Get Location From:",
            style: TextStyle(),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    determinePosition();
                  },
                  icon: const Icon(
                    Icons.location_on,
                    size: 60,
                  )),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _selectfromMap();
                  },
                  icon: const Icon(
                    Icons.map,
                    size: 60,
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectfromMap() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Location not found"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final Completer<GoogleMapController> mapcontroller =
        Completer<GoogleMapController>();

    CameraPosition defaultLocation = CameraPosition(
      target: LatLng(
        position.latitude,
        position.longitude,
      ),
      zoom: 14.4746,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text("Select Location"),
            content: SizedBox(
                height: pageHeight,
                width: pageWidth,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: defaultLocation,
                  onMapCreated: (controller) =>
                      mapcontroller.complete(controller),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                )));
      },
    );
  }
}
