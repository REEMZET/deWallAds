import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class DirectionButton extends StatelessWidget {
  final String geocordinates;

  DirectionButton({
    required this.geocordinates
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _openMaps();
      },
      child: Text('deWall Direction',style: TextStyle(color: Colors.white),),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _openMaps() async {
    // Construct the map URL with the destination coordinates
    String mapUrl = 'https://www.google.com/maps/dir/?api=1&destination=$geocordinates';

    // Check if the URL can be launched
    if (await canLaunch(mapUrl)) {
      // Launch the map application with directions
      await launch(mapUrl);
    } else {
      // Handle the case where the URL cannot be launched
      print('Could not launch $mapUrl');
    }
  }
}