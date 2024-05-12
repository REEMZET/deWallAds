import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Pages/EnquiryChat.dart';
import '../utils/Pagerouter.dart';
import 'Directionbutton.dart';



class EnquiryModel {
  String wallid;
  String title;
  String postedByUsername;
  String postedByUserPhone;
  String wallSize;
  String wallLocation;
  String locationCoordinates;
  String wallRentPrice;
  String city;
  String wallimage;
  String companyid;
  String companyname;
  String companyphone;
  String dateTime;
  String enquiryId;

  EnquiryModel({
    required this.wallid,
    required this.title,
    required this.postedByUsername,
    required this.postedByUserPhone,
    required this.wallSize,
    required this.wallLocation,
    required this.locationCoordinates,
    required this.wallRentPrice,
    required this.city,
    required this.wallimage,
    required this.companyid,
    required this.companyname,
    required this.companyphone,
    required this.dateTime,
    required this.enquiryId,
  });

  Map<String, dynamic> toJson() {
    return {
      "wallid": wallid,
      "title": title,
      "postedByUsername": postedByUsername,
      "postedByUserPhone": postedByUserPhone,
      "wallSize": wallSize,
      "wallLocation": wallLocation,
      "locationCoordinates": locationCoordinates,
      "wallRentPrice": wallRentPrice,
      "city": city,
      "wallimage":wallimage,
      "companyid":companyid,
      "companyname":companyname,
     "companyphone":companyphone,
      "dateTime":dateTime,
      "enquiryId":enquiryId
    };
  }
}


class EnquiryDetails extends StatefulWidget {
  final EnquiryModel enquirymodel;
  EnquiryDetails({required this.enquirymodel});
  @override
  State<EnquiryDetails> createState() => _EnquiryDetailsState();
}

class _EnquiryDetailsState extends State<EnquiryDetails> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('deWall Enquiry Details', style: TextStyle(fontSize: 15, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Container(width:double.infinity,height:170,child: Image.network(widget.enquirymodel.wallimage,fit: BoxFit.fitWidth,)),
            const SizedBox(height: 10),
             Text(
              "${widget.enquirymodel.title}🔥",
              maxLines: null,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 0.75),
            ),

            Text(
              'Enquiry Date-${widget.enquirymodel.dateTime}',
              style: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 140,
              child: tabledata(widget.enquirymodel.wallSize, widget.enquirymodel.city, widget.enquirymodel.wallRentPrice),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, top: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Location Details:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 27, top: 4, right: 4),
              child: Align(
                alignment: Alignment.topLeft,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: widget.enquirymodel.wallLocation,
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 4, right: 4),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, top: 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Owner Details:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 4),
                      child: Text(
                        'Uploaded By: ${widget.enquirymodel.postedByUsername}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child:  GestureDetector(
                        onTap: () {
                          // Implement the code to make a call here
                          launch('tel:"${widget.enquirymodel.postedByUserPhone}"');
                        },
                        child: Text(
                          'Phone-${widget.enquirymodel.postedByUserPhone}',
                          style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),




            Padding(
              padding: const EdgeInsets.only(left: 10, top: 4, right: 4),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, top: 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Enquiry company Details:-',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 4),
                      child: Text(
                        'Enquiry By: ${widget.enquirymodel.companyname}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child:     GestureDetector(
                        onTap: () {
                          // Implement the code to make a call here
                          launch('tel:"${widget.enquirymodel.companyphone}"');
                        },
                        child: Text(
                          'Phone-${widget.enquirymodel.companyphone}',
                          style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                    ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 20,left: 10,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(onPressed: (){
                            Navigator.push(
                                context,
                                customPageRoute(EnquiryChat(
                                  enquiryid: widget.enquirymodel.enquiryId,
                                  companyid: widget.enquirymodel.companyid, CompanyName: widget.enquirymodel.companyname,wallid: widget.enquirymodel.wallid, companyphone:widget.enquirymodel.companyphone ,
                                )));
                          }, child: Text('Chat Now',style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),),
                          DirectionButton(geocordinates: widget.enquirymodel.locationCoordinates,// Replace with your destination longitude
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabledata(String wallsize, String city, String rate) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: '''
           <!DOCTYPE html>
    <html lang="en">
   <head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 20px;
    }

    th, td {
      border: 1px solid #ddd;
      padding: 8px;
      text-align: left;
    }

    th {
      background-color: #f2f2f2;
    }
  </style>
</head>
<body>
  <table>
    <tr>
      <th>Size</th>
      <td>$wallsize</td>
    </tr>
    <tr>
      <th>City</th>
      <td>$city</td>
    </tr>
    <tr>
      <th>Rate</th>
      <td>$rate</td>
    </tr>
  </table>
</body>
</html>
        ''',
      ),
    );
  }




}
