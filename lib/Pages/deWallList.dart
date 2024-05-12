import 'package:dewallads/widgetui/deWallListUI.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../utils/Pagerouter.dart';
import 'PosterDetails.dart';

class deWallList extends StatefulWidget {
  late String node;
  late String value;

  deWallList({super.key, required this.node, required this.value});

  @override
  State<deWallList> createState() {
    return _deWallListState();
  }
}

DatabaseReference ref =
    FirebaseDatabase.instance.reference().child('deWall/walls');

class _deWallListState extends State<deWallList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.value,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: WidgetdeWall(widget.node, widget.value),
    );
  }
}

Widget WidgetdeWall(String node, value) {
  return FirebaseAnimatedList(
    scrollDirection: Axis.vertical,
    query: ref.orderByChild(node).equalTo(value),
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
          childWidget = deWallListUI(
              charges: wallRentPrice,
              imageUrl: photosUrl[0],
              title: title,
              size: wallSize,
              location: city,
              onPressed: () {
                Navigator.push(
                    context, customPageRoute(PosterDetails(wallid: wallid)));
              });
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
