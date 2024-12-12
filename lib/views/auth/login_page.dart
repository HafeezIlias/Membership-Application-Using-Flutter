import 'dart:convert';
import 'package:email_otp/email_otp.dart';
import 'package:simple_app/myconfig.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/views/main_page.dart';
import 'package:simple_app/views/auth/register_page.dart';
import 'package:simple_app/views/shared/mydrawer.dart';
import 'package:simple_app/global.dart' as globals;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  late bool isOtpSent = false;
  bool isPasswordVisible = false;
  String userEmail = '';

  bool rememberme = false;
  String verificationMessage = '';
  Color verificationColor = Colors.black;

  String lastSnackBarMessage = '';
  String username='';

  @override
  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Logo Simple App.png',
                height: 150,
                width: 200,                
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Align(
                  alignment: const AlignmentDirectional(-1, 0),
                  child: Text(
                    'Login to your Account',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              TextField(
                controller: emailcontroller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  prefixIconColor: const Color.fromARGB(255, 253, 157, 2),
                  labelText: 'Email/Username',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  suffixIcon: verificationMessage.isNotEmpty
                      ? Icon(
                          verificationMessage == 'Verified'
                              ? Icons.check_circle
                              : Icons.error,
                          color: verificationColor,
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    verifyIdentifier(
                        value); // Verify email or username on input change
                  } else {
                    _updateVerificationStatus(
                        '', Colors.black); // Reset on empty input
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                obscureText: !isPasswordVisible,
                controller: passwordcontroller,
                decoration:  InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  prefixIconColor: const Color.fromARGB(255, 253, 157, 2),
                  labelText: 'Password',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
              Row(
                children: [
                  const Text("Remember me"),
                  Checkbox(
                    activeColor: const Color.fromARGB(255, 253, 157, 2),

                    value: rememberme,
                    onChanged: (bool? value) {
                      setState(() {
                        rememberme = value ?? false;
                        if (rememberme) {
                          
                          if (emailcontroller.text.isNotEmpty &&
                              passwordcontroller.text.isNotEmpty) {
                            storeSharedPrefs(rememberme, emailcontroller.text,
                                passwordcontroller.text);
                          } else {
                            rememberme = false;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Please enter your credentials"),
                              backgroundColor: Colors.red,
                            ));
                          }
                        } else {
                          storeSharedPrefs(false, "", "");
                        }
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: MaterialButton(
                    elevation: 10,
                    onPressed: onLogin,
                    minWidth: 400,
                    height: 50,
                    color: const Color.fromARGB(255, 253, 157, 2),
                    child: const Text("Login",
                        style: TextStyle(color: Colors.white))),
              ),            
              GestureDetector(
                onTap: () {
                  showEmailInputDialog();
                },
                child: const Text("Forgot Password",),
              ),            
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (content) => const RegisterPage()));
                },
                child: const Text("Create new account?"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onLogin() async {
  String identifier = emailcontroller.text; // Either email or username
  String password = passwordcontroller.text;

  if (identifier.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Please enter email/username and password"),
    ));
    return;
  }

  try {
    final response = await http
        .post(
          Uri.parse("${MyConfig.servername}/simple_app/api/login_user.php"),
          body: {
            "identifier": identifier,
            "password": password
          }, // Use 'identifier' instead of 'email'
        )
        .timeout(const Duration(seconds: 10)); // Set a timeout for the request

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
if (data['status'] == "success") {
        // Safely extract user data with null-checks
        globals.userId = data['data']['user_id'] ?? 'No user ID'; 
        globals.username = data['data']['username'] ?? 'Guest'; // Fallback if 'user_id' is not present
        String? usernameFromApi = data['data']['username'];
        String username = usernameFromApi ?? 'Guest';  // Fallback to 'Guest' if username is null
        
        // Print user data
        print('User ID: ${globals.userId}');
        print('Username: $username');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Login Success"),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (content) => MainPage(username: username)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Login Failed"),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      // Handle non-200 response status
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${response.statusCode} - ${response.body}"),
        backgroundColor: Colors.red,
      ));
    }
  } catch (e) {
    // Log error for debugging
    print("Error during login: $e");

    // Network or timeout error
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Network error. Please try again."),
      backgroundColor: Colors.red,
    ));
  }
}



  void storeSharedPrefs(bool value, String email, String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      prefs.setString("email", email);
      prefs.setString("password", pass);
      prefs.setBool("rememberme", value);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Stored"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));
    } else {
      prefs.remove("email");
      prefs.remove("password");
      prefs.setBool("rememberme", value);
      emailcontroller.text = "";
      passwordcontroller.text = "";
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Removed"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailcontroller.text = prefs.getString("email") ?? '';
    passwordcontroller.text = prefs.getString("password") ?? '';
    rememberme = prefs.getBool("rememberme") ?? false;
    setState(() {});
  }

