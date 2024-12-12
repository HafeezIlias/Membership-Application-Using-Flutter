import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:simple_app/models/myevent.dart';
import 'package:simple_app/myconfig.dart';

class EditEventsPage extends StatefulWidget {
  final MyEvent myevent;

  const EditEventsPage({super.key, required this.myevent});

  @override
  State<EditEventsPage> createState() => _EditEventsPageState();
}

class _EditEventsPageState extends State<EditEventsPage> {
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
  late double PageWidth, PageHeight;

  File? _image;

  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController.text = widget.myevent.eventTitle.toString();
    descriptionController.text = widget.myevent.eventDescription.toString();
    locationController.text = widget.myevent.eventLocation.toString();
    eventtypevalue = widget.myevent.eventType.toString();
    var formatter = DateFormat('dd-MM-yyyy hh:mm a');
    // String formattedDate = formatter.format(selectedStartDateTime);
    startDateTime = formatter
        .format(DateTime.parse(widget.myevent.eventStartdate.toString()));
    endDateTime = formatter
        .format(DateTime.parse(widget.myevent.eventEnddate.toString()));
  }

  @override
  Widget build(BuildContext context) {
    PageHeight = MediaQuery.of(context).size.height;
    PageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Event"),
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
                                fit: BoxFit.fill,
                                image: _image == null
                                    ? NetworkImage(
                                        "${MyConfig.servername}/simple_app/assets/events/${widget.myevent.eventFilename}")
                                    : FileImage(_image!) as ImageProvider),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey),
                          ),
                          height: PageHeight * 0.4),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? "Enter Title" : null,
                        controller: titleController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            hintText: "Event Title")),
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
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            hintText: "Event Location")),
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
                  color:const Color.fromARGB(255, 253, 157, 2),
                ),
                const SizedBox(width: 8), // Space between the icon and text
                Text(item['label']), // Display the label
              ],
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedValue = newValue as String?; // Update the selected value
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
                        if (_image != null) {
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
                        }
                        if (startDateTime == "" || endDateTime == "") {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Please select start/end date"),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }

                        updateEventDialog();
                      },
                      minWidth: PageWidth,
                      height: 50,
                      color: const Color.fromARGB(255, 253, 157, 2), // Uses primary color from theme
                      child: Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.white, // Text color matches onPrimary color
                        ),
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
                      fixedSize: Size(PageWidth / 4, PageHeight / 8)),
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
                      fixedSize: Size(PageWidth / 4, PageHeight / 8)),
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
      // setState(() {
      //   _image = File(pickedFile.path);
      // });
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
    print("BEFORE CROP: ");
    print(getFileSize(_image!));
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      // setState(() {
      //   _image = File(pickedFile.path);
      // });
      cropImage();
    } else {}
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Please Crop Your Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
      print(getFileSize(_image!));
      setState(() {});
    }
  }

  double getFileSize(File file) {
    int sizeInBytes = file.lengthSync();
    double sizeInKB = (sizeInBytes / (1024 * 1024)) * 1000;
    return sizeInKB;
  }

  void updateEventDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: const Text(
              "Update Event",
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
                  updateEvent();
                  Navigator.of(context).pop();
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

  void updateEvent() {
    String image;
    String title = titleController.text;
    String location = locationController.text;
    String description = descriptionController.text;
    String start = selectedStartDateTime.toString();
    String end = selectedEndDateTime.toString();
    if (_image == null) {
      image = "NA";
    } else {
      image = base64Encode(_image!.readAsBytesSync());
    }

    if (start == "null") {
      start = "NA";
    }
    if (end == "null") {
      end = "NA";
    }
    // log(image);
    http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/update_event.php"),
        body: {
          "eventid": widget.myevent.eventId.toString(),
          "title": title,
          "location": location,
          "description": description,
          "eventtype": eventtypevalue,
          "start": start,
          "end": end,
          "filename":widget.myevent.eventFilename,
          "image": image
        }).then((response) {
      if (response.statusCode == 200) {
         var data = jsonDecode(response.body);
        //  log(response.body);
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
}