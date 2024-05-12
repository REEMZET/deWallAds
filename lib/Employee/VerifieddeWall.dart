import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';
import '../utils/Pagerouter.dart';
import '../widgetui/explorewidget.dart';
import 'EditdeWall.dart';

class VerifieddeWalls extends StatefulWidget {
  const VerifieddeWalls({Key? key}) : super(key: key);

  @override
  State<VerifieddeWalls> createState() => _VerifieddeWallsState();
}

class _VerifieddeWallsState extends State<VerifieddeWalls> {
  final TextEditingController searchController = TextEditingController();
  final DatabaseReference ref =
  FirebaseDatabase.instance.reference().child('deWall/walls');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Verified deWall List',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          buildSearchWidget(),
          Expanded(
            child: ExploreWidget(),
          ),
        ],
      ),
    );
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

          List<String> photosUrl = data['photosUrl'] != null &&
              data['photosUrl'] is List
              ? List<String>.from(data['photosUrl'])
              : [];
          List<CarouselItem> carouselList = photosUrl
              .map((imageUrl) => CarouselItem(image: NetworkImage(imageUrl)))
              .toList();

          if (searchController.text.isEmpty ||
              postedByUserPhone
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase())) {
            Widget childWidget = photosUrl.isNotEmpty
                ? Explorewidget(
              charges: wallRentPrice,
              imageUrl: carouselList,
              title: title,
              size: wallSize,
              location: city,
              viewCount: viewCount,
              onPressed: () {
                WallPoster wallPoster = WallPoster(
                  wallid: wallid,
                  title: title,
                  postDate: postDate,
                  postedBy: postedBy,
                  cateogory: cateogory,
                  postedByUsername: postedByUsername,
                  postedByUserPhone: postedByUserPhone,
                  wallSize: wallSize,
                  wallLocation: wallLocation,
                  locationCoordinates: {"latitude": latitude, "longitude": longitude},
                  wallRentPrice: wallRentPrice,
                  available: available,
                  photosUrl: photosUrl,
                  city: city,
                  videoUrl: videoUrl,
                  viewCount: int.parse(viewCount), tags: [],
                );
                Navigator.push(
                  context,
                  customPageRoute(EditdeWall(wallposter: wallPoster)),
                );
              },
            )
                : const SizedBox();

            return SizeTransition(
              sizeFactor: animation,
              child: childWidget,
            );
          }
        }
        return const SizedBox();
      },
    );
  }

  Widget buildSearchWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 20, top: 15),
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
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 12),
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "Search dewall by phone number..",
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchController.text = value;
                    });
                  },
                ),
              ),
              const Icon(
                Icons.arrow_circle_right_outlined,
                size: 15,
                color: Colors.black87,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
