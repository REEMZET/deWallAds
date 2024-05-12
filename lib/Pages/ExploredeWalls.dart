import 'package:dewallads/widgetui/explorewidget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';

import '../utils/Pagerouter.dart';
import 'PosterDetails.dart';

class ExploredeWalls extends StatefulWidget {
  final String cateogory;

  const ExploredeWalls({super.key, required this.cateogory});

  @override
  State<ExploredeWalls> createState() => _ExploredeWallsState();
}

DatabaseReference ref =
    FirebaseDatabase.instance.reference().child('deWall/walls');

class _ExploredeWallsState extends State<ExploredeWalls> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.cateogory,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        body: ExploreWidget());
  }

  Widget ExploreWidget() {
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      query: ref.orderByChild("cateogory").equalTo(widget.cateogory),
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
            childWidget = Explorewidget(
              charges: wallRentPrice,
              imageUrl: carousellist,
              title: title,
              size: wallSize,
              location: city,
              viewCount: viewCount,
              onPressed: () {
                Navigator.push(
                    context, customPageRoute(PosterDetails(wallid: wallid)));
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
