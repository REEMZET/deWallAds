import 'package:dewallads/Constants/color_constant.dart';
import 'package:flutter/material.dart';

class Welcometext extends StatelessWidget {
  const Welcometext({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 3, right: 69),
        child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "Hey,",
                  style: TextStyle(
                      color: ColorConstant.blueGray80001,
                      fontSize: 20,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.75)),
              TextSpan(
                  text: " ",
                  style: TextStyle(
                      color: ColorConstant.blueGray80001,
                      fontSize: 20,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.75)),
              TextSpan(
                  text: "User! \n",
                  style: TextStyle(
                      color: ColorConstant.blueGray80001,
                      fontSize: 20,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.75)),
              TextSpan(
                  text: "Let's start exploring",
                  style: TextStyle(
                      color: ColorConstant.blueGray80001,
                      fontSize: 20,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.75)),
              TextSpan(
                  text: " 👋 ",
                  style: TextStyle(
                      color: ColorConstant.blueGray80001,
                      fontSize: 25,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.75))
            ]),
            textAlign: TextAlign.left));
  }
}
