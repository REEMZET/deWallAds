import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as base;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../Model/GeoapiRespose.dart';
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

class AddWall extends StatefulWidget {
  const AddWall({Key? key}) : super(key: key);

  @override
  State<AddWall> createState() => _AddWallState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
UserModel? userModel;

class _AddWallState extends State<AddWall> {

  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController wallSizeController = TextEditingController();
  final TextEditingController wallLocationController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController wallRentPriceController = TextEditingController();
  final TextEditingController VideoidController = TextEditingController();

  List<String> tag = [];
  late bool isUserLoggedIn;
  String _currentAddress = " ";
  late List<String> uidlist;
  Position? _currentPosition;
  bool _isLoading = false;
  late List<String> imageUrls;
  late String latitude;
  late String longitude;
  late VideoPlayerController _controller;
  XFile? _videoFile;
  late String itemId;
  List<XFile>? _mediaFileList;
  final ImagePicker _picker = ImagePicker();
  late ProgressDialog pr;

  YoutubePlayerController _ytcontroller = YoutubePlayerController(
    initialVideoId: 'A3guEmM6FGE',
    flags: YoutubePlayerFlags(
      autoPlay: true,
      mute: false,

    ),
  );



  Future<void> _getCurrentPosition() async {
    final permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      setState(() {
        _isLoading = true;
      });

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        setState(() {
          _currentPosition = position;
          fetchData();
          _isLoading = false;
        });
      } catch (e) {
        debugPrint("Error getting current position: $e");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
    }
  }

