import 'dart:convert';
import 'package:email_otp/email_otp.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_app/myconfig.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/views/main_page.dart';
import 'package:simple_app/views/register_page.dart';

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
  String userEmail = '';


  bool rememberme = false;
  String verificationMessage = '';
  Color verificationColor = Colors.black;

  String lastSnackBarMessage = '';


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
                obscureText: true,
                controller: passwordcontroller,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  prefixIconColor: Color.fromARGB(255, 253, 157, 2),
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              Row(
                children: [
                  const Text("Remember me"),
                  Checkbox(
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
                      if (isOtpSent)
                        Column(
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
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        if (!isOtpSent) {
                          sendOtp(emailcontroller.text);
                        } else {
                          verifyOtpAndResetPassword();
                        }
                      },
                      child: Text(isOtpSent ? "Verify and Reset Password" : "Send OTP"),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text("Forgot Password?"),
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
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/login_user.php"),
        body: {
          "identifier": identifier,
          "password": password
        }, // Use 'identifier' instead of 'email'
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login Success"),
            backgroundColor: Colors.green,
          ));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (content) => const MainPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
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
  void sendOtp(email) async {
    EmailOTP.config(
      appName: "MyMemberLink",
      otpLength: 6,
    );

    bool sent = await EmailOTP.sendOTP(email: email);
    if (sent) {
      setState(() {
        isOtpSent = true;
        userEmail = email;
      });
      Fluttertoast.showToast(msg: "OTP has been sent to $email");
    } else {
      Fluttertoast.showToast(msg: "Failed to send OTP");
    }
  }

  void verifyOtpAndResetPassword() async {
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();

    bool isVerified = EmailOTP.verifyOTP(otp: otp);
    if (isVerified) {
      // Call PHP API to reset password
      resetPassword(userEmail, newPassword);
    } else {
      Fluttertoast.showToast(msg: "Invalid OTP. Please try again.");
    }
  }

  void resetPassword(String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('${MyConfig.servername}/simple_app/api/reset_password.php'),
      body: {
        "email": email,
        "new_password": newPassword,
      },
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      Fluttertoast.showToast(msg: responseData['message']);
    } else {
      Fluttertoast.showToast(msg: "Failed to connect to the server.");
    }
  }

}
