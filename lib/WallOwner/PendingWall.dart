import 'package:dewallads/WallOwner/Widget/WalllistUi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';
import '../utils/Pagerouter.dart';
import '../widgetui/explorewidget.dart';


class PendingdeWalls extends StatefulWidget {
  const PendingdeWalls({Key? key}) : super(key: key);

  @override
  State<PendingdeWalls> createState() => _PendingdeWallsState();
}
User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
class _PendingdeWallsState extends State<PendingdeWalls> {
  final TextEditingController searchController = TextEditingController();
  final DatabaseReference ref =
  FirebaseDatabase.instance.reference().child('deWall/Admin/pendingwalls');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Pending deWall List',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: ExploreWidget()
    );
  }

  Widget ExploreWidget() {
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      query: ref.orderByChild('postedByUserPhone').equalTo(phoneNumber),
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


            Widget childWidget = photosUrl.isNotEmpty
                ? ownerWalllist(
              charges: wallRentPrice,
              imageUrl: carouselList,
              title: title,
              size: wallSize,
              location: city,
              viewCount: viewCount, available: available,

            )
                : const SizedBox();

            return SizeTransition(
              sizeFactor: animation,
              child: childWidget,
            );
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
