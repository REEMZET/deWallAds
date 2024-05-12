import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:video_player/video_player.dart';

import '../Model/UserModel.dart';
import '../widgetui/NotificationWidget/OneSignalNotificationwithoutimage.dart';

class WallPoster {
  String wallid;
  String title;
  String postDate;
  String postedBy;
  String cateogory;
  String postedByUsername;
  String postedByUserPhone;
  String wallSize;
  String wallLocation;
  Map<String, double> locationCoordinates;
  String wallRentPrice;
  String available;
  List<String> photosUrl;
  String city;
  String videoUrl;
  int viewCount;
  List<String> tags;

  WallPoster({
    required this.wallid,
    required this.title,
    required this.postDate,
    required this.postedBy,
    required this.cateogory,
    required this.postedByUsername,
    required this.postedByUserPhone,
    required this.wallSize,
    required this.wallLocation,
    required this.locationCoordinates,
    required this.wallRentPrice,
    required this.available,
    required this.photosUrl,
    required this.city,
    required this.videoUrl,
    this.viewCount = 0,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      "wallid": wallid,
      "title": title,
      "postDate": postDate,
      "postedBy": postedBy,
      "postedByUsername": postedByUsername,
      "postedByUserPhone": postedByUserPhone,
      "wallSize": wallSize,
      "wallLocation": wallLocation,
      "locationCoordinates": locationCoordinates,
      "wallRentPrice": wallRentPrice,
      "available": available,
      "photosUrl": photosUrl,
      "city": city,
      "videoUrl": videoUrl,
      "viewCount": viewCount,
      "tags": tags,
      "cateogory": cateogory,
    };
  }
}

class EditdeWall extends StatefulWidget {
  final WallPoster wallposter;

  EditdeWall({required this.wallposter});

  @override
  State<EditdeWall> createState() => _EditdeWallState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
UserModel? userModel;

class _EditdeWallState extends State<EditdeWall> {
  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController wallSizeController = TextEditingController();
  final TextEditingController wallLocationController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController wallRentPriceController = TextEditingController();
  final TextEditingController VideoidController = TextEditingController();
  final TextEditingController wallcateogroyController=TextEditingController();
  final TextEditingController wallownernameController=TextEditingController();
  final TextEditingController wallownerphoneController=TextEditingController();

  List<String> tag = [];
  late bool isUserLoggedIn;
  late List<String> uidlist;
  late List<String> imageUrls;
  late String videourl;
  late String longitude;
  late String latitude;
  late VideoPlayerController _controller;
  late String walltitle;
  late String walllocation;
  late String wallCateogory;

  late String itemId;

