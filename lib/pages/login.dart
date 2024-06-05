
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:evitecompanion/config/app.dart';
import 'package:evitecompanion/config/appstyle.dart';
import 'package:evitecompanion/services/login.service.dart';
import 'package:evitecompanion/utils/regex.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert' as convert;

import 'package:localstorage/localstorage.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final googleSignIn = GoogleSignIn(
    clientId: Platform.isAndroid ? 
      "806960755412-ht29qt2ha16hoolgerifn9jep9lcc7hl.apps.googleusercontent.com"
      : "806960755412-fllksc6o8bdf44965ae2qcrteqcgbp9p.apps.googleusercontent.com",
    signInOption: SignInOption.standard,
    scopes: ['email']
  );
  final formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoaded = true;

  void onLoginAttempt() {
    if (!isLoaded) {
      return;
    }
    setState(() {
      isLoaded = false;
    });
    var isValid = formKey.currentState?.validate();
    if (isValid != null && isValid) {
      LoginService.loginAttempt(userNameController.text, passwordController.text)
      .then((result) {
        if (result.statusCode != 200) {
            _showSnackbar('Invalid username or password.');
            return;
        }

        setState(() {
          isLoaded = true;
        });
        var jsonResponse = convert.jsonDecode(result.body) as Map<String, dynamic>;
        var data = JwtDecoder.decode(jsonResponse['token'] ?? '');

        // if (data.keys.contains('IsOrganizer')) {
        //   if (data['IsOrganizer'] != 'True') {
        //     // Error
        //     _showErrorDialog();
        //   } else {
        //     localStorage.setItem('isGoogle', 'false');
        //     localStorage.setItem("accessToken", jsonResponse['token']);
        //     localStorage.setItem("userData", json.encode(data));
        //     Navigator.pushNamed(context, '/eventSelection');
        //   }
        // } else {
        //   // Error
        //   _showErrorDialog();
        // }

        localStorage.setItem('isGoogle', 'false');
        localStorage.setItem("accessToken", jsonResponse['token']);
        localStorage.setItem("userData", json.encode(data));
        Navigator.pushNamed(context, '/eventSelection');
      })
      .catchError((err) {
        setState(() {
          isLoaded = true;
        });
        _showSnackbar('Invalid username or password.');
      });
    } 
    else {
      setState(() {
        isLoaded = true;
      });
    }
  }

  void onLoginGoogleAttempt(BuildContext context, String? gaccessToken) {
    if (gaccessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: AppStyle.snackBar,
        content: Text('Failed to login with Google (code 0x03)', style: TextStyle(color: AppStyle.snackBarText))
      ));
      return;
    }

    LoginService.loginGoogleAttempt(gaccessToken)
      .then((result) {
        if (result.statusCode != 200) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: AppStyle.snackBar,
              content: Text('Failed to login with Google (code 0x04)', style: TextStyle(color: AppStyle.snackBarText))
            ));
            return;
        }

        var jsonResponse = convert.jsonDecode(result.body) as Map<String, dynamic>;

        if (jsonResponse["error"] == true) {   
          googleSignIn.signOut();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppStyle.snackBar,
            content: Text(jsonResponse["errorMessage"], style: const TextStyle(color: AppStyle.snackBarText))
          ));
          return;
        }

        var data = JwtDecoder.decode(jsonResponse['token'] ?? '');

        // if (data.keys.contains('IsOrganizer')) {
        //   if (data['IsOrganizer'] != 'True') {
        //     // Error
        //     _showErrorDialog();
        //   } else {
        //     localStorage.setItem('isGoogle', 'true');
        //     localStorage.setItem("accessToken", jsonResponse['token']);
        //     localStorage.setItem("userData", json.encode(data));
        //     Navigator.pushNamed(context, '/eventSelection');
        //   }
        // } else {
        //   // Error
        //   googleSignIn.signOut();
        //   _showErrorDialog();
        // }

        localStorage.setItem('isGoogle', 'true');
        localStorage.setItem("accessToken", jsonResponse['token']);
        localStorage.setItem("userData", json.encode(data));
        Navigator.pushNamed(context, '/eventSelection');
      })
      .catchError((error) {
        googleSignIn.signOut();
        var message = 'Failed to login with Google (code 0x05)';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppStyle.snackBar,
          content: Text(message, style: const TextStyle(color: AppStyle.snackBarText))
        ));
      });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppStyle.snackBar,
      content: Text(message, style: const TextStyle(color: AppStyle.snackBarText))
    ));
  }

  Future<void> _showErrorDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                SizedBox(
                  child: Image.asset('assets/images/error403.jpg', alignment: Alignment.center, fit: BoxFit.contain),
                ),
                const Text('Looks like you are not an organizer', 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 31, 31, 31),
                    fontWeight: FontWeight.bold,
                  )
                )
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              }, 
              child: const Text('Close')
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 1.8,
                  child: Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/loginbg.jpg'),
                      
                      ),
                    ),
                    child: OverflowBox(
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(221, 26, 17, 17),
                                    Color.fromARGB(103, 39, 9, 9)
                                  ]
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("| ${App.title}", style: TextStyle(
                                  fontSize: (MediaQuery.of(context).size.width / 1.8) / 8,
                                  fontWeight: FontWeight.w100,
                                  color: Colors.white
                                )),
                                Text("     Digital Transformation Office", style: TextStyle(
                                  fontSize: (MediaQuery.of(context).size.width / 1.8) / 18,
                                  fontWeight: FontWeight.w100,
                                  color: Colors.white
                                ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                //
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: userNameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email, color: Colors.grey, size: 18),
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(),
                            focusedBorder:  OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Input email address.';
                            }
                            else if (!Regex.emailRegex.hasMatch(text)) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.grey, size: 18),
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            border: OutlineInputBorder(),
                            focusedBorder:  OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                          ),
                          obscureText: true,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Password field is required.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: onLoginAttempt,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyle.buttonColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                            
                              children: [
                                if (!isLoaded)  ...const [
                                 SizedBox(
                                    height: 20,
                                    width: 20,
                                    child:  CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 1
                                      ,
                                    ),
                                 ),
                                  SizedBox(width: 10)
                                ],
                                
                                const Text('Login', style: TextStyle(color: Colors.white))
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 50, thickness: 1, color: Colors.grey),
                        // login with google
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              var ctx = context;
                              googleSignIn.signIn()
                                .then((value) {
                                  if (value == null) {
                                    return;
                                  }
                                  value.authentication.then((auth) {
                                    onLoginGoogleAttempt(ctx, (auth.idToken != null) ? auth.idToken : auth.accessToken);
                                  })
                                  .catchError((error) {
                                    _showSnackbar('Failed to login with Google (code 0x02)');
                                  });
                                })
                                .catchError((error) {
                                  _showSnackbar('Failed to login with Google (code 0x01)');
                                });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/google.png', width: 20, height: 20),
                                const SizedBox(width: 10),
                                const Text('Signin with Google', style: TextStyle(color: Color.fromARGB(255, 37, 35, 35)))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

   @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

