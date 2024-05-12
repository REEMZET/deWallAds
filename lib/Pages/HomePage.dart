import 'dart:convert';
import 'dart:math';

import 'package:dewallads/Company/BulkOrder.dart';
import 'package:dewallads/Company/EnquiryList.dart';
import 'package:dewallads/Employee/EmployeeDashboard.dart';
import 'package:dewallads/Model/GeoapiRespose.dart';
import 'package:dewallads/Model/wallPosterModel.dart';
import 'package:dewallads/Pages/AboutDewall.dart';
import 'package:dewallads/Pages/ExploreCity.dart';
import 'package:dewallads/Pages/ExploredeWalls.dart';
import 'package:dewallads/Pages/Join%20Page.dart';
import 'package:dewallads/Pages/Profile.dart';
import 'package:dewallads/Pages/Searchwallposter.dart';
import 'package:dewallads/Pages/Support.dart';
import 'package:dewallads/Pages/Termsandcondition.dart';
import 'package:dewallads/Pages/deWallList.dart';
import 'package:dewallads/WallOwner/AddWall.dart';
import 'package:dewallads/WallOwner/DashBoard.dart';
import 'package:dewallads/widgetui/HomeWidget/TopdeWall.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'package:url_launcher/url_launcher.dart';

import '../Model/UserModel.dart';
import '../main.dart';
import '../utils/CircularProgress.dart';
import '../utils/Pagerouter.dart';
import '../widgetui/HomeWidget/Nearby deWall.dart';
import '../widgetui/HomeWidget/PosterUi.dart';
import '../widgetui/HomeWidget/TopLocationmenu.dart';
import '../widgetui/HomeWidget/Welcomtext.dart';
import '../widgetui/HomeWidget/sizemenu.dart';
import '../widgetui/RoundButton.dart';
import 'PosterDetails.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, Key});

  @override
  State<HomePage> createState() => _HomePageState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late bool isUserLoggedIn;
  String _currentAddress = " ";
  Position? _currentPosition;
  bool _isLoading = false;
  late UserModel userModel;
  String searchText = "";
  List<WallPosterModel> featuredwallPosters = [];
  DatabaseReference ref =
      FirebaseDatabase.instance.reference().child('deWall/walls');

  Future<void> _getCurrentPosition() async {
    // Check and request location permission
    final permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        setState(() {
          _currentPosition = position;
          fetchData();
          _isLoading = false; // Hide loading indicator
        });
      } catch (e) {
        debugPrint("Error getting current position: $e");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
    }
  }

  Future<void> fetchData() async {
    String latitude = _currentPosition!.latitude.toString();
    String longitude = _currentPosition!.longitude.toString();
    //final url = 'https://geocode.maps.co/reverse?lat=$latitude&lon=$longitude';
    final url='https://geocode.maps.co/reverse?lat=$latitude&lon=$longitude&api_key=658cdae25cc15835570082neaecb947';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final geoApiResponse =
          ApiResponse.fromJson(jsonResponse); // Use your ApiResponse class here

      final address = geoApiResponse.address;
      setState(() {
        _currentAddress = address.stateDistrict;
        _isLoading = true;
      });
    } else {
      setState(() {
        _currentAddress = 'Error: ${response.statusCode}';
      });
    }
  }

  void getUserDetails(String userPhoneNumber) {
    DatabaseReference userRef = FirebaseDatabase.instance
        .reference()
        .child('deWall')
        .child('User')
        .child(userPhoneNumber);
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
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
      }
    });
  }

  @override
  void initState() {
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
    isUserLoggedIn = FirebaseAuth.instance.currentUser != null;
    _getCurrentPosition();
    if (isUserLoggedIn) {
      getUserDetails(phoneNumber!);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black12));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/walllogo.png',
              height: 40,
              width: 40,
            ),
            const SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'deWall Ads',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.amber,
                    ),
                    Text(
                      _currentAddress,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
      floatingActionButton: userModel.accounttype == 'wallowner'
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, customPageRoute(Dashboard()));
        },
        tooltip: 'Add Wall',
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue, // Set the background color to blue
      )
          : null,


      drawer: SafeArea(child: userModel.accounttype=='company'? buildCompanyDrawer():buildOwnerDrawer()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Welcometext(),
                  const SizedBox(height: 8),
                  buildSearchWidget(),
                  const SizedBox(height: 25),
                  const Text(
                    'deWall by Size',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(height: 50, child: WallSizeWidget()),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured deWall',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              customPageRoute(
                                  const ExploredeWalls(cateogory: 'Featured')));
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text(
                            'explore',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(height: 150, child: featuredwall()),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Top deWall',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              customPageRoute(const ExploredeWalls(
                                  cateogory: 'TopdeWalls')));
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text(
                            'explore',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(height: 120, child: topdewall()),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Top City deWall',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context, customPageRoute(const ExploreCity()));
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text(
                            'explore',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(height: 95, child: topCityDeWall()),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Explore nearby deWall',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              customPageRoute(deWallList(
                                node: 'city',
                                value: _currentAddress,
                              )));
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text(
                            'explore',
                            style: TextStyle(fontSize: 10, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: _isLoading
                        ? nearbydeWalls()
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
            Footer()
          ],
        ),
      ),
    );
  }

  Widget buildSearchWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 50, top: 15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.grey[100],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.search,
                color: Colors.black87,
                size: 15,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: "Search location...",
                    border: InputBorder.none,
                  ),
                  onTap: () {
                    Navigator.push(
                        context, customPageRoute(const SearchdeWall()));
                  }, // Callback when the text changes
                ),
              ),
              const Icon(
                Icons.arrow_circle_right_outlined,
                size: 15,
                color: Colors.black87,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget featuredwall() {
    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query: ref.orderByChild("cateogory").equalTo('Featured').limitToFirst(5),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        final data = snapshot.value;
        if (data != null && data is Map) {
          String city = data['city'].toString();
          String wallid = data['wallid'].toString();

          List<String> photosUrl = [];
          if (data['photosUrl'] != null && data['photosUrl'] is List) {
            photosUrl = List<String>.from(data['photosUrl']);
          }
          Widget childWidget;
          if (photosUrl.isNotEmpty) {
            int randomIndex = Random().nextInt(photosUrl.length);
            childWidget = PosterItem(
              onPressed: () {
                Navigator.push(
                    context, customPageRoute(PosterDetails(wallid: wallid)));
              },
              imageUrl: photosUrl[randomIndex],
            );
          } else {
            childWidget = const SizedBox();
          }

          return SizeTransition(
            sizeFactor: animation,
            child: childWidget,
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget topdewall() {
    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query: ref.orderByChild("cateogory").equalTo('TopdeWalls').limitToFirst(5),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        final data = snapshot.value;
        if (data != null && data is Map) {
          String city = data['city'].toString();
          String wallSize = data['wallSize'].toString();
          String available = data['available'].toString();
          String cateogory = data['cateogory'].toString();
          String wallRentPrice = data['wallRentPrice'].toString();
          String wallid = data['wallid'].toString();
          String title = data['title'].toString();
          List<String> photosUrl = [];

          if (data['photosUrl'] != null && data['photosUrl'] is List) {
            photosUrl = List<String>.from(data['photosUrl']);
          }

          Widget childWidget;
          if (photosUrl.isNotEmpty) {
            // Generate a random index within the range of the photosUrl list
            int randomIndex = Random().nextInt(photosUrl.length);
            childWidget = TopdeWall(
              charges: wallRentPrice,
              imageUrl: photosUrl[randomIndex],
              title: title,
              size: wallSize,
              location: city,
              onPressed: () {
                Navigator.push(
                    context, customPageRoute(PosterDetails(wallid: wallid)));
              },
            );
          } else {
            childWidget =
                const SizedBox(); // or another default widget if the list is empty
          }
          return SizeTransition(
            sizeFactor: animation,
            child: childWidget,
          );
        }

        return const SizedBox(); // Return an empty container if data is not in the expected format.
      },
    );
  }

  Widget topCityDeWall() {
    Set<String> uniqueCities = <String>{};

    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query: ref.orderByChild('city').limitToFirst(20),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        final data = snapshot.value;
        if (data != null && data is Map) {
          String city = data['city'].toString();
          if (!uniqueCities.contains(city)) {
            uniqueCities.add(city);
            return Toplocationmenu(
              icon: Icons.location_city,
              label: city,
              onPressed: () {
                Navigator.push(
                    context,
                    customPageRoute(deWallList(
                      node: 'city',
                      value: city,
                    )));
              },
            );
          }
        }

        return const SizedBox(); // Return an empty container if data is not in the expected format or if the city is a repetition.
      },
    );
  }

  Widget nearbydeWalls() {
    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query: ref.orderByChild("city").equalTo(_currentAddress).limitToFirst(2),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        final data = snapshot.value;

        if (data != null && data is Map) {
          String city = data['city'].toString();
          String wallSize = data['wallSize'].toString();
          String available = data['available'].toString();
          String cateogory = data['cateogory'].toString();
          String wallRentPrice = data['wallRentPrice'].toString();
          String title = data['title'].toString();
          String wallid = data['wallid'].toString();
          List<String> photosUrl = [];

          if (data['photosUrl'] != null && data['photosUrl'] is List) {
            photosUrl = List<String>.from(data['photosUrl']);
          }

          Widget childWidget;

          if (photosUrl.isNotEmpty) {
            // Generate a random index within the range of the photosUrl list
            int randomIndex = Random().nextInt(photosUrl.length);
            childWidget = NearbydeWall(
              charges: wallRentPrice,
              imageUrl: photosUrl[randomIndex],
              title: title,
              size: wallSize,
              location: city,
              onPressed: () {
                Navigator.push(
                    context, customPageRoute(PosterDetails(wallid: wallid)));
              },
            );
          } else {
            childWidget =
                const SizedBox(); // or another default widget if the list is empty
          }

          return SizeTransition(
            sizeFactor: animation,
            child: childWidget,
          );
        }

        return SizedBox();// Return an empty container if data is not in the expected format.
      },
    );
  }

  Widget WallSizeWidget() {
    Set<String> uniqueSizes = <String>{};
    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query: ref.orderByChild('wallSize').limitToFirst(50),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        final data = snapshot.value;

        if (data != null && data is Map) {
          String wallSize = data['wallSize'].toString();

          // Check if the city is not already added to the set
          if (!uniqueSizes.contains(wallSize)) {
            uniqueSizes.add(wallSize);
            return OvalMenuItem(
              icon: Icons.addchart_sharp,
              label: wallSize,
              onPressed: () {
                Navigator.push(
                    context,
                    customPageRoute(deWallList(
                      node: 'wallSize',
                      value: wallSize,
                    )));
              },
            );
          }
        }

        return const SizedBox(); // Return an empty container if data is not in the expected format or if the city is a repetition.
      },
    );
  }


  Widget buildCompanyDrawer() {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      width: 240,
      child: ListView(
        children: [
          Container(
              color: Colors.blue,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 130,
                    width: 100,
                  ),
                  Text(
                    'deWall ads',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                ],
              )),
          buildDrawerItem('Bulk Order', Icons.local_shipping, () {
            // Handle Package menu item
            Navigator.pop(context); // Close the drawer
            Navigator.push(context, customPageRoute(BulkOrder()));
          }),
          buildDrawerItem('Enquiry', Icons.question_answer, () {
            Navigator.pop(context);
            isUserLoggedIn
                ? Navigator.push(context, customPageRoute(EnquiryList()))
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinPage(),
                    ),
                  );
            // Close the drawer
          }),
          buildDrawerItem('Profile', Icons.supervised_user_circle_outlined, () {
            Navigator.pop(context);
            isUserLoggedIn
                ? Navigator.push(context, customPageRoute(Profile()))
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinPage(),
                    ),
                  );
            // Close the drawer
          }),
          buildDrawerItem('Support', Icons.support, () {
            Navigator.pop(context);
            Navigator.push(context, customPageRoute(SupportPage()));
            // Close the drawer
          }),
          buildDrawerItem(
            isUserLoggedIn ? 'Logout' : 'Login',
            Icons.logout,
            () {
              if (isUserLoggedIn) {
                logoutAndRestartApp(context);
                showLoadingDialog(context, 2);
                Navigator.pop(context);
                setState(() {
                  isUserLoggedIn = false;
                });
              } else {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinPage(),
                  ),
                ).then((value) {
                  /*setState(() {
                    isUserLoggedIn = true;
                  });*/
                });
              }
            },
          ),


          buildDrawerItem('Terms and Conditions', Icons.description, () {
            Navigator.pop(context); // Close the drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InAppWebViewPage(
                  url: 'https://doc-hosting.flycricket.io/dewall-ads-terms-of-use/492b6606-b611-49be-96b9-68abcfef03c6/terms', // Replace with your URL
                ),
              ),
            );
          }),
          buildDrawerItem('Privacy_policy', Icons.description, () {
            Navigator.pop(context); // Close the drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InAppWebViewPage(
                  url: 'https://doc-hosting.flycricket.io/dewall-ads-privacy-policy/1f42ee3d-02bc-4191-b69b-70875d30449a/privacy', // Replace with your URL
                ),
              ),
            );
          }),
          buildDrawerItem('About deWall Ads', Icons.info, () {
            // Handle 'About deWall Ads' menu item
            Navigator.pop(context);
            Navigator.push(context, customPageRoute(AboutDewall()));
          }),

          buildDrawerItem('About Developer', Icons.developer_mode_rounded, () {
            Navigator.pop(context); // Close the drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InAppWebViewPage(
                  url: 'https://reemzetdeveloper.in/', // Replace with your URL
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildOwnerDrawer() {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      width: 240,
      child: ListView(
        children: [
          Container(
              color: Colors.blue,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 130,
                    width: 100,
                  ),
                  Text(
                    'deWall ads',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                ],
              )),
          buildDrawerItem('Dashboard', Icons.dashboard, () {
            // Handle Package menu item
            Navigator.pop(context);
            if(isUserLoggedIn) {
              if (userModel.accounttype == 'wallowner') {
                Navigator.push(context, customPageRoute(Dashboard()));
              }
              else if (userModel.accounttype == 'employee') {
                Navigator.push(context, customPageRoute(EmployeeDashboard()));
              } else {
                Fluttertoast.showToast(
                  msg: 'Please verify by Admin contact to dewall',
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.green,
                );
              }
            }

          }),

          buildDrawerItem('Profile', Icons.supervised_user_circle_outlined, () {
            Navigator.pop(context);
            isUserLoggedIn
                ? Navigator.push(context, customPageRoute(Profile()))
                : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const JoinPage(),
              ),
            );
            // Close the drawer
          }),
          buildDrawerItem('Support', Icons.support, () {
            Navigator.pop(context);
            Navigator.push(context, customPageRoute(SupportPage()));
            // Close the drawer
          }),
          buildDrawerItem(
            isUserLoggedIn ? 'Logout' : 'Login',
            Icons.logout,
                () {
              if (isUserLoggedIn) {
                logoutAndRestartApp(context);
                showLoadingDialog(context, 2);
                Navigator.pop(context);
                setState(() {
                  isUserLoggedIn = false;
                });
              } else {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinPage(),
                  ),
                ).then((value) {
                  /*setState(() {
                    isUserLoggedIn = true;
                  });*/
                });
              }
            },
          ),

          buildDrawerItem('Terms and Conditions', Icons.description, () {
            Navigator.pop(context); // Close the drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InAppWebViewPage(
                  url: 'https://doc-hosting.flycricket.io/dewall-ads-terms-of-use/492b6606-b611-49be-96b9-68abcfef03c6/terms', // Replace with your URL
                ),
              ),
            );
          }),
          buildDrawerItem('Privacy_policy', Icons.description, () {
            Navigator.pop(context); // Close the drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InAppWebViewPage(
                  url: 'https://doc-hosting.flycricket.io/dewall-ads-privacy-policy/1f42ee3d-02bc-4191-b69b-70875d30449a/privacy', // Replace with your URL
                ),
              ),
            );
          }),
          buildDrawerItem('About deWall Ads', Icons.info, () {
            // Handle 'About deWall Ads' menu item
            Navigator.pop(context);
            Navigator.push(context, customPageRoute(AboutDewall()));
          }),
          buildDrawerItem('About Developer', Icons.developer_mode_rounded, () {
            Navigator.pop(context); // Close the drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InAppWebViewPage(
                  url: 'https://reemzetdeveloper.in/', // Replace with your URL
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildDrawerItem(String title, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          height: 40,
          child: ListTile(
            title: Text(title, style: TextStyle(color: Colors.blue)),
            leading: Icon(icon, color: Colors.blue),
            onTap: onTap,
            dense: true,
          ),
        ),
        Divider(color: Colors.black12), // Add a Divider below the ListTile
      ],
    );
  }

  Widget Footer() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.white],
          // Specify the gradient colors
          end: Alignment.topCenter,
          // Set the gradient start position
          begin: Alignment.bottomCenter, // Set the gradient end position
        ),
      ),
      child: Column(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    height: 90,
                  ),
                  const Text(
                    'About Us',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Welcome to deWall Ads, your ultimate destination for revolutionizing the advertising industry. '
                      'We address critical challenges faced by businesses and political parties in selecting ideal '
                      'locations for promoting their services and messages. Our innovative solutions extend beyond traditional advertising, '
                      'offering a platform for property owners to rent their walls for promotional purposes.',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'At deWall Ads, our mission is to provide a comprehensive advertising solution that bridges the gap between businesses and '
                      'their target audiences. We strive to empower companies and political entities to enhance their visibility and '
                      'reach by utilizing prime locations. Through a blend of physical and digital advertising, '
                      'we aim to transform busy areas into effective marketing canvases.',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Contact Info',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                      child: Align(
                        alignment: Alignment.center,
                        child:Text(
                          'Address: Building no-22, Darbhanga, Bihar-847103',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14, // Adjust the font size as needed
                            fontWeight: FontWeight.bold, // Apply bold style
                            fontStyle: FontStyle.italic, // Apply italic style
                            letterSpacing: 0.5, // Adjust letter spacing as needed
                          ),
                        )

                      )),
                  const Text('Mobile: +91 7281887889',style: TextStyle(fontWeight: FontWeight.bold),),
                  const Text('Email: contact.dewall@gmail.com',style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundIconButton(
                    containerheight: 40,
                    containerwidth: 40,
                    iconsize: 15,
                    icon: FontAwesomeIcons.youtube,
                    // YouTube icon
                    color: Colors.red,
                    onPressed: () {
                      openyt();
                    },
                  ),
                  RoundIconButton(
                    containerheight: 40,
                    containerwidth: 40,
                    iconsize: 15,
                    icon: Icons.web_outlined,
                    color: Colors.indigo,
                    onPressed: () {
                  openweb();
                    },
                  ),

                  RoundIconButton(
                    containerheight: 40,
                    containerwidth: 40,
                    iconsize: 15,
                    icon: FontAwesomeIcons.linkedin,
                    color: Colors.blue,
                    onPressed: () {
                      openlinkedin();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          const Align(
              alignment: Alignment.center,
              child: Text('Copyright © 2023 deWall ads. All rights reserved.')),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }


  void logoutAndRestartApp(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    runApp(MyApp());
  }
  openlinkedin() async{
    var linkedinurl = "https://www.linkedin.com/company/dewallads/";
    await launch(linkedinurl);
  }
  openyt() async{
    var yturl = "http://www.youtube.com/@deWallads";
    await launch(yturl);
  }
  openweb() async{
    var weburl = "http://www.dewallads.com/";
    await launch(weburl);
  }


  @override
  void dispose() {
    super.dispose();
  }
}
