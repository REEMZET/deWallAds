import 'package:flutter/material.dart';

import '../../Constants/Stringsfile.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return DesktopNavBar();
  }

  Widget DesktopNavBar() {
    return Container(
      height: 70,
      color: Colors.pink,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Logo(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              navbutton('HOME'),
              navbutton('ABOUT US'),
              navbutton('GALLERY'),
              navbutton('VIDEOS'),
              navbutton('SERVICES'),
            ],
          ),
        ],
      ),
    );
  }

  Widget navbutton(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: () {},
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          )),
    );
  }

  Widget Logo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          child: Image.network(
            'https://static.vecteezy.com/system/resources/previews/012/011/843/non_2x/indian-wedding-couple-character-bride-and-groom-free-png.png',
            width: 100,
            height: 70,
          ),
        ),
        const Text(
          AppStrings.AppName,
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
