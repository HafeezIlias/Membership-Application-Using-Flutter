import 'dart:convert';
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
  bool rememberme = false;
  String verificationMessage = '';
  Color verificationColor = Colors.black;

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
                color: const Color.fromARGB(255, 253, 157, 2),
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
                  labelText: 'Email',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  suffixIcon: verificationMessage.isNotEmpty
                      ? Icon(
                          verificationMessage == 'Email is verified'
                              ? Icons.check_circle
                              : Icons.error,
                          color: verificationColor,
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    verifyEmail(value); // Verify email on input change
                  } else {
                    _updateVerificationStatus('', Colors.black); // Reset on empty input
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
    String email = emailcontroller.text;
    String password = passwordcontroller.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter email and password"),
      ));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/login_user.php"),
        body: {"email": email, "password": password},
        
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
  Future<void> verifyEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/verify_email.php"),
        body: {"email": email},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _updateVerificationStatus('Email is verified', Colors.green);
        } else {
          _updateVerificationStatus('Email does not exist', Colors.red);
        }
      } else {
        _updateVerificationStatus('Server error', Colors.red);
        print('server error');
      }
    } catch (e) {
      debugPrint("Error: $e");
      _updateVerificationStatus('Network error', Colors.red);
    }
  }

  // Method to update verification status
  void _updateVerificationStatus(String message, Color color) {
    setState(() {
      verificationMessage = message;
      verificationColor = color;
    });
  }

}
