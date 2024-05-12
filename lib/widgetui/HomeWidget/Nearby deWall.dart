import 'package:flutter/material.dart';

class NearbydeWall extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String size;
  final String location;
  final String charges;
  final Function()? onPressed;

  const NearbydeWall({
    super.key,
    required this.charges,
    required this.imageUrl,
    required this.title,
    required this.size,
    this.onPressed,
    required this.location,
  });

  @override
  State<NearbydeWall> createState() => _NearbydeWallState();
}

class _NearbydeWallState extends State<NearbydeWall> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      // Use widget.onPressed to access the onPressed function
      child: Container(
          width: 150,
          height: 170,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Card(
            color: Colors.white,
            surfaceTintColor: Colors.white54,
            elevation: 2,
            margin: const EdgeInsets.all(4),
            child: Column(
              children: [
                ClipRRect(
                  // Apply rounded corners to the image
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.imageUrl,
                    height: 110,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return const SizedBox(
                          width: 130,
                          height: 120,
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
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.yellow,
                            size: 10,
                          ),
                          Text(
                            widget.location,
                            style: const TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                      Text(
                        'Rate-${widget.charges}',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.indigo),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
