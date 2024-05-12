import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../utils/Pagerouter.dart';
import '../widgetui/HomeWidget/TopLocationmenu.dart';
import '../widgetui/deWallListUI.dart';
import 'PosterDetails.dart';

class ExploreCity extends StatefulWidget {
  const ExploreCity({Key? key}) : super(key: key);

  @override
  State<ExploreCity> createState() => _ExploreCityState();
}

DatabaseReference ref = FirebaseDatabase.instance.reference().child('deWall/walls');
TextEditingController cityController = TextEditingController();

class _ExploreCityState extends State<ExploreCity> {
  Set<String> uniqueCities = <String>{};
  GlobalKey<_WidgetDeWallState> widgetDeWallKey = GlobalKey<_WidgetDeWallState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'deWall by Cities',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Container(width:double.infinity,child: Padding(
            padding: const EdgeInsets.only(left: 10,top: 10,bottom: 5),
            child: Text('Select City to view dewall',textAlign: TextAlign.start,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
          )),
          Container(
            height: 90,
            child: TopCityDeWall(cityController: cityController, updateKey: _updateWidgetDeWallKey),
          ),
          Container(width:double.infinity,child: Padding(
            padding: const EdgeInsets.only(left: 10,top: 10,bottom: 5),
            child: Text('deWall in ${cityController.text}',textAlign: TextAlign.start,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
          )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: WidgetDeWall(value: cityController.text, key: widgetDeWallKey),
            ),
          ),
        ],
      ),
    );
  }

  void _updateWidgetDeWallKey() {
    setState(() {
      widgetDeWallKey = GlobalKey<_WidgetDeWallState>();
    });
  }
}

class TopCityDeWall extends StatelessWidget {
  const TopCityDeWall({Key? key, required this.cityController, required this.updateKey}) : super(key: key);

  final TextEditingController cityController;
  final VoidCallback updateKey;

  @override
  Widget build(BuildContext context) {
    Set<String> uniqueCities = <String>{};
    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query: ref.orderByChild('city').limitToFirst(200),
      itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
        final data = snapshot.value;
        if (data != null && data is Map) {
          String city = data['city'].toString();
          if (!uniqueCities.contains(city)) {
            uniqueCities.add(city);
            return Toplocationmenu(
              icon: Icons.location_city,
              label: city,
              onPressed: () {
                cityController.text = city;
                updateKey();
              },
            );
          }
        }

        return const SizedBox(); // Return an empty container if data is not in the expected format or if the city is a repetition.
      },
    );
  }
}

class WidgetDeWall extends StatefulWidget {
  const WidgetDeWall({required this.value, required Key key}) : super(key: key);

  final String value;

  @override
  _WidgetDeWallState createState() => _WidgetDeWallState();
}

class _WidgetDeWallState extends State<WidgetDeWall> {
  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      query: ref.orderByChild('city').equalTo(widget.value),
      itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
        final data = snapshot.value;
        if (data != null && data is Map) {
          String city = data['city'].toString();
          String wallSize = data['wallSize'].toString();
          String available = data['available'].toString();
          String category = data['category'].toString();
          String wallRentPrice = data['wallRentPrice'].toString();
          String wallId = data['wallId'].toString();
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
                Navigator.push(context, customPageRoute(PosterDetails(wallid: wallId,)));
              },
            );
          } else {
            childWidget = const SizedBox(); // or another default widget if the list is empty
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
