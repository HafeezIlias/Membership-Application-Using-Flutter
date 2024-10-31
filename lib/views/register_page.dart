import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/myconfig.dart';
import 'dart:async';


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

  final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"); //email format
  final phoneRegex = RegExp(r"^\+?[0-9]{10,14}$"); //phone number format
  final passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6}$'); //password format which only allow letter and umber

  String? usernameStatus; // status of the username
  String? emailStatus; // status of the email
  String? phoneStatus;
  String? passwordStatus;

  bool isPasswordVisible = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

    @override
  void dispose() {
    // Cancel the debounce timer if it’s still running
    _debounce?.cancel();
    super.dispose();
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
    if (value.isEmpty) {
      if (emailStatus != null) {
        setState(() {
          emailStatus = null; // Reset icon if field is empty
        });
      }
    } else if (!emailRegex.hasMatch(value)) {
      if (emailStatus != "invalid_format") {
        setState(() {
          emailStatus = "invalid_format"; // Show invalid format status
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email format"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      checkEmailAvailability(value); // Check availability if format is valid
    }
  },
  decoration: InputDecoration(
    labelText: 'Email',
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    suffixIcon: emailStatus == null
        ? null
        : (emailStatus == "available"
            ? const Icon(Icons.check_circle, color: Colors.green)
            : (emailStatus == "unavailable"
                ? const Icon(Icons.error, color: Colors.red)
                : (emailStatus == "invalid_format"
                    ? const Icon(Icons.warning, color: Colors.orange)
                    : const Icon(Icons.error, color: Colors.grey)))),
  ),
),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9()+\-\s]')),
                  ],
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        phoneStatus = null; // Reset icon if field is empty
                      });
                    } else if (!phoneRegex.hasMatch(value)) {
                      setState(() {
                        phoneStatus =
                            "invalid_format"; // Show invalid format status
                      });
                    } else {
                      setState(() {
                        phoneStatus = "valid"; // Valid format
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    suffixIcon: phoneStatus == null
                        ? null
                        : (phoneStatus == "valid"
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : (phoneStatus == "invalid_format"
                                ? const Icon(Icons.warning,
                                    color: Colors.orange)
                                : const Icon(Icons.error, color: Colors.grey))),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
          controller: passwordController,
          obscureText: !isPasswordVisible, // Hide/show password based on isPasswordVisible
          keyboardType: TextInputType.visiblePassword,
          maxLength: 6, // Limits input to 6 characters
          onChanged: checkPasswordValidity,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), // Allows only alphanumeric characters
          ],
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            helperText: passwordStatus,
            helperStyle: TextStyle(
              color: passwordStatus == "Password is valid"
                  ? Colors.green
                  : Colors.red,
            ),
            suffixIcon: GestureDetector(
              onLongPress: () {
                setState(() {
                  isPasswordVisible = true;
                });
              },
              onLongPressUp: () {
                setState(() {
                  isPasswordVisible = false;
                });
              },
              child: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
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
  // Check if email is empty and reset status
  if (email.isEmpty) {
    setState(() {
      emailStatus = null;
    });
    return;
  }

  // Regular expression for email format validation
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(email)) {
    // Update status to invalid format
    setState(() {
      emailStatus = "invalid_format";
    });
    
    // Show "Invalid Format" SnackBar only if not previously shown
    if (emailStatus != "invalid_format") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Format"),
          backgroundColor: Colors.red,
        ),
      );
    }
    return; // Exit early if format is invalid
  }

  // Proceed to check email availability if format is valid
  try {
    final response = await http.post(
      Uri.parse("${MyConfig.servername}/simple_app/api/verify_login.php"),
      body: {"email": email},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['email'] != null && data['email']['status'] == 'success') {
        if (emailStatus != "unavailable") {
          setState(() {
            emailStatus = "unavailable";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email is unavailable. Try a different one."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() {
          emailStatus = "available";
        });
      }
    } else {
      setState(() {
        emailStatus = "error";
      });
    }
  } catch (e) {
    debugPrint("Error checking email availability: $e");
    setState(() {
      emailStatus = "error";
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

  void checkPasswordValidity(String value) {
    setState(() {
      if (value.length < 6) {
        passwordStatus = "Password must be 6 characters";
      } else if (!passwordRegex.hasMatch(value)) {
        passwordStatus = "Password must contain letters and numbers";
      } else {
        passwordStatus = "Password is valid";
      }
    });
  }
  
}
