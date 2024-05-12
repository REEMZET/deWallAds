import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class BulkOrder extends StatefulWidget {
  const BulkOrder({Key? key}) : super(key: key);

  @override
  State<BulkOrder> createState() => _BulkOrderState();
}

class _BulkOrderState extends State<BulkOrder> {
  void launchBulkOrderWhatsApp() async {
    String enquirymsg = '''
  *Bulk Advertising*

  Hello, I have a question regarding your *deWall Ads Bulk Advertising services*; 
  Can you please answer,
  1. Available locations 
  2. radius in km near the outlets
  3. Minimum number of orders

    Please respond.

    Thanks & Regards,
''';

    final link = WhatsAppUnilink(
      phoneNumber: '+91-7281887889', // Replace with the appropriate phone number
      text: enquirymsg,
    );

    await launch('$link');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Bulk Order',style: TextStyle(color: Colors.white,fontSize: 16),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'deWall ads Bulk Order Content',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
                decoration: TextDecoration.underline, // Add this line for underline
              ),
            ),

            const SizedBox(height: 4),

        Text(
          "Thank you for considering deWall Ads for your bulk advertising needs! "
              "We understand the importance of reaching a wider audience through strategic advertising,"
              " and we're here to help. If you're interested in placing a bulk order for advertising space or have specific"
              " requirements, please send Enquiry by below button. Our dedicated team will get in touch with you to discuss your "
              "needs and provide a customized solution.",
          style: TextStyle(fontSize: 13),
        ),
            Padding(
              padding: const EdgeInsets.only(left: 35,right: 35,top: 20),
              child: ElevatedButton(
                onPressed: () async {
                  launchBulkOrderWhatsApp();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Use your preferred primary color
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // WhatsApp logo icon
                    Image.asset(
                      'assets/images/whatsapp.png',
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 4),
                    // "Send Enquiry" text
                    Text(
                      'Send Enquiry',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}