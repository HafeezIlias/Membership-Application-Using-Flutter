import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/myconfig.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  String?
      usernameStatus; // Use a String to represent the status of the username
  String? emailStatus; // Use a String to represent the status of the username

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Logo Simple App.png',
                  height: 150,
                  width: 200,
                  color: const Color.fromARGB(255, 253, 157, 2),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: Align(
                    alignment: const AlignmentDirectional(-1, 0),
                    child: Text(
                      'Create your Account',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                TextField(
                  controller: usernameController,
                  onChanged: (value) {
                    checkUsernameAvailability(
                        value); // Check availability on input change
                  },
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    suffixIcon: usernameStatus == null
                        ? null
                        : (usernameStatus == "available"
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : (usernameStatus == "unavailable"
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.error,
                                    color: Colors
                                        .grey))), // Indicate error if applicable
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  onChanged: (value) {
                    checkEmailAvailability(
                        value); // Check availability on input change
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    suffixIcon: emailStatus == null
                        ? null
                        : (emailStatus == "available"
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : (emailStatus == "unavailable"
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.error,
                                    color: Colors
                                        .grey))), // Indicate error if applicable
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                    controller: phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    )),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MaterialButton(
                    elevation: 10,
                    onPressed: onRegisterDialog,
                    minWidth: 400,
                    height: 50,
                    color: const Color.fromARGB(255, 253, 157, 2),
                    child: const Text("Register",
                        style: TextStyle(color: Colors.white))),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Already registered? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onRegisterDialog() {
    String email = emailController.text;
    String password = passwordController.text;
    String username = usernameController.text;
    String phoneNumber = phoneNumberController.text;

    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter all credentials"),
        backgroundColor: Colors.red,
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
            "Register new account?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                userRegistration();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Registration Canceled"),
                  backgroundColor: Colors.red,
                ));
              },
            ),
          ],
        );
      },
    );
  }

  void userRegistration() async {
    String email = emailController.text;
    String password = passwordController.text;
    String username = usernameController.text;
    String phoneNumber = phoneNumberController.text;

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/register_user.php"),
        body: {
          "email": email,
          "password": password,
          "username": username,
          "phoneNum": phoneNumber
        },
      );
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Registration Successful"),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context); // Go back to login screen
      } else {
        // Show specific server error message (e.g., duplicate email/username)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message'] ?? "Registration failed"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Network error. Please try again."),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> checkEmailAvailability(String email) async {
    if (email.isEmpty) {
      setState(() {
        emailStatus = null; // Reset to null if the input is empty
      });
      return; // Exit the function if there's no input
    }

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/verify_login.php"),
        body: {"email": email},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['email'] != null && data['email']['status'] == 'success') {
          setState(() {
            emailStatus = "unavailable"; // Username is not available
          });
        } else {
          setState(() {
            emailStatus = "available"; // Username is  available
          });
        }
      } else {
        // Handle server error
        setState(() {
          emailStatus = "error"; // Indicate a server error
        });
      }
    } catch (e) {
      debugPrint("Error checking email availability: $e");
      setState(() {
        emailStatus = "error"; // Indicate a network error
      });
    }
  }

  Future<void> checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      setState(() {
        usernameStatus = null; // Reset to null if the input is empty
      });
      return; // Exit the function if there's no input
    }

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/verify_login.php"),
        body: {"username": username},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['username'] != null &&
            data['username']['status'] == 'success') {
          setState(() {
            usernameStatus = "unavailable"; // Username is not available
          });
        } else {
          setState(() {
            usernameStatus = "available"; // Username is  available
          });
        }
      } else {
        // Handle server error
        setState(() {
          usernameStatus = "error"; // Indicate a server error
        });
      }
    } catch (e) {
      debugPrint("Error checking username availability: $e");
      setState(() {
        usernameStatus = "error"; // Indicate a network error
      });
    }
  }
}
