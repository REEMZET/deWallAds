import 'package:badges/badges.dart' as badges;
import 'package:dewallads/Employee/EnquiryDetails.dart';
import 'package:dewallads/Pages/EnquiryChat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Pages/Searchwallposter.dart';
import '../utils/Pagerouter.dart';

class AdminEnquiryList extends StatefulWidget {
  const AdminEnquiryList({super.key});

  @override
  State<AdminEnquiryList> createState() => _AdminEnquiryListState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
final DatabaseReference enquiriesRef =
    FirebaseDatabase.instance.reference().child('deWall/Admin/Enquiries');


class _AdminEnquiryListState extends State<AdminEnquiryList> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('deWall Enquiry List',
              style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            buildSearchWidget(),
            Expanded(child:
            EnquiryList()),
          ],
        ));
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
                    hintText: "Search Enquiry by phone number..",
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchController.text=value;
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
    );
  }




  Widget EnquiryList() {

    return FirebaseAnimatedList(
      query: enquiriesRef,
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        String enquiryId = snapshot.child('enquiryid').value.toString();
        String wallId = snapshot.child('wallid').value.toString();
        String status = snapshot.child('status').value.toString();
        String ownerName = snapshot.child('ownername').value.toString();
        String ownerPhone = snapshot.child('ownerphone').value.toString();
        String wallSize = snapshot.child('wallsize').value.toString();
        String wallRentPrice = snapshot.child('wallprice').value.toString();
        String wallLocation = snapshot.child('wallLocation').value.toString();
        String wallGeoCord = snapshot.child('wallgeocord').value.toString();
        String wallCity = snapshot.child('wallcity').value.toString();
        String dateTime = snapshot.child('datetime').value.toString();
        String walltitle = snapshot.child('walltitle').value.toString();
        String wallimage = snapshot.child('wallimage').value.toString();
        String companyid = snapshot.child('companyid').value.toString();
        String companyname=snapshot.child('companyname').value.toString();
        String companyphone= snapshot.child('companyphone').value.toString();


        if(searchController.text.isEmpty){
          return InkWell(
            onTap: (){
              EnquiryModel enquiryModel=EnquiryModel(wallid: wallId, title: walltitle, postedByUsername: ownerName,
                  postedByUserPhone: ownerPhone, wallSize: wallSize, wallLocation: wallLocation, locationCoordinates: wallGeoCord,
                  wallRentPrice: wallRentPrice ,city: wallCity,wallimage:wallimage,companyid:companyid,companyname:companyname,
                  companyphone:companyphone,dateTime:dateTime,enquiryId:enquiryId);
              Navigator.push(context, customPageRoute(EnquiryDetails(enquirymodel: enquiryModel)));
            },
            child: Card(
                color: Colors.white,
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            // Set the border radius
                            child: Image.network(
                              wallimage, width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return const SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Center(
                                      child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator()),
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Image.asset(
                                  'assets/images/placeholder.png',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                );
                              }, // Adjust the BoxFit property as needed
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                walltitle.substring(0,15),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.blueAccent),
                              ),
                              Text(
                                wallCity,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                              Text(
                                'Size:-$wallSize',
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                dateTime.substring(0,11),
                                style: const TextStyle(
                                    fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              updateEnquiryStatus(enquiryId);
                              Navigator.push(
                                  context,
                                  customPageRoute(EnquiryChat(
                                    enquiryid: enquiryId,
                                    companyid: companyid, CompanyName: companyname,wallid: wallId, companyphone:companyphone ,
                                  )));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              // Background color of the button
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(20.0), // Rounded corners
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Chat Now',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                status == 'Unseen'
                                    ? const badges.Badge(
                                  badgeStyle: badges.BadgeStyle(
                                    badgeColor: Colors.yellow,
                                  ),
                                  badgeContent: Text(
                                    '1',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  child: Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                )
                                    : const Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                  size: 18,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),

                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Company-$companyname',
                              style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Implement the code to make a call here
                                launch('tel:$companyphone');
                              },
                              child: Text(
                                'Phone-$companyphone',
                                style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),

                      ),
                    ],
                  ),
                )),
          );


        }else if(companyphone.toLowerCase().contains(searchController.value.text.toLowerCase().toString())){
          return InkWell(
            onTap: (){
              EnquiryModel enquiryModel=EnquiryModel(wallid: wallId, title: walltitle, postedByUsername: ownerName,
                  postedByUserPhone: ownerPhone, wallSize: wallSize, wallLocation: wallLocation, locationCoordinates: wallGeoCord,
                  wallRentPrice: wallRentPrice ,city: wallCity,wallimage:wallimage,companyid:companyid,companyname:companyname,
                  companyphone:companyphone,dateTime:dateTime,enquiryId:enquiryId);
              Navigator.push(context, customPageRoute(EnquiryDetails(enquirymodel: enquiryModel)));
            },
            child: Card(
                color: Colors.white,
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            // Set the border radius
                            child: Image.network(
                              wallimage, width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return const SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Center(
                                      child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator()),
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Image.asset(
                                  'assets/images/placeholder.png',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                );
                              }, // Adjust the BoxFit property as needed
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                walltitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.blueAccent),
                              ),
                              Text(
                                wallCity,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                              Text(
                                'Size:-$wallSize',
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              updateEnquiryStatus(enquiryId);
                              Navigator.push(
                                  context,
                                  customPageRoute(EnquiryChat(
                                    enquiryid: enquiryId,
                                    companyid: companyid, CompanyName: companyname,wallid: wallId, companyphone:companyphone ,
                                  )));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              // Background color of the button
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(20.0), // Rounded corners
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Chat Now',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                status == 'Unseen'
                                    ? const badges.Badge(
                                  badgeStyle: badges.BadgeStyle(
                                    badgeColor: Colors.yellow,
                                  ),
                                  badgeContent: Text(
                                    '1',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  child: Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                )
                                    : const Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                  size: 18,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),

                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Company-$companyname',
                              style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Implement the code to make a call here
                                launch('tel:$companyphone');
                              },
                              child: Text(
                                'Phone-$companyphone',
                                style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),

                      ),
                    ],
                  ),
                )),
          );
        }else{
          return Container();
        }


      },
      sort: (a, b) {
        String statusA = a.child('status').value.toString();
        String statusB = b.child('status').value.toString();

        // Compare the statuses
        if (statusA == 'Unseen' && statusB != 'Unseen') {
          return -1;
        } else if (statusA != 'Unseen' && statusB == 'Unseen') {
          return 1;
        } else {
          return 0;
        }
      },
    );
  }

  void updateEnquiryStatus(String eqnuiryid) {
    enquiriesRef.child(eqnuiryid).update({'status': 'seen'});
  }

}