  Future<void> fetchData() async {
    latitude = _currentPosition!.latitude.toString();
    longitude = _currentPosition!.longitude.toString();
    final url = 'https://geocode.maps.co/reverse?lat=$latitude&lon=$longitude';
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
        setState(() {});
      }
    });
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

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        // Open camera
        _mediaFileList = [];

        for (int i = 0; i < 3; i++) {
          final XFile? pickedFile = await _picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 800,
            maxHeight: 400,
            imageQuality: 85,
          );

          if (pickedFile != null) {
            // Add the picked image to the list
            setState(() {
              _mediaFileList?.add(pickedFile);
            });

            if (_mediaFileList!.length < 3) {
              // Show dialog to ask if the user wants to add more images
              bool addMore = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('please add More Images',style: TextStyle(fontSize: 13),),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Add more images
                        },
                        child: Text('Add'),
                      ),
                      TextButton(
                        onPressed: () {
                          _mediaFileList?.clear();
                          setState(() {

                          });
                          Navigator.of(context).pop(false); // Cancel
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  );
                },
              );

              if (!addMore) {
                break; // User canceled or reached the limit
              }
            }
          } else {
            // If the user cancels or an error occurs, stop taking photos
            break;
          }
        }
      } else {
        // Open gallery
        final List<XFile> pickedFileList = await _picker.pickMultiImage(
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (pickedFileList != null && pickedFileList.length == 3) {
          setState(() {
            _mediaFileList = pickedFileList;
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Please pick exactly 3 images.',
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.green,
          );
        }
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }




  void _viewLargeImage(XFile file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.file(
          File(file.path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _previewImages() {
    if (_mediaFileList != null && _mediaFileList!.isNotEmpty) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _mediaFileList!.asMap().entries.map((MapEntry<int, XFile> entry) {
            return Stack(
              children: [
                InkWell(
                  onTap: () {
                    _viewLargeImage(entry.value);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      File(entry.value.path),
                      width: 300.0,
                      height: 170.0,
                      fit: BoxFit.cover,
                    ),
                  ),
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
    } else {
      return Center(
        child: Container(
          height: 160,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                itemDashboard(
                  'click to add image',
                  Icons.add_a_photo_outlined,
                  Colors.deepOrange,
                  () {
                    _showImageSourceDialog();
                  },
                ),
                itemDashboard(
                  'click to add image',
                  Icons.add_a_photo_outlined,
                  Colors.deepOrange,
                      () {
                    _showImageSourceDialog();
                  },
                ),
                itemDashboard(
                  'click to add image',
                  Icons.add_a_photo_outlined,
                  Colors.deepOrange,
                      () {
                    _showImageSourceDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _mediaFileList!.removeAt(index);
      _mediaFileList?.clear();
      setState(() {

      });
    });
  }

  Future<String> uploadImage(XFile imageFile, String filename) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference =
        storage.ref().child('wallimages/${filename}.png');
    UploadTask uploadTask = storageReference.putFile(File(imageFile.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadVideoWithProgress(XFile videoFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageReference = storage.ref().child('videos/$itemId.mp4');
      UploadTask uploadTask = storageReference.putFile(File(videoFile.path));

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        pr.update(
          progress: progress,
          message: "Please wait...",
          progressWidget: Container(
              padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
              color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
          messageTextStyle: TextStyle(
              color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
        );
      }, onDone: () {});

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      if (taskSnapshot.state == TaskState.success) {
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        return downloadUrl;
      } else {
        throw Exception("Error uploading video: ${taskSnapshot.state}");
      }
    } on PlatformException catch (e) {
      throw Exception("Error uploading video: $e");
    }
  }
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onImageButtonPressed(ImageSource.camera); // Open camera
              },
              child: Row(
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 8),
                  Text('Camera'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onImageButtonPressed(ImageSource.gallery); // Open gallery
              },
              child: Row(
                children: [
                  Icon(Icons.image),
                  SizedBox(width: 8),
                  Text('Gallery'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    isUserLoggedIn = FirebaseAuth.instance.currentUser != null;

    _getCurrentPosition();
    if (isUserLoggedIn) {
      getUserDetails(phoneNumber!);
    }
    _controller = VideoPlayerController.file(File(_videoFile?.path ?? ''))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Video Source'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickVideoFromGallery();
              },
              child: Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _recordVideo();
              },
              child: Text('Camera'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickVideoFromGallery() async {
    XFile? pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);
    _handlePickedVideo(pickedVideo);
  }

  Future<void> _recordVideo() async {
    XFile? recordedVideo = await ImagePicker().pickVideo(source: ImageSource.camera);
    _handlePickedVideo(recordedVideo);
  }


  Future<void> _handlePickedVideo(XFile? pickedVideo) async {
    if (pickedVideo != null) {

      final videoDuration = await _getVideoDuration(File(pickedVideo.path));

      if (videoDuration > 10) {
        ProgressDialog pd = ProgressDialog(context,
            type: ProgressDialogType.normal,
            isDismissible: true,
            showLogs: true);
        pd.style(
          message: 'Compressing video...',
          borderRadius: 4.0,
          backgroundColor: Colors.white,
          progressWidget: CircularProgressIndicator(
            strokeWidth: 1,
          ),
          elevation: 10.0,
          insetAnimCurve: Curves.easeInOut,
          progress: 0.0,
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 10.0,
            fontWeight: FontWeight.w400,
          ),
          messageTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
          ),
        );
        pd.show();

        final trimmedVideoPath = await _trimVideo(pickedVideo.path, 10);


        await VideoCompress.setLogLevel(0);
        final compressedInfo = await VideoCompress.compressVideo(
          trimmedVideoPath,
          quality: VideoQuality.Res640x480Quality,
          deleteOrigin: false,
          includeAudio: true,
        );


        pd.hide();

        setState(() {
          _videoFile = XFile(compressedInfo!.path!);
          _controller = VideoPlayerController.file(File(_videoFile!.path))
            ..initialize().then((_) {
              setState(() {});
            });
        });
      } else {
        setState(() {
          _videoFile = pickedVideo;
          _controller = VideoPlayerController.file(File(_videoFile!.path))
            ..initialize().then((_) {
              setState(() {});
            });
        });
      }
    }
  }



  Future<String> _trimVideo(String inputPath, int durationInSeconds) async {
    final flutterFFmpeg = FlutterFFmpeg();
    final Directory tempDir = await getTemporaryDirectory();
    final originalFileName = base.basename(inputPath);
    final outputPath = '${tempDir.path}/$originalFileName';

    final arguments = [
      '-i',
      inputPath,
      '-t',
      '$durationInSeconds',
      '-b:v',
      '100k', // Adjust bitrate as needed
      '-c',
      'copy',
      outputPath,
    ];
    await flutterFFmpeg.executeWithArguments(arguments);

    return outputPath;
  }

  Future<int> _getVideoDuration(File file) async {
    final videoPlayerController = VideoPlayerController.file(file);
    await videoPlayerController.initialize();
    final duration = videoPlayerController.value.duration;
    await videoPlayerController.dispose();
    return duration.inSeconds;
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

  Widget itemDashboard(String title, IconData iconData, Color background, VoidCallback onPressed) {
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
    if (userModel!.accounttype == 'employee') {
      itemId = databaseReference.child("deWall/walls").push().key ?? '';
    } else {
      itemId =
          databaseReference.child("deWall/Admin/pendingwalls").push().key ?? '';
    }

    imageUrls = await uploadImages(_mediaFileList);
    if (_videoFile != null) {
      VideoidController.text = await uploadVideoWithProgress(_videoFile!);
    }

    //String videoUrl = 'ABzn5vLzg3g';

    DateTime currentDate = DateTime.now();
    String formattedDate =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(currentDate);
    final randomTags = tagGenerator(
        '${titleController.value.text} ${cityController.value.text} ${heightController.value.text}${widthController.value.text} ${wallLocationController.value.text}');

    WallPoster wallPoster = WallPoster(
      wallid: itemId,
      title: titleController.value.text,
      postDate: formattedDate,
      cateogory: 'General',
      postedBy: userModel!.uid,
      postedByUsername: userModel!.name,
      postedByUserPhone: userModel!.phonenumber,
      wallSize:
          '${heightController.value.text}x${widthController.value.text} feet',
      wallLocation: wallLocationController.value.text,
      locationCoordinates: {
        "latitude": double.parse(latitude),
        "longitude": double.parse(longitude),
      },
      wallRentPrice: wallRentPriceController.value.text,
      available: 'Unverified',
      photosUrl: imageUrls,
      city: cityController.value.text,
      videoUrl: VideoidController.value.text,
      viewCount: 1,
      tags: randomTags,
    );
    WallPoster wall = wallPoster;
    final wallposter = wall.toJson();
    await FirebaseFirestore.instance
        .collection("deWall")
        .doc('walls')
        .collection('walllist')
        .doc(itemId)
        .set(wallposter);
    wallposter.remove('tags');
    if (userModel!.accounttype == 'employee') {
      await databaseReference.child("deWall/walls/$itemId").set(wallposter);
    } else {
      await databaseReference
          .child("deWall/Admin/pendingwalls/$itemId")
          .set(wallposter);
    }

    clearFields();
    await pr.hide();
    Fluttertoast.showToast(
      msg: 'deWall sent to admin for verification. Please wait.',
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green,
    );
    Navigator.of(context).pop();
  }

  Future<List<String>> uploadImages(List<XFile>? imageFiles) async {
    List<String> imageUrls = [];
    if (imageFiles != null && imageFiles.isNotEmpty) {
      int a = 1;
      for (XFile imageFile in imageFiles) {
        String imageUrl = await uploadImage(imageFile, '$itemId$a');
        imageUrls.add(imageUrl);
        a++;
      }
    }
    return imageUrls;
  }

  void clearFields() {
    titleController.clear();
    heightController.clear();
    widthController.clear();
    wallLocationController.clear();
    wallRentPriceController.clear();
    cityController.clear();

    // Clear image and video files
    _mediaFileList?.clear();
    VideoidController.clear();

    // Dispose video controller
    _controller.dispose();

    // Initialize new video controller
    _controller = VideoPlayerController.file(File(_videoFile?.path ?? ''))
      ..initialize().then((_) {
        setState(() {});
      });

    // Update the UI
    setState(() {});
  }

  bool areFieldsEmpty() {
    if (userModel!.accounttype == 'employee') {
      return titleController.text.isEmpty ||
          heightController.text.isEmpty ||
          widthController.text.isEmpty ||
          wallLocationController.text.isEmpty ||
          wallRentPriceController.text.isEmpty ||
          cityController.text.isEmpty ||
          _mediaFileList == null ||
          _mediaFileList!.isEmpty ||
          VideoidController.text.isEmpty;
    } else {
      return titleController.text.isEmpty ||
          heightController.text.isEmpty ||
          widthController.text.isEmpty ||
          wallLocationController.text.isEmpty ||
          wallRentPriceController.text.isEmpty ||
          cityController.text.isEmpty ||
          _mediaFileList == null ||
          _mediaFileList!.isEmpty ||
          _videoFile == null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: 4,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upload Video',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  OutlinedButton(
                    onPressed: () {
                      _showVideoDialog(context);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(20), // Adjust the radius as needed
                      ),
                      side: const BorderSide(
                        color: Colors.red, // Set the border color here
                        width: 0.5, // Set the border width
                      ),
                    ),
                    child:  Row(
                      children: [
                        Text(
                          'Guide video',
                          style:
                          TextStyle(fontSize:9,fontWeight: FontWeight.bold,color: Colors.red),
                        ),
                        Icon(
                          Icons.play_arrow_outlined,
                          size: 10,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              _videoFile == null
                  ? itemDashboard('click to add video',
                      Icons.video_call_outlined, Colors.deepOrange, () {
                      _pickVideo();
                    })
                  : InkWell(
                      onTap: () {
                        _showVideoPreviewDialog();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 150,
                            height: 250,
                            child: VideoPlayer(_controller),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.video_camera_back,
                                    size: 25,
                                  ),
                                  Text(
                                    'Preview video',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),

                              InkWell(
                                  onTap: () {
                                    _pickVideo();
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.change_circle,
                                        size: 25,
                                      ),
                                      Text(
                                        'Change Video',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
              SizedBox(
                height: 15,
              ),
              userModel!.accounttype == 'employee'
                  ? buildTextField(VideoidController, 'Video id',
                      Icons.play_arrow_outlined, TextInputType.name, 15)
                  : SizedBox(height: 10),
              Text('Title of deWall',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              buildTextField(titleController, 'Title', Icons.title,
                  TextInputType.name, 30),
              Text('Size of wall',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(heightController, 'Height (feet)',
                        Icons.height, TextInputType.number, 3),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: buildTextField(widthController, 'Width (feet)',
                        Icons.width_normal_rounded, TextInputType.number, 3),
                  ),
                ],
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
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              buildTextField(cityController, 'City', Icons.location_city,
                  TextInputType.text, 15),
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
                      'Upload deWall',
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
      margin: EdgeInsets.symmetric(vertical: 10.0),
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

  Future<void> sendpushnotification(
    String msg,
  ) async {
    final pushoneSignalNotification = PushOneSignalNotification(
      restApiKey: 'OTY3ODBmMzYtOGM2YS00MWRkLWJjYjctYmUxYTMzYjE3Y2Y0',
      appId: 'bbe4c4df-2829-4e6e-91fd-3c97c11fbbc1',
    );

    await pushoneSignalNotification.sendPushNotification(
      message: msg,
      title: 'deWall ads',
      heading: 'New deWall added please verify',
      externalIds: uidlist,
      targetChannel: 'push',
      imageUrl: imageUrls.first,
      customData: {"custom_key": "custom_value"},
    );
  }

  Future<void> getAdminUid() async {
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('deWall/uid');
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

  void _showVideoDialog(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width * 0.8;
    double dialogHeight = dialogWidth * (9 / 16);
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Container(
          width: dialogWidth,
          height: 500,
          child: YoutubePlayer(
            controller: _ytcontroller,
            showVideoProgressIndicator: true,
            aspectRatio: 9 / 16,
          ),
        ),
      ),
    );
  }

}
