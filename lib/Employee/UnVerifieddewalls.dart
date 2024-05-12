import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';

import '../utils/Pagerouter.dart';
import '../widgetui/explorewidget.dart';
import 'EditdeWall.dart';

class UnverifieddeWalls extends StatefulWidget {
  const UnverifieddeWalls({super.key});

  @override
  State<UnverifieddeWalls> createState() => _UnverifieddeWallsState();
}

DatabaseReference ref =
    FirebaseDatabase.instance.reference().child('deWall/Admin/pendingwalls');

class _UnverifieddeWallsState extends State<UnverifieddeWalls> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Unverified  deWall',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        body: ExploreWidget());
  }

  Widget ExploreWidget() {
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      query: ref,
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
          WallPoster wallPoster = WallPoster(
            wallid: wallid,
            title: title,
            postDate: postDate,
            // You might need to populate these values based on your data
            postedBy: postedBy,
            cateogory: cateogory,
            postedByUsername: postedByUsername,
            postedByUserPhone: postedByUserPhone,
            wallSize: wallSize,
            wallLocation: wallLocation,
            locationCoordinates: {"latitude": latitude, "longitude": longitude},
            // Provide default values or calculate from your data
            wallRentPrice: wallRentPrice,
            available: available,
            photosUrl: photosUrl,
            city: city,
            videoUrl: videoUrl,
            // Provide the video URL if available
            viewCount: int.parse(viewCount),
            // Convert viewCount to int
            tags: [], // Provide tags if available
          );

          Widget childWidget;
          if (photosUrl.isNotEmpty) {
            childWidget = Explorewidget(
              charges: wallRentPrice,
              imageUrl: carousellist,
              title: title,
              size: wallSize,
              location: city,
              viewCount: viewCount,
              onPressed: () {
                Navigator.push(
                    context,
                    customPageRoute(EditdeWall(
                      wallposter: wallPoster,
                    )));
              },
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
