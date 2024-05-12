import 'dart:async';

import 'package:dewallads/Company/EnquiryList.dart';
import 'package:dewallads/Pages/Join%20Page.dart';
import 'package:dewallads/widgetui/HomeWidget/Nearby%20deWall.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../Model/UserModel.dart';
import '../utils/DailogProgress.dart';
import '../utils/Pagerouter.dart';
import '../widgetui/NotificationWidget/OneSignalNotificationwithoutimage.dart';

class PosterDetails extends StatefulWidget {
  final String wallid;

  const PosterDetails({super.key, required this.wallid});

  @override
  State<PosterDetails> createState() => _PosterDetailsState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
UserModel? userModel;
late YoutubePlayerController _controller;
late List<String> uidlist;
bool isUserLoggedIn() {
  return FirebaseAuth.instance.currentUser != null;
}

class _PosterDetailsState extends State<PosterDetails> {
  DatabaseReference wallref = FirebaseDatabase.instance.reference().child('deWall/walls');

  List<String>? photosUrl;
  List<String>? wallgeocord;
  late String title, wallSize, city, latitude, longitude, postDate,
      postedBy, postedByUserPhone, postedByUsername, videoUrl,
      viewCount, wallLocation, wallRentPrice;

  bool loading = true;
  bool isExpanded = false;
  bool _isMuted = false;
  Future<void> getWallData(String wallid) async {
    DataSnapshot dataSnapshot = await wallref.child(wallid).get();
    if (dataSnapshot.value != null) {
      dynamic photosUrlValue = dataSnapshot.child('photosUrl').value;
      if (photosUrlValue is List<dynamic>) {
        photosUrl = List<String>.from(
            photosUrlValue.map((dynamic item) => item.toString()));
      }
      int currentViewCount = int.parse(dataSnapshot.child('viewCount').value.toString());
      wallref.child(wallid).child('viewCount').set(currentViewCount + 1);
      title = dataSnapshot.child('title').value.toString();
      latitude = dataSnapshot
          .child('locationCoordinates')
          .child('latitude')
          .value
          .toString();
      longitude = dataSnapshot
          .child('locationCoordinates')
          .child('longitude')
          .value
          .toString();
      postDate = dataSnapshot.child('postDate').value.toString();
      postedBy = dataSnapshot.child('postedBy').value.toString();
      postedByUserPhone =
          dataSnapshot.child('postedByUserPhone').value.toString();
      postedByUsername =
          dataSnapshot.child('postedByUsername').value.toString();
      videoUrl = dataSnapshot.child('videoUrl').value.toString();
      viewCount = dataSnapshot.child('viewCount').value.toString();
      wallLocation = dataSnapshot.child('wallLocation').value.toString();
      wallRentPrice = dataSnapshot.child('wallRentPrice').value.toString();
      wallSize = dataSnapshot.child('wallSize').value.toString();
      city = dataSnapshot.child('city').value.toString();

      setState(() {
        loading = false;
        _controller = YoutubePlayerController(
          initialVideoId: videoUrl,
          flags: const YoutubePlayerFlags(
            autoPlay: false,

            loop: true,
            mute: false,
          ),
        );
      });
    } else {
      print('No data found for wall ID: $wallid');
    }
  }

