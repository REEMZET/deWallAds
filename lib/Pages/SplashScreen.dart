import 'dart:async';

import 'package:dewallads/Admin/Weblogin.dart';
import 'package:dewallads/Model/UserModel.dart';
import 'package:dewallads/Pages/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';
import '../Admin/AdminDashBoard.dart';
import '../Employee/EmployeeDashboard.dart';
import '../WallOwner/DashBoard.dart';
import '../utils/Pagereplacement.dart';
import 'HomePage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);

class _SplashScreenState extends State<SplashScreen> {
  late bool isUserLoggedIn;
  late UserModel userModel;

  Future<String> getUserDetails(String userPhoneNumber) async {
    Completer<String> completer = Completer<String>();

    DatabaseReference userRef = FirebaseDatabase.instance
        .reference()
        .child('deWall')
        .child('User')
        .child(userPhoneNumber);
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
        setState(() {
          userModel = UserModel(
            name: data['name'] ?? '',
            phonenumber: data['phonenumber'] ?? '',
            uid: data['uid'] ?? '',
            deviceId: data['deviceid'] ?? '',
            regDate: data['regdate'] ?? '',
            city: data['city'] ?? '',
            state: data['state'] ?? '',
            accounttype: data['accounttype'] ?? '',
          );
          completer.complete(userModel.accounttype);
        });
      }
    });

    return completer.future;
  }

  Future<void> navigate() async {
    String accountType = await getUserDetails(phoneNumber!);

    Future.delayed(Duration(seconds: 1), () {
      if (accountType == 'wallowner') {
        Navigator.pushReplacement(context, customPagereplaceRoute(Dashboard()));
      } else if (accountType == 'admin') {
        Navigator.pushReplacement(
            context, customPagereplaceRoute(AdminDashboard()));
      } else if (accountType == 'employee') {
        Navigator.pushReplacement(
            context, customPagereplaceRoute(EmployeeDashboard()));
      } else {
        Navigator.pushReplacement(context, customPagereplaceRoute(HomePage()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isUserLoggedIn = FirebaseAuth.instance.currentUser != null;
    userModel = UserModel(
      name: '',
      phonenumber: '',
      uid: '',
      deviceId: '',
      regDate: '',
      city: '',
      state: '',
      accounttype: '',
    );
    if (isUserLoggedIn) {
      User? user = FirebaseAuth.instance.currentUser;
      var externalId = user!.uid
          .toString(); // You will supply the external id to the OneSignal SDK
      OneSignal.login(externalId);
      OneSignal.User.pushSubscription.optIn();
      if (kIsWeb) {
        Navigator.pushReplacement(context, customPagereplaceRoute(WebEmployeeDashboard()));
      } else {
        navigate();
      }

    } else {
      Future.delayed(Duration(seconds: 2), () {
        if (kIsWeb) {
          Navigator.pushReplacement(context, customPagereplaceRoute(SignInScreen(accouunttype: 'employee')));
        } else {
          Navigator.pushReplacement(context, customPagereplaceRoute(HomePage()));
        }
       
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(
              'assets/images/logo.png', // Path to your icon image
              width: 200,
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Text(
                'Welcome to deWall Ads',
                style: TextStyle(color: Colors.white),
              )),
            )
          ]),
        ),
      ),
    );
  }
}
