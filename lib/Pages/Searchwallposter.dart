import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dewallads/Model/wallPosterModel.dart';
import 'package:dewallads/widgetui/HomeWidget/Nearby%20deWall.dart';
import 'package:flutter/material.dart';

import '../utils/Pagerouter.dart';
import 'PosterDetails.dart';

class SearchdeWall extends StatefulWidget {
  const SearchdeWall({super.key});

  @override
  _SearchdeWallState createState() => _SearchdeWallState();
}

class _SearchdeWallState extends State<SearchdeWall> {
  final TextEditingController _searchController = TextEditingController();

  late Query query;

  @override
  void initState() {
    super.initState();
    query = FirebaseFirestore.instance
        .collection("deWall")
        .doc('walls')
        .collection('walllist')
        .limit(50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Poster',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 15, top: 4),
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
                      size: 18,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Search by location or size...",
                          border: InputBorder.none,
                        ),
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              query = FirebaseFirestore.instance
                                  .collection("deWall")
                                  .doc('walls')
                                  .collection('walllist')
                                  .where("tags", arrayContains: value)
                                  .limit(50);
                            } else {
                              query = FirebaseFirestore.instance
                                  .collection("deWall")
                                  .doc('walls')
                                  .collection('walllist')
                                  .limit(50);
                            }
                          });
                        },
                      ),
                    ),
                    const Icon(
                      Icons.arrow_circle_right_outlined,
                      size: 15,
                      color: Colors.black87,
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!.docs;
                List<Widget> itemList = [];
                for (var item in items) {
                  final data = item.data() as Map<String, dynamic>;
                  final model = WallPosterModel.fromJson(data);
                  itemList.add(
                    buildServiceItem(model),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return itemList[index];
                  },
                  itemCount: itemList.length,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildServiceItem(WallPosterModel model) {
    return NearbydeWall(
        imageUrl: model.photosUrl.first,
        title: model.title,
        size: model.wallSize,
        charges: model.wallRentPrice,
        location: model.city,
        onPressed: () {
          Navigator.push(
              context, customPageRoute(PosterDetails(wallid: model.wallid)));
        });
  }
}
