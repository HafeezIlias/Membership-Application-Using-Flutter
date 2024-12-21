import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/myconfig.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  final phoneRegex = RegExp(r"^\+?[0-9]{10,14}$");
  final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6}$');

  final GoogleSignIn googleSignIn = GoogleSignIn();

  String? usernameStatus;
  String? emailStatus;
  String? phoneStatus;
  String? passwordStatus;

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Logo Simple App.png',
                  height: 120,
                  width: 180,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Username Field
                _buildTextField(
                  controller: usernameController,
                  label: 'Username',
                  icon: Icons.person,
                  onChanged: checkUsernameAvailability,
                  suffixIcon: _getStatusIcon(usernameStatus),
                ),

                const SizedBox(height: 12),

                // Email Field
                _buildTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email,
                  onChanged: checkEmailAvailability,
                  suffixIcon: _getStatusIcon(emailStatus),
                ),

                const SizedBox(height: 12),

                // Phone Number Field
                _buildTextField(
                  controller: phoneNumberController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  inputType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9()+\-\s]')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      phoneStatus = phoneRegex.hasMatch(value)
                          ? "valid"
                          : "invalid_format";
                    });
                  },
                  suffixIcon: _getStatusIcon(phoneStatus),
                ),

                const SizedBox(height: 12),

                // Password Field
                _buildPasswordField(),

                const SizedBox(height: 20),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onRegisterDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 253, 157, 2),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Google Registration Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: registerWithGoogle,
                    icon: const Icon(Icons.login, color: Color.fromARGB(255, 253, 157, 2)),
                    label: const Text(
                      'Register with Google',
                      style: TextStyle(fontSize: 16,color: Color.fromARGB(255, 253, 157, 2)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color.fromARGB(255, 253, 157, 2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Already registered? Login",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // Widget Builders
  // -------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    required Function(String) onChanged,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 253, 157, 2)),
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      maxLength: 6,
      onChanged: checkPasswordValidity,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
      ],
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Colors.orangeAccent),
        labelText: 'Password',
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
          child: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
        ),
        helperText: passwordStatus,
        helperStyle: TextStyle(
          color: passwordStatus == "Password is valid"
              ? Colors.green
              : Colors.red,
        ),
      ),
    );
  }

  Widget _getStatusIcon(String? status) {
    switch (status) {
      case "available":
        return const Icon(Icons.check_circle, color: Colors.green);
      case "unavailable":
        return const Icon(Icons.error, color: Colors.red);
      case "invalid_format":
        return const Icon(Icons.warning, color: Colors.orange);
      default:
        return const SizedBox.shrink();
    }
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
  Future<void> registerWithGoogle() async {
  try {
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      final GoogleSignInAuthentication auth = await account.authentication;

      // Send the ID token to your backend for registration
      final response = await http.post(
        Uri.parse('${MyConfig.servername}/simple_app/api/google_register.php'),
        body: {
          'id_token': auth.idToken,
        },
      );

      if (response.statusCode == 200) {
        print('Registration successful: ${response.body}');
      } else {
        print('Registration failed: ${response.body}');
      }
    }
  } catch (error) {
    print('Error during Google registration: $error');
  }
}

}
