import 'package:flutter/material.dart';

class AboutDewall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About deWall',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to deWall Ads!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'About Us:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'At deWall Ads, our mission is to provide a comprehensive advertising solution that bridges the gap between businesses and their target audiences. We strive to empower companies and political entities to enhance their visibility and reach by utilizing prime locations. Through a blend of physical and digital advertising, we aim to transform busy areas into effective marketing canvases.',
              style: TextStyle(fontSize: 16),
            ),
            // Add more sections as needed

            SizedBox(height: 16),
            Text(
              'Contact Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
          Align(
              alignment: Alignment.center,
              child:Text(
                'Address: Building no-22, Darbhanga, Bihar-847103',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Apply bold style
                  fontStyle: FontStyle.italic, // Apply italic style
                  letterSpacing: 0.5, // Adjust letter spacing as needed
                ),
              )
          ),
            Text(
              'Mobile: +91 7281887889',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Email: contact.dewall@gmail.com',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
