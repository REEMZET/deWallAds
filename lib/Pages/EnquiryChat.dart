import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../Model/UserModel.dart';
import '../utils/ChatBubble.dart';
import '../widgetui/NotificationWidget/OneSignalNotificationwithoutimage.dart';

class EnquiryChat extends StatefulWidget {
  final String enquiryid;
  final String companyid;
  final String CompanyName;
  final String wallid;
  final String companyphone;

  const EnquiryChat(
      {super.key, required this.enquiryid, required this.companyid, required this.CompanyName, required this.wallid, required this.companyphone});

  @override
  State<EnquiryChat> createState() => _EnquiryChatState();
}

final TextEditingController _messageController = TextEditingController();

ScrollController _scrollController = ScrollController();
User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
UserModel? userModel;

late DatabaseReference _databaseReference;
late DatabaseReference adminenqstatusref,userRef,companyenqstatusref;
late List<String> uidlist;
late List<String> Companyid;
late String Companyname;


class _EnquiryChatState extends State<EnquiryChat> {
  void getUserDetails(String userPhoneNumber) {
     userRef = FirebaseDatabase.instance
        .reference()
        .child('deWall')
        .child('User')
        .child(userPhoneNumber);
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
        userModel = UserModel(
          name: data['name'] ?? '',
          phonenumber: data['phonenumber'] ?? '',
          uid: data['uid'] ?? '',
          deviceId: data['deviceid'] ?? '',
          regDate: data['regdate'] ?? '',
          city: data['city'] ?? '',
          state: data['state'] ?? '',
          accounttype: data['accounttype'] ?? '',
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Companyid = [widget.companyid];
    Companyname=widget.CompanyName;
    if (user != null) {
      getUserDetails(phoneNumber!);
      _databaseReference = FirebaseDatabase.instance
          .reference().child('deWall/chats').child(widget.enquiryid);
      companyenqstatusref=FirebaseDatabase.instance.reference().child('deWall').child('User').child(widget.companyphone).child('Enquiries').child(widget.wallid);

      getAdminUid();
    }
  }

  @override
  Widget build(BuildContext context) {
    adminenqstatusref = FirebaseDatabase.instance
        .reference()
        .child('deWall/Admin/Enquiries')
        .child(widget.enquiryid)
        .child('status');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            Text('${Companyname ?? 'Unknown Owner'}', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(child: Messagelist()),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: 5,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget Messagelist() {
  return Container(
    margin: const EdgeInsets.only(bottom: 0),
    child: FirebaseAnimatedList(
      query: _databaseReference,
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        String text = snapshot.child('text').value.toString();
        String sender = snapshot.child('sender').value.toString();
        return ChatBubble(
          text: text,
          isCurrentUser: sender == userModel!.uid,
        );
      },
    ),
  );
}

void _sendMessage() {
  String messageText = _messageController.text.trim();
  if (messageText.isNotEmpty) {
    Message message = Message(
      text: messageText,
      sender: userModel!.uid,
    );
    _databaseReference.push().set(message.toMap());
    
    if (userModel?.accounttype == 'company') {
      updateseenstatusadmin();
      sendpushnotificationtoadmin(messageText);
    } else {
      updateseenstatuscompany();
      sendpushnotificationtoCompany(messageText);
    }

    _messageController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
}

class Message {
  late String text;
  late String sender;
  late DateTime timestamp; // Add timestamp property

  Message({
    required this.text,
    required this.sender,
  }) {
    timestamp = DateTime.now();
  }

  Message.fromMap(Map<dynamic, dynamic> map) {
    text = map['text'];
    sender = map['sender'];
    timestamp = DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

void updateseenstatusadmin() {
  adminenqstatusref.set('Unseen');
}
void updateseenstatuscompany() {
  companyenqstatusref.child('status').set('Unseen');
}

Future<void> sendpushnotificationtoadmin(
  String msg,
) async {
  final pushoneSignalNotification = PushOneSignalNotification(
    restApiKey: 'OTY3ODBmMzYtOGM2YS00MWRkLWJjYjctYmUxYTMzYjE3Y2Y0',
    appId: 'bbe4c4df-2829-4e6e-91fd-3c97c11fbbc1',
  );

  await pushoneSignalNotification.sendPushNotification(
    message: msg,
    title: 'deWall ads',
    heading: 'New message from deWall ads',
    externalIds: uidlist,
    targetChannel: 'push',
    customData: {"custom_key": "custom_value"},
    // imageUrl: 'https://example.com/your-image.jpg',
  );
}

Future<void> sendpushnotificationtoCompany(
  String msg,
) async {
  final pushoneSignalNotification = PushOneSignalNotification(
    restApiKey: 'OTY3ODBmMzYtOGM2YS00MWRkLWJjYjctYmUxYTMzYjE3Y2Y0',
    appId: 'bbe4c4df-2829-4e6e-91fd-3c97c11fbbc1',
  );

  await pushoneSignalNotification.sendPushNotification(
    message: msg,
    title: 'deWall ads',
    heading: 'New message from deWall ads',
    externalIds: Companyid,
    targetChannel: 'push',
    customData: {"custom_key": "custom_value"},
    // imageUrl: 'https://example.com/your-image.jpg',
  );
}

Future<void> getAdminUid() async {
  DatabaseReference starCountRef = FirebaseDatabase.instance.ref('deWall/uid');
  starCountRef.onValue.listen((DatabaseEvent event) {
    final data = event.snapshot.value;
    if (data is String) {
      uidlist = data.split(',');
      for (var uid in uidlist) {
        print(uid);
      }
    } else {
      print('Invalid data format');
    }
  });
}
