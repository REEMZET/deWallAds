import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class TextSlider extends StatefulWidget {
  final List<String> textItems; // List of text items to display in the slider

  const TextSlider({super.key, required this.textItems});

  @override
  _TextSliderState createState() => _TextSliderState();
}

class _TextSliderState extends State<TextSlider> {
  int _currentIndex = 0; // Current index for the indicator

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 30,
            // Adjust the height of the slider as needed
            autoPlay: true,
            // Enable auto-play
            autoPlayInterval: const Duration(seconds: 3),
            // Set auto-play interval
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            // Set auto-play animation duration
            enableInfiniteScroll: true,
            // Enable infinite scroll
            pauseAutoPlayOnTouch: true,
            // Pause auto-play on touch
            viewportFraction: 0.8,
            // Set the fraction of the viewport to occupy
            enlargeCenterPage: true,
            // Enlarge the center text
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex =
                    index; // Update the current index when the page changes
              });
            },
          ),
          items: widget.textItems.map((text) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 12,
                        // Adjust the text size as needed
                        fontWeight: FontWeight.bold,
                        // Adjust the text style as needed
                        color: Colors.white, // Adjust the text color as needed
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        DotsIndicator(
          dotsCount: widget.textItems.length, // Number of dots to display
          position: _currentIndex, // Current position (converted to int)
          decorator: const DotsDecorator(
            size: Size.square(6.0), // Size of the dots
            activeSize: Size(15.0, 6.0), // Size of the active dot
            color: Colors.grey, // Color of the dots
            activeColor: Colors.blue, // Color of the active dot
          ),
        )
      ],
    );
  }
}
