import 'package:flutter/material.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';

class Explorewidget extends StatefulWidget {
  final List<CarouselItem> imageUrl;
  final String title;
  final String size;
  final String location;
  final String charges;
  final Function()? onPressed;
  final String viewCount;

  const Explorewidget({
    super.key,
    required this.charges,
    required this.imageUrl,
    required this.title,
    required this.size,
    required this.viewCount,
    this.onPressed,
    required this.location,
  });

  @override
  State<Explorewidget> createState() => _ExplorewidgetState();
}

class _ExplorewidgetState extends State<Explorewidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      surfaceTintColor: Colors.white,
      child: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6),
                topLeft: Radius.circular(6),
              ), // Adjust the radius as needed
              child: CustomCarouselSlider(
                items: widget.imageUrl,
                autoplayDuration: const Duration(seconds: 4),
                autoplay: false,
                width: MediaQuery.of(context).size.width * .9,
                showSubBackground: false,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.blue, size: 14),
                      // Placeholder icon
                      const SizedBox(width: 3),
                      Text(
                        widget.location,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.aspect_ratio,
                          color: Colors.green, size: 14),
                      // Placeholder icon
                      const SizedBox(width: 5),
                      Text(
                        widget.size,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.currency_rupee,
                          color: Colors.pink, size: 16),
                      // Placeholder icon
                      const SizedBox(width: 1),
                      Text(
                        widget.charges,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.pink,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye,
                          color: Colors.black87, size: 16), // Placeholder icon
                      const SizedBox(width: 5),
                      Text(
                        'Views-${widget.viewCount}',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                widget.onPressed?.call();
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Adjust the radius as needed
                ),
                side: const BorderSide(
                  color: Colors.blue, // Set the border color here
                  width: 0.5, // Set the border width
                ),
              ),
              child: const Text(
                "View Details",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(
              height: 6,
            )
          ],
        ),
      ),
    );
  }
}
