import 'package:dewallads/WallOwner/Widget/WalllistUi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';


import '../Employee/EditdeWall.dart';
import '../widgetui/explorewidget.dart';

class OwnerdeWalllist extends StatefulWidget {
  const OwnerdeWalllist({super.key});

  @override
  State<OwnerdeWalllist> createState() => _OwnerdeWalllistState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);

class _OwnerdeWalllistState extends State<OwnerdeWalllist> {
  DatabaseReference ref =
      FirebaseDatabase.instance.reference().child('deWall/walls');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'My deWall List',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        body: ExploreWidget());
  }

  Widget ExploreWidget() {
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      query: ref.orderByChild('postedBy').equalTo(user!.uid),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        final data = snapshot.value;
        if (data != null && data is Map) {
          String city = data['city'].toString();
          String wallSize = data['wallSize'].toString();
          String viewCount = data['viewCount'].toString();
          String wallRentPrice = data['wallRentPrice'].toString();
          String wallid = data['wallid'].toString();
          String title = data['title'].toString();
          String postDate = data['postDate'].toString();
          String cateogory = data['cateogory'].toString();
          String postedBy = data['postedBy'].toString();
          String postedByUsername = data['postedByUsername'].toString();
          String postedByUserPhone = data['postedByUserPhone'].toString();
          String wallLocation = data['wallLocation'].toString();
          String available = data['available'].toString();
          String videoUrl = data['videoUrl'].toString();
          double latitude = data['latitude'] != null
              ? double.parse(data['latitude'].toString())
              : 0.0;
          double longitude = data['longitude'] != null
              ? double.parse(data['longitude'].toString())
              : 0.0;
          List<String> photosUrl = [];
          List<CarouselItem> carousellist = [];
          if (data['photosUrl'] != null && data['photosUrl'] is List) {
            photosUrl = List<String>.from(data['photosUrl']);
            for (String imageUrl in photosUrl) {
              carousellist.add(CarouselItem(
                image: NetworkImage(imageUrl),
              ));
            }
          }


          Widget childWidget;
          if (photosUrl.isNotEmpty) {
            childWidget = ownerWalllist(
              charges: wallRentPrice,
              imageUrl: carousellist,
              title: title,
              size: wallSize,
              location: city,
              viewCount: viewCount,
              onPressed: () {
                // Navigator.push(context, customPageRoute(EditdeWall(wallposter: wallPoster,)));
              }, available: available,
            );
          } else {
            childWidget = const SizedBox();
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
}