  String blurPhoneNumber(String originalPhoneNumber) {
    int blurLength = 5; // Number of digits to blur

    if (originalPhoneNumber.length > blurLength) {
      // Keep the first digits unchanged, replace the last ones with asterisks
      String blurredDigits = '*' * blurLength;
      return originalPhoneNumber.replaceRange(
          originalPhoneNumber.length - blurLength,
          originalPhoneNumber.length,
          blurredDigits);
    }
    return originalPhoneNumber; // Return the original number if it has less than or equal to 5 digits
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

  Future<void> getAdminUid() async {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('deWall/uid');
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data is String) {
        uidlist = data.split(',');
        for (var uid in uidlist) {
          print(uid);
        }
      } else {
        print('Invalid data format');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getWallData(widget.wallid);
      getAdminUid();
    if (user != null) {
      getUserDetails(phoneNumber!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('deWall Details',
            style: TextStyle(fontSize: 15, color: Colors.white)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : ExpandableCarousel.builder(
                          itemCount: photosUrl?.length ?? 0,
                          itemBuilder: (BuildContext context, int itemIndex,
                                  int pageViewIndex) =>
                              Container(
                            margin: const EdgeInsets.all(5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photosUrl![itemIndex],
                                fit: BoxFit.fill,
                                height: 200,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const SizedBox(
                                      width: 130,
                                      height: 120,
                                      child: Center(
                                        child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator()),
                                      ),
                                    );
                                  }
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder.png',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          options: CarouselOptions(
                            aspectRatio: 16 / 9,
                            viewportFraction: 1.0,
                          ),
                        ),
                  const SizedBox(height: 10),
                  Text(
                    "$title🔥",
                    maxLines: null,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 0.75),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 13),
                        child: Row(
                          children: [
                            const Icon(Icons.remove_red_eye,
                                size: 12, color: Colors.blue),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                "views:-$viewCount",
                                maxLines: null,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.ads_click,
                                size: 13, color: Colors.green),
                            Text("postedDate:-${postDate.substring(0, 11)}", maxLines: null, textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 130,
                    child: tabledata(wallSize, city, wallRentPrice),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15, top: 8),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Location Details:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 27, top: 4, right: 4),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: '$wallLocation ',
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 4, right: 4),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4, top: 8),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Owner Details:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 4),
                            child: Text(
                              'Uploaded By: $postedByUsername',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Phone Number: ${blurPhoneNumber(postedByUserPhone)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isUserLoggedIn()) {
                          if(userModel!.accounttype=='company'){
                            bool exists = await checkUserEnquiryExist(
                                phoneNumber!, widget.wallid);
                            if (exists) {
                              Fluttertoast.showToast(
                                msg: 'Enquiry already sent',
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 2,
                                backgroundColor: Colors.green,
                              );
                              Navigator.push(
                                  context, customPageRoute(const EnquiryList()));
                            } else {
                              sendEnquiry();
                            }
                          }else{
                            Fluttertoast.showToast(
                              msg: 'you can not send Enquiry',
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.green,
                            );
                          }

                        } else {
                          Navigator.push(
                              context, customPageRoute(const JoinPage()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text('Enquiry Now', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, top: 4, bottom: 4),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'deWalls Video',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.solid,
                            fontSize: 14),
                      ),
                    ),
                  ),
                  videoUrl.length < 20
                      ? Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15, right: 15),
                            height: 360,
                            width: 220,
                            child: YoutubePlayer(
                              controller: _controller,
                              showVideoProgressIndicator: false,
                              aspectRatio: 16 / 9,
                              onReady: () {
                                _controller.mute();
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  // Toggle mute/unmute
                                  if (_isMuted) {
                                    _controller.unMute();
                                  } else {
                                    _controller.mute();
                                  }
                                  setState(() {
                                    _isMuted = !_isMuted;
                                  });
                                },
                                icon: Icon(
                                  _isMuted ? Icons.volume_off : Icons.volume_up,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                      : Text('waitig for conversion'),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, top: 4, bottom: 4),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'More deWalls',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  Recomendations(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget tabledata(String wallsize, String city, String rate) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: '''
           <!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 20px;
    }

    th, td {
      border: 1px solid #ddd;
      padding: 8px;
      text-align: left;
    }

    th {
      background-color: #f2f2f2;
    }
  </style>
</head>
<body>
  <table>
    <tr>
      <th>Size</th>
      <td>$wallsize</td>
    </tr>
    <tr>
      <th>City</th>
      <td>$city</td>
    </tr>
    <tr>
      <th>Rate</th>
      <td>$rate</td>
    </tr>
  </table>
</body>
</html>
        ''',
      ),
    );
  }

  Widget Recomendations() {
    return SizedBox(
        height: 170,
        child: FirebaseAnimatedList(
          scrollDirection: Axis.horizontal,
          query: wallref.orderByChild("city").equalTo(city).limitToFirst(5),
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
                childWidget = NearbydeWall(
                  charges: wallRentPrice,
                  imageUrl: photosUrl[0],
                  title: title,
                  size: wallSize,
                  location: city,
                  onPressed: () {
                    Navigator.push(context,
                        customPageRoute(PosterDetails(wallid: wallid)));
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
        ));
  }

  Future<void> sendEnquiry() async {
    LoadingDialog loadingDialog = LoadingDialog();
    loadingDialog.show(context);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final DatabaseReference adminenqref = FirebaseDatabase.instance
        .reference()
        .child('deWall')
        .child('Admin')
        .child('Enquiries');
    final DatabaseReference userenqref = FirebaseDatabase.instance
        .reference()
        .child('deWall')
        .child('User')
        .child(phoneNumber!)
        .child('Enquiries');
    try {
      String enquirykey = adminenqref.push().key ?? '';
      await adminenqref.child(enquirykey).set({
        'enquiryid': enquirykey,
        'wallid': widget.wallid,
        'status': 'Unseen',
        'ownername': postedByUsername,
        'ownerphone': postedByUserPhone,
        'wallsize': wallSize,
        'wallprice': wallRentPrice,
        'wallLocation': wallLocation,
        'wallgeocord': '$latitude,$longitude',
        'wallcity': city,
        'datetime': formattedDate,
        'companyname': userModel!.name,
        'companyphone': userModel!.phonenumber,
        'companyid': userModel!.uid,
        'companycity': userModel!.city,
        'walltitle': title,
        'wallimage': photosUrl![0],
      }).then((_) {
        userenqref.child(widget.wallid).set({
          'enquiryid': enquirykey,
          'wallid': widget.wallid,
          'status': 'Unseen',
          'ownername': postedByUsername,
          'ownerphone': postedByUserPhone,
          'wallsize': wallSize,
          'wallprice': wallRentPrice,
          'wallLocation': wallLocation,
          'wallgeocord': '$latitude,$longitude',
          'wallcity': city,
          'datetime': formattedDate,
          'walltitle': title,
          'wallimage': photosUrl![0],
        });
        loadingDialog.dismiss();
        sendpushnotificationtoadmin('new dewall Enquiry', photosUrl![0]);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enquiry Sent')));
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error : $e')));
    }
  }
  Future<void> sendpushnotificationtoadmin(String msg,String imageurl) async {
    final pushoneSignalNotification = PushOneSignalNotification(
      restApiKey: 'OTY3ODBmMzYtOGM2YS00MWRkLWJjYjctYmUxYTMzYjE3Y2Y0',
      appId: 'bbe4c4df-2829-4e6e-91fd-3c97c11fbbc1',
    );

    await pushoneSignalNotification.sendPushNotification(
      message: msg,
      title: 'deWall ads',
      heading: 'New message from deWall ads',
      externalIds: uidlist,
      targetChannel: 'push',
      customData: {"custom_key": "custom_value"},
      imageUrl: imageurl,
    );
  }

  Future<bool> checkUserEnquiryExist(String phoneNumber, String wallId) async {
    Completer<bool> completer = Completer<bool>();

    try {
      final enquirref = FirebaseDatabase.instance
          .reference()
          .child('deWall')
          .child('User')
          .child(phoneNumber)
          .child('Enquiries')
          .child(wallId);

      enquirref.onValue.listen((event) async {
        final enqdata = event.snapshot.value;
        if (enqdata != null) {
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      });
    } catch (e) {
      print('Error checking user enquiry existence: $e');
      completer.completeError(e);
    }

    return completer.future;
  }
}