  late ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        Uri.parse(widget.wallposter.videoUrl).toString())
      ..initialize().then((_) {
        setState(() {});
      });
    imageUrls = widget.wallposter.photosUrl;
    videourl = widget.wallposter.videoUrl;
    walltitle = widget.wallposter.title;
    walllocation = widget.wallposter.wallLocation;
    wallCateogory=widget.wallposter.cateogory;
    uidlist = [widget.wallposter.postedBy];
  }

  List<String> tagGenerator(String str) {
    String keyword = "";
    List<String> words = str.split(" ");
    for (int n = 0; n < words.length; n++) {
      for (int i = 0; i < words[n].length; i++) {
        for (int j = 0; j <= i; j++) {
          keyword = keyword + (words[n].toLowerCase()[j]);
        }
        tag.add(keyword);
        keyword = "";
      }
    }
    for (int i = 0; i < str.length; i++) {
      String currentTag = "";
      for (int j = 0; j <= i; j++) {
        currentTag += str[j];
      }
      tag.add(currentTag);
    }
    return tag;
  }

  void _viewLargeImage(String imageurl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
          child: Image.network(
        imageurl,
        fit: BoxFit.cover,
      )),
    );
  }

  Widget _previewImages() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: imageUrls!.asMap().entries.map((MapEntry<int, String> entry) {
          return Stack(
            children: [
              InkWell(
                onTap: () {
                  _viewLargeImage(entry.value);
                },
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      entry.value,
                      width: 300.0,
                      height: 170.0,
                      fit: BoxFit.cover,
                    )),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    _removeImage(entry.key);
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      imageUrls.removeAt(index);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showVideoPreviewDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: GestureDetector(
          onTap: () {
            // Play or pause the video on tap
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          },
          child: Container(
            width: 100,
            height: 400, // Adjust the height as needed
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }

  Widget itemDashboard(String title, IconData iconData, Color background,
      VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.all(4),
        width: 250,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
              color: Colors.blue.withOpacity(.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> addWall() async {
    if (areFieldsEmpty()) {
      Fluttertoast.showToast(
        msg:
            'Please fill in all details and include the required video and images.',
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
      );

      return;
    }
    await pr.show();
    itemId = widget.wallposter.wallid;

    DateTime currentDate = DateTime.now();
    String formattedDate =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(currentDate);
    final randomTags = tagGenerator('${titleController.value.text} ${cityController.value.text} ${heightController.value.text}${widthController.value.text} ${wallLocationController.value.text}');

    WallPoster wallPoster = WallPoster(
      wallid: itemId,
      title: titleController.value.text,
      postDate: formattedDate,
      cateogory: wallcateogroyController.value.text,
      postedBy: widget.wallposter.postedBy,
      postedByUsername: widget.wallposter.postedByUsername,
      postedByUserPhone: widget.wallposter.postedByUserPhone,
      wallSize: '${heightController.value.text}x${widthController.value.text} feet',
      wallLocation: wallLocationController.value.text,
      locationCoordinates: widget.wallposter.locationCoordinates,
      wallRentPrice: wallRentPriceController.value.text,
      available: 'Verified',
      photosUrl: imageUrls,
      city: cityController.value.text,
      videoUrl: VideoidController.value.text,
      viewCount: 1,
      tags: randomTags,
    );
    WallPoster wall = wallPoster;
    final wallposter = wall.toJson();
    await FirebaseFirestore.instance.collection("deWall").doc('walls').collection('walllist').doc(itemId).set(wallposter);
    wallposter.remove('tags');
    await databaseReference.child("deWall/walls/$itemId").set(wallposter);
    await pr.hide();
    sendpushnotification();

    Fluttertoast.showToast(
      msg: 'deWall verification compete',
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green,
    );
    Navigator.of(context).pop();
    await databaseReference.child("deWall/Admin/pendingwalls/$itemId").remove();
  }

  bool areFieldsEmpty() {
    return titleController.text.isEmpty ||
        heightController.text.isEmpty ||
        widthController.text.isEmpty ||
        wallLocationController.text.isEmpty ||
        wallRentPriceController.text.isEmpty ||
        cityController.text.isEmpty ||
        VideoidController.text.isEmpty ||
        wallcateogroyController.text.isEmpty||
        imageUrls.isEmpty ||
        imageUrls.isEmpty;
  }

  Map<String, String> separateHeightWidth(String wallSize) {
    List<String> parts = wallSize.split('x');

    if (parts.length == 2) {
      String height = parts[0].trim().replaceAll('feet', '');
      String width = parts[1].trim().replaceAll('feet', '');

      return {'height': height, 'width': width};
    } else {
      // Handle incorrect format, return null or throw an exception
      return {'error': 'Invalid wall size format'};
    }
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = walltitle;
    wallLocationController.text = walllocation;
    wallRentPriceController.text = widget.wallposter.wallRentPrice;
    cityController.text = widget.wallposter.city;
    VideoidController.text = widget.wallposter.videoUrl;
    wallcateogroyController.text=widget.wallposter.cateogory;
    wallownernameController.text=widget.wallposter.postedByUsername;
    wallownerphoneController.text=widget.wallposter.postedByUserPhone;

    Map<String, String> dimensions =
        separateHeightWidth(widget.wallposter.wallSize);
    if (dimensions.containsKey('error')) {
      print('Error: ${dimensions['error']}');
    } else {
      String height = dimensions['height']!;
      String width = dimensions['width']!;
      heightController.text = height;
      widthController.text = width;
    }

    pr = ProgressDialog(context);
    pr = ProgressDialog(context,
        type: ProgressDialogType.download,
        isDismissible: false,
        showLogs: true);
    pr.style(
        message: 'Uploading file...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget:
            SizedBox(height: 4, width: 5, child: CircularProgressIndicator()),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Wall Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
              child: ListView(
            children: <Widget>[
              Text('Please add exactly 3 images',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              _previewImages(),
              Text('Upload Video',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              InkWell(
                onTap: () {
                  _showVideoPreviewDialog();
                },
                child: Container(width: 150, height: 250,child: VideoPlayer(_controller),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Youtube video id', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.blue)),
                  InkWell(onTap:(){_copyToClipboard(VideoidController.value.text);},child: Text('Copy url', style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.indigo))),
                ],
              ),
              buildTextField(VideoidController, 'Video id', Icons.play_arrow_outlined, TextInputType.name, 15),
              SizedBox(height: 10),
              Text('Title of deWall', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
              buildTextField(titleController, 'Title', Icons.title,TextInputType.name, 30),
              Text('Size of wall', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.blue)),
              Row(
                children: [
                  Expanded(child: buildTextField(heightController, 'Height (feet)',Icons.height, TextInputType.number, 3),
                  ),
                  SizedBox(width: 10),
                  Expanded(child: buildTextField(widthController, 'Width (feet)',Icons.width_normal_rounded, TextInputType.number, 3),
                  ),
                ],
              ),

              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: wallcateogroyController.text,
                onChanged: (String? newValue) {
                  wallcateogroyController.text = newValue!;

                },
                items: [
                  DropdownMenuItem(
                    value: 'Featured',
                    child: Text('Featured'),
                  ),
                  DropdownMenuItem(
                    value: 'General',
                    child: Text('General'),
                  ),
                  DropdownMenuItem(
                    value: 'TopdeWalls',
                    child: Text('TopdeWalls'),
                  ),
                ],
                decoration: InputDecoration(
                  hintText: 'Select Wall Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),



              Text('location of deWall',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              buildTextField(wallLocationController, 'Location',
                  Icons.location_on, TextInputType.streetAddress, 35),
              Text('Rent of deWall',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              buildTextField(wallRentPriceController, 'Rent Price',
                  Icons.currency_rupee, TextInputType.text, 15),
              Text('City of deWall',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
              buildTextField(cityController, 'City', Icons.location_city,
                  TextInputType.text, 15),

              Text('WallOwner Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
              buildTextField(wallownernameController, 'OwnerName', Icons.person,
                  TextInputType.text, 30),
              buildTextField(wallownerphoneController, 'OwnerPhone', Icons.person,
                  TextInputType.text, 10),


              Container(
                margin: EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    addWall();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'Verify and Publish deWall',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ))),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText,
      IconData icon, TextInputType inputType, int length) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLength: length,
        style: TextStyle(color: Colors.deepPurple),
        // Set the text color to blue
        textCapitalization: TextCapitalization.words,
        // Set the input type
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Future<void> sendpushnotification() async {
    final pushoneSignalNotification = PushOneSignalNotification(
      restApiKey: 'OTY3ODBmMzYtOGM2YS00MWRkLWJjYjctYmUxYTMzYjE3Y2Y0',
      appId: 'bbe4c4df-2829-4e6e-91fd-3c97c11fbbc1',
    );

    await pushoneSignalNotification.sendPushNotification(
      message: 'your dewall verified successfully',
      title: 'deWall ads',
      heading: 'Congrats your dewall publish',
      externalIds: uidlist,
      targetChannel: 'push',
      imageUrl: imageUrls.first,
      customData: {"custom_key": "custom_value"},
    );
  }
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: 'url copied',
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green,
    );
  }

}
