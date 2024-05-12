import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Model/UserModel.dart';
import 'Join Page.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);

class _ProfileState extends State<Profile> {
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

  Future<void> callusesr() async {
    String accountType = await getUserDetails(phoneNumber!);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
    callusesr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Profile',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'), // Add the user's profile image URL
              ),
              SizedBox(height: 20),
              Text(
                'Name: ${userModel.name}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Phone Number: ${userModel.phonenumber}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'City: ${userModel.city}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'State: ${userModel.state}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  logoutAndRestartApp(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black54, // Set button color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void logoutAndRestartApp(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const JoinPage(),
      ),
    );
  }
}