// Updated method to verify email or username
  Future<void> verifyIdentifier(String value) async {
    bool isEmail = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(value); // checking if it follow format of email

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/verify_login.php"),
        body: isEmail ? {"email": value} : {"username": value},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (isEmail && data['email']['status'] == 'success') {
          _updateVerificationStatus('Verified', Colors.green);
          lastSnackBarMessage = ''; // Reset since it's a success
        } else if (!isEmail && data['username']['status'] == 'success') {
          _updateVerificationStatus('Verified', Colors.green);
          lastSnackBarMessage = ''; // Reset since it's a success
        } else {
          _updateVerificationStatus('Not Exist', Colors.red);
          if (lastSnackBarMessage != 'Email or Username not exist') {
            lastSnackBarMessage = 'Email or Username not exist';
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Email or Username not exist'),
              backgroundColor: Colors.red,
            ));
          }
        }
      } else {
        _updateVerificationStatus('Server error', Colors.red);
        if (lastSnackBarMessage != 'Server error') {
          lastSnackBarMessage = 'Server error';
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Server error'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      _updateVerificationStatus('Network error', Colors.red);
      if (lastSnackBarMessage != 'Network error') {
        lastSnackBarMessage = 'Network error';
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Network error'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }


// Method to update verification status
  void _updateVerificationStatus(String message, Color color) {
    setState(() {
      verificationMessage = message;
      verificationColor = color;
    });
  }
void showEmailInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Forgot Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailcontroller,
                decoration: const InputDecoration(labelText: 'Enter your email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                sendOtp(emailcontroller.text);
              },
              child: const Text("Send OTP"),
            ),
          ],
        );
      },
    );
  }
  Future<void> sendOtp(String email) async {
    // Simulate sending OTP
    EmailOTP.config(
    appName: 'MyMemberLink',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v4,
  );
  if (await EmailOTP.sendOTP(email: emailcontroller.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("OTP has been sent")));                   
                    showOtpAndResetDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("OTP failed sent")));
              }
  }
            
  void showOtpAndResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                verifyOtpAndResetPassword();
              },
              child: const Text("Verify and Reset Password"),
            ),
          ],
        );
      },
    );
  
  }
  Future<void> verifyOtpAndResetPassword() async {
    bool isValid = EmailOTP.verifyOTP(otp: otpController.text);
    if (isValid) {
      updateNewPassword();
      Navigator.of(context).pop();     
    } else {
      showErrorDialog("Invalid OTP. Please try again.");
    }
  }
void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("Your password has been reset successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
  void updateNewPassword() async {

    final String email = emailcontroller.text;
    final String newPassword = newPasswordController.text;

     try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/reset_password.php"),
        body: {
          "email": email,
          "new_password": newPassword
        },
      );
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Update New Password Successful"),
          backgroundColor: Colors.green,
        ));
        showSuccessDialog();  // Go back to login screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message'] ?? "Update failed"),
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
}