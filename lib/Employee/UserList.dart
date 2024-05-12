import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('deWall/User');
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'deWall User_List',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: buildSearchWidget(),
          ),
          Expanded(
            child: UserListWidget(),
          ),
        ],
      ),
    );
  }

  Widget UserListWidget() {
    return FirebaseAnimatedList(
      scrollDirection: Axis.vertical,
      query: usersRef,
      itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
        final data = snapshot.value;
        if (data != null && data is Map) {
          String accounttype = data['accounttype'].toString();
          String city = data['city'].toString();
          String name = data['name'].toString();
          String phonenumber = data['phonenumber'].toString();
          String regdate = data['regdate'].toString();

          if (phonenumber.contains(searchController.text)) {
            return Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Phone: $phonenumber',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'City: $city',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Registration Date: $regdate',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Account Type: $accounttype',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      buildAccountTypePopupMenu(accounttype, phonenumber),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        return const SizedBox(); // Return an empty container if data is not in the expected format or if the phone number does not match the search.
      },
    );
  }

  Widget buildSearchWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.grey[100],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.search,
              color: Colors.black87,
              size: 15,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 12),
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search by phone number..",
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    // Update the search results when the text changes
                    // You may also want to add some debouncing to avoid making too many requests in a short period.
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  void updateAccountTypeAndCloseDialog(String phone, String accountType, BuildContext context) {
    DatabaseReference userRef = FirebaseDatabase.instance
        .reference()
        .child('deWall/User')
        .child(phone);

    userRef
        .update({'accounttype': accountType})
        .then((_) {
      // Update successful
      print('User assigned as an employee successfully');

    })
        .catchError((error) {
      // Handle the error
      print('Error assigning user as an employee: $error');
      Navigator.of(context).pop(); // Close the dialog
    });
  }
  Widget buildAccountTypePopupMenu(String currentAccountType, String phone) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        // Handle the selected account type
        updateAccountTypeAndCloseDialog(phone, result, context);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'employee',
          child: Text('Employee'),
        ),
        const PopupMenuItem<String>(
          value: 'wallowner',
          child: Text('Wall Owner'),
        ),
        const PopupMenuItem<String>(
          value: 'company',
          child: Text('Company'),
        ),
      ],
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Assign Role'),
      ),
    );
  }
}
