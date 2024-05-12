import 'package:badges/badges.dart' as badges;
import 'package:dewallads/Company/CompanyEnquiryDetails.dart';
import 'package:dewallads/Employee/EnquiryDetails.dart';
import 'package:dewallads/Pages/EnquiryChat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../utils/Pagerouter.dart';

class EnquiryList extends StatefulWidget {
  const EnquiryList({super.key});

  @override
  State<EnquiryList> createState() => _EnquiryListState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
final DatabaseReference enquiriesRef = FirebaseDatabase.instance
    .reference()
    .child('deWall')
    .child('User')
    .child(phoneNumber!)
    .child('Enquiries');

class _EnquiryListState extends State<EnquiryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('deWall Enquiry List',
              style: TextStyle(color: Colors.white)),
        ),
        body: EnquiryList());
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



        return InkWell(
          onTap: (){
            CompanyEnquiryModel enquiryModel=CompanyEnquiryModel(wallid: wallId, title: walltitle, postedByUsername: ownerName,
                postedByUserPhone: ownerPhone, wallSize: wallSize, wallLocation: wallLocation, locationCoordinates: wallGeoCord,
                wallRentPrice: wallRentPrice ,city: wallCity,wallimage:wallimage,companyid:companyid,
                companyphone:companyphone,dateTime:dateTime,enquiryId:enquiryId);
            Navigator.push(context, customPageRoute(CompanyEnquiryDetails(enquirymodel: enquiryModel)));
          },
          child: Card(
              color: Colors.white,
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
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
                        updateseenstatus(wallId);
                        Navigator.push(context, customPageRoute(EnquiryChat(
                              enquiryid: enquiryId,
                              companyid: companyid,
                              CompanyName: 'deWall ads',wallid: wallId, companyphone: companyphone,
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
                              fontSize: 10.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 1,
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
              )),
        );
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

  void updateseenstatus(String wallId) {
    enquiriesRef.child(wallId).child('status').set('Seen');
  }
}
