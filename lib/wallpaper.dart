class Wallpaper {
  final String imageID;
  final String albumImage;
  final String creatorInfo;
  final String creatorLink;
  final String licence;

  Wallpaper._(
      {required this.imageID,
      required this.creatorInfo,
      required this.albumImage,
      required this.creatorLink,
      required this.licence});

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper._(
      imageID: json['imageID'].toString(),
      creatorInfo: json['creatorInfo'].toString(),
      albumImage: json['albumImage'],
      creatorLink: json['creatorLink'].toString(),
      licence: json['licence'].toString(),
    );
  }

  Map<String, String> toJson() => {
        'imageID': imageID,
        'creatorInfo': creatorInfo,
        'albumImage': albumImage,
        'creatorLink': creatorLink,
        'licence': licence,
      };

  @override
  String toString() =>
      'Wallpaper{imageID: $imageID, creatorInfo: $creatorInfo, albumImage: $albumImage, creatorLink: $creatorLink, licence: $licence}';
}
