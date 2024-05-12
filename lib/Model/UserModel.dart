class UserModel {
  String name;
  String phonenumber;
  String uid;
  String deviceId;
  String regDate;
  String city;
  String state;
  String accounttype;






  UserModel({
    required this.name,
    required this.phonenumber,
    required this.uid,
    required this.deviceId,
    required this.regDate,
    required this.city,
    required this.state,
    required this.accounttype,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phonenumber': phonenumber,
      'uid': uid,
      'deviceid': deviceId,
      'regdate': regDate,
      'city':city,
      'state':state,
      'accounttype':accounttype
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      phonenumber: json['phonenumber'] ?? '',
      uid: json['uid'] ?? '',
      deviceId: json['deviceid'] ?? '',
      regDate: json['regdate'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ??'',
      accounttype: json['accounttype']
    );
  }
}
