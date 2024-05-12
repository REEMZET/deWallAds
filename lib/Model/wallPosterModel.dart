class WallPosterModel {
  String wallid;
  String title;
  String postDate;
  String cateogory;
  String postedBy;
  String postedByUsername;
  String postedByUserPhone;
  String wallSize;
  String wallLocation;
  Map<String, double> locationCoordinates;
  String wallRentPrice;
  String available;
  List<String> photosUrl;
  String city;
  String videoUrl;
  int viewCount;


  WallPosterModel({
    required this.wallid,
    required this.title,
    required this.postDate,
    required this.postedBy,
    required this.cateogory,
    required this.postedByUsername,
    required this.postedByUserPhone,
    required this.wallSize,
    required this.wallLocation,
    required this.locationCoordinates,
    required this.wallRentPrice,
    required this.available,
    required this.photosUrl,
    required this.city,
    required this.videoUrl,
    this.viewCount = 0,

  });

  factory WallPosterModel.fromJson(Map<String, dynamic> json) {
    return WallPosterModel(
      wallid: json['wallid'],
      title: json['title'],
      postDate: json['postDate'],
      postedBy: json['postedBy'],
      postedByUsername: json['postedByUsername'],
      postedByUserPhone: json['postedByUserPhone'],
      wallSize: json['wallSize'],
      wallLocation: json['wallLocation'],
      locationCoordinates: Map<String, double>.from(json['locationCoordinates']),
      wallRentPrice: json['wallRentPrice'],
      available: json['available'],
      photosUrl: List<String>.from(json['photosUrl']),
      city: json['city'],
      videoUrl: json['videoUrl'],
      viewCount: json['viewCount'],
      cateogory:json['cateogory'],
    );
  }
}
