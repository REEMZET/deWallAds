import 'dart:async';

import 'package:dewallads/Employee/EmployeeDashboard.dart';
import 'package:dewallads/WallOwner/DashBoard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';
import '../Admin/AdminDashBoard.dart';
import '../Admin/Weblogin.dart';
import '../Model/UserModel.dart';
import '../utils/Pagereplacement.dart';
import '../widgetui/TextSlider.dart';
import 'HomePage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInScreen extends StatefulWidget {
  final String accouunttype;

  const SignInScreen({super.key, required this.accouunttype});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool otpSent = false;
  late String _phoneNumber = "";
  late String _verificationId;
  late String _otp;
  late String buttontext = 'GET OTP';
  late String _name;
  late String _city;
  late String _state;
  late String _accounttype;
  late String token;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await GoogleSignIn().signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in the user with the credential
        final UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = authResult.user;
        Fluttertoast.showToast(
          msg: 'Success login with google',
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
        );
        _pushUserModelToRealtimeDBbygooglesign(user!);

      }
    } catch (error) {
      print('$error');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  final FocusNode _otpFocusNode = FocusNode();

  Future<void> _verifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
      _pushUserModelToRealtimeDB();
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Failed: $e')));
      print('Verification Failed: $e');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, int? resendToken) async {
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {};

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending verification code: $e')));
      print('Error sending verification code: $e');
    }
  }


  Future<void> verify() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otp,
      );

      // Sign in the user using the credential
      await _auth.signInWithCredential(credential);
      _pushUserModelToRealtimeDB();

    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error verifying OTP: $e',
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
      );
    }
  }

  void _pushUserModelToRealtimeDBbygooglesign(User user) async {

    var externalId = user.uid.toString(); // You will supply the external id to the OneSignal SDK
    OneSignal.login(externalId);
    OneSignal.User.pushSubscription.optIn();
    token = externalId;
    UserModel model;
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('d/M/yy').format(currentDate);

    if(_accounttype=='employee'){
      model = UserModel(
          name: user.displayName.toString(),
          phonenumber: user.phoneNumber.toString(),
          uid: user.uid.toString(),
          deviceId: token.toString(),
          regDate: formattedDate,
          city: 'Pata',
          state: 'Bihar',
          accounttype: 'Not Verified Employee'
      );
    }else{
      model = UserModel(
          name: user.displayName.toString(),
          phonenumber: user.phoneNumber.toString(),
          uid: user.uid.toString(),
          deviceId: token.toString(),
          regDate: formattedDate,
          city: 'Patna',
          state: 'Bihar',
          accounttype: _accounttype
      );
    }


    String phoneNumber = user.phoneNumber.toString();
    final DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('deWall').child('User').child(phoneNumber);

    usersRef.onValue.listen((event) async {
      final udata = event.snapshot.value;
      if (udata != null) {
        if (kIsWeb) {
          Navigator.pushReplacement(context, customPagereplaceRoute(WebEmployeeDashboard()));
        }else{
          if (_accounttype == 'company') {
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false);
          } else if (_accounttype == 'wallowner') {
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (context) => const Dashboard()),
                    (route) => false);
          } else if (_accounttype == 'admin') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()));
          } else if (_accounttype == 'employee') {
            if(event.snapshot.child('accounttype').value.toString()!='employee'){
              Fluttertoast.showToast(
                msg: 'Please verify by Admin contact to dewall',
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.green,
              );
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
            }else{
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeDashboard()));
            }
          }
        }


      } else {
        print('usernot exit');
        try {
          Map<String, dynamic> userMap = model.toMap();
          await usersRef.update(userMap).then((_) {
            if (_accounttype == 'company') {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const HomePage()));
            } else if (_accounttype == 'wallowner') {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Dashboard()));
            } else if (_accounttype == 'admin') {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const AdminDashboard()));
            } else if (_accounttype == 'employee') {
              Fluttertoast.showToast(
                msg: 'Please verify by Admin contact to dewall',
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.green,
              );
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
            }
            Fluttertoast.showToast(
              msg: 'Account Created',
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.green,
            );
          });

        } catch (e) {
          Fluttertoast.showToast(
            msg: 'Error $e',
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.green,
          );
        }
      }
    });
  }

  void _pushUserModelToRealtimeDB() async {
    User? user = FirebaseAuth.instance.currentUser;
    var externalId = user!.uid.toString(); // You will supply the external id to the OneSignal SDK
    OneSignal.login(externalId);
    OneSignal.User.pushSubscription.optIn();
    token = externalId;
    UserModel model;
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('d/M/yy').format(currentDate);

    if(_accounttype=='employee'){
      model = UserModel(
          name: _name,
          phonenumber: _phoneNumber.substring(3, 13),
          uid: user.uid.toString(),
          deviceId: token.toString(),
          regDate: formattedDate,
          city: _city,
          state: _state,
          accounttype: 'Not Verified Employee'
      );
    }else{
      model = UserModel(
          name: _name,
          phonenumber: _phoneNumber.substring(3, 13),
          uid: user.uid.toString(),
          deviceId: token.toString(),
          regDate: formattedDate,
          city: _city,
          state: _state,
          accounttype: _accounttype
      );
    }


    String phoneNumber = _phoneNumber.substring(3, 13);
    final DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('deWall').child('User').child(phoneNumber);

    usersRef.onValue.listen((event) async {
      final udata = event.snapshot.value;
      if (udata != null) {
        if (kIsWeb) {
          Navigator.pushReplacement(context, customPagereplaceRoute(WebEmployeeDashboard()));
        }else{
          if (_accounttype == 'company') {
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false);
          } else if (_accounttype == 'wallowner') {
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (context) => const Dashboard()),
                    (route) => false);
          } else if (_accounttype == 'admin') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()));
          } else if (_accounttype == 'employee') {
            if(event.snapshot.child('accounttype').value.toString()!='employee'){
              Fluttertoast.showToast(
                msg: 'Please verify by Admin contact to dewall',
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.green,
              );
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
            }else{
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeDashboard()));
            }
          }
        }


      } else {
        print('usernot exit');
        try {
          Map<String, dynamic> userMap = model.toMap();
          await usersRef.update(userMap).then((_) {
            if (_accounttype == 'company') {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const HomePage()));
            } else if (_accounttype == 'wallowner') {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Dashboard()));
            } else if (_accounttype == 'admin') {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const AdminDashboard()));
            } else if (_accounttype == 'employee') {
              Fluttertoast.showToast(
                msg: 'Please verify by Admin contact to dewall',
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.green,
              );
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
              }
            Fluttertoast.showToast(
              msg: 'Account Created',
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.green,
            );
          });

        } catch (e) {
          Fluttertoast.showToast(
            msg: 'Error $e',
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.green,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _accounttype = widget.accouunttype;

    return Scaffold(
      backgroundColor:Colors.transparent ,
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Login to deWallads',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
        ),
      ),
      body:  Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  width: double.infinity,
                ),
                const Text(
                  'Sign_In',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 4),
                    child: Column(
                      children: [
                        const Text(
                          'Account Details',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        widget.accouunttype == 'company'
                            ? SizedBox(
                          height: 50,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Company Name',
                              labelText: 'Company Name',
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              prefixIcon: Icon(
                                Icons.add_business,
                                color: Colors.indigo,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurple, width: 2),
                                // Change border color here
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white,
                                    width:
                                    1.5), // Change border color here
                              ),
                              counterText: '',
                            ),
                            onChanged: (value) {
                              _name = value;
                            },
                            maxLength: 25,
                          ),
                        )
                            : SizedBox(
                          height: 50,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Enter your name',
                              labelText: 'Enter your name',
                              hintStyle: TextStyle(
                                  color: Colors.white, fontSize: 12),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.indigo,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurple, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white, width: 1.5),
                              ),
                              counterText: '',
                            ),
                            onChanged: (value) {
                              _name = value;
                            },
                            maxLength: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Enter State',
                              labelText: 'Enter State',
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              prefixIcon: Icon(
                                Icons.warehouse_rounded,
                                color: Colors.indigo,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurple, width: 2),
                                // Change border color here
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white,
                                    width: 1.5), // Change border color here
                              ),
                              counterText: '',
                            ),
                            onChanged: (value) {
                              _state = value;
                            },
                            maxLength: 25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Enter City',
                              labelText: 'Enter City',
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              prefixIcon: Icon(
                                Icons.location_city,
                                color: Colors.indigo,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurple, width: 2),
                                // Change border color here
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white,
                                    width: 1.5), // Change border color here
                              ),
                              counterText: '',
                            ),
                            onChanged: (value) {
                              _city = value;
                            },
                            maxLength: 25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          child: TextField(
                            enabled: buttontext == 'GET OTP',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Enter Mobile number',
                              labelText: 'Mobile number',
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              prefixIcon: Icon(
                                Icons.phone_android,
                                color: Colors.indigo,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurple, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.white, width: 1.5),
                              ),
                              counterText: '',
                            ),
                            onChanged: (value) {
                              _phoneNumber = '+91$value';
                            },
                            maxLength: 10,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        if (otpSent) // Only show OTP text field when OTP is sent
                          SizedBox(
                            height: 50,
                            child: TextField(
                              focusNode: _otpFocusNode,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Enter Otp',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(),
                                counterText: '',
                              ),
                              onChanged: (value) {
                                _otp = value;
                              },
                              maxLength: 6,
                            ),
                          ),
                        ElevatedButton(
                          onPressed: () async {
                            if (buttontext == 'GET OTP') {
                              if (_phoneNumber.length == 13) {
                                setState(() {
                                  buttontext = 'Sending OTP';
                                });
                                try {
                                  await _verifyPhoneNumber();
                                  await Future.delayed(const Duration(seconds: 4));
                                  setState(() {
                                    buttontext = 'Verify OTP';
                                    otpSent = true; // Set OTP sent state
                                  });
                                  _otpFocusNode.requestFocus();
                                } catch (e) {
                                  print('Error sending OTP: $e');
                                  setState(() {
                                    buttontext = 'GET OTP';
                                  });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Invalid phone number')),
                                );
                              }
                            } else {
                              if (_otp.length == 6) {
                                setState(() {
                                  buttontext = 'Verifying OTP';
                                });
                                try {
                                  await verify();
                                  setState(() {
                                    buttontext = 'OTP Verified';
                                  });
                                } catch (e) {
                                  print('Error verifying OTP: $e');
                                  setState(() {
                                    buttontext = 'Verify OTP';
                                  });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Invalid otp')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Colors.blue, // Set background color to blue
                          ),
                          child: buttontext == 'Sending OTP' ||
                              buttontext == 'Verifying OTP'
                              ? const CircularProgressIndicator() // Show progress indicator
                              : Text(
                            buttontext,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                       SignInButton(onPressed: (){_signInWithGoogle();}, buttonType: ButtonType.google,),
                        InkWell(
                          child: const Text(
                            '-------Skip sign-------',
                            style: TextStyle(
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                          onTap: () {
                            if (!kIsWeb) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()),
                              );
                            }

                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: const TextSlider(
                    textItems: [
                      'Welcome to deWall Ads – transformative advertising experiences',
                      '"Open the door to advertising excellence – log in to deWall Ads and revolutionize your brand story!"',
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();
    super.dispose();
  }
}
