import 'package:dewallads/Pages/SplashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBAUl5NT5WOUqc3Sngq6o7xn99B2ehcQEE",
          authDomain: "dewall-7.firebaseapp.com",
          databaseURL: "https://dewall-7-default-rtdb.firebaseio.com",
          projectId: "dewall-7",
          storageBucket: "dewall-7.appspot.com",
          messagingSenderId: "325164339395",
          appId: "1:325164339395:web:16ee2a65de366470e25276",
          measurementId: "G-V26GY2DWDL"));
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//Remove this method to stop OneSignal Debugging
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("bbe4c4df-2829-4e6e-91fd-3c97c11fbbc1");
  OneSignal.Notifications.requestPermission(true);


  if (kIsWeb) {
    
  } else {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }

  runApp(const MyApp());
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'deWall ads',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen());
  }
}
