import 'package:dewallads/Employee/AdminEnquiryList.dart';
import 'package:dewallads/Employee/UnVerifieddewalls.dart';
import 'package:dewallads/Employee/UserList.dart';
import 'package:dewallads/Employee/VerifieddeWall.dart';
import 'package:dewallads/Pages/AboutDewall.dart';
import 'package:dewallads/Pages/HomePage.dart';
import 'package:dewallads/Pages/Profile.dart';
import 'package:dewallads/WallOwner/AddWall.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/Pagerouter.dart';


class WebEmployeeDashboard extends StatefulWidget {
  const WebEmployeeDashboard({super.key});

  @override
  State<WebEmployeeDashboard> createState() => _WebEmployeeDashboardState();
}

class _WebEmployeeDashboardState extends State<WebEmployeeDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employee Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: Text('deWall ads',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white)),
                  subtitle: Text('Employee Dashboard',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white54)),
                  trailing: const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                ),
                const SizedBox(height: 30)
              ],
            ),
          ),
          Container(
            color: Colors.blue,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.only(topLeft: Radius.circular(200))),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 40,
                mainAxisSpacing: 30,
                children: [
                  itemDashboard(
                      'Upload deWall', CupertinoIcons.add_circled, Colors.teal,
                          () {
                        Navigator.push(context, customPageRoute(AddWall()));
                      }),
                  itemDashboard(
                      'Enquires', Icons.support_agent_rounded, Colors.pink, () {
                    Navigator.push(
                        context, customPageRoute(AdminEnquiryList()));
                  }),
                  itemDashboard('Unverified deWalls', Icons.unpublished,
                      Colors.deepOrange, () {
                        Navigator.push(
                            context, customPageRoute(UnverifieddeWalls()));
                      }),
                  itemDashboard(
                      'Verified dewall', Icons.verified, Colors.pinkAccent, () {
                    Navigator.push(
                        context, customPageRoute(const VerifieddeWalls()));
                  }),
                  itemDashboard(
                      'deWall User', CupertinoIcons.person_3_fill, Colors.blue,
                          () {
                        Navigator.push(context, customPageRoute(UserList()));
                      }),


                  itemDashboard(
                      'Profile', CupertinoIcons.person_2, Colors.purple, () {
                    Navigator.push(context, customPageRoute(const Profile()));
                  }),

                  itemDashboard(
                      'About deWall', CupertinoIcons.info_circle, Colors.brown,
                          () {
                        Navigator.push(context, customPageRoute(AboutDewall()));
                      }),

                ],
              ),
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  itemDashboard(String title, IconData iconData, Color background,
      VoidCallback onPressed) =>
      GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 5),
                color: Theme.of(context).primaryColor.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent),
              ),
            ],
          ),
        ),
      );
}
