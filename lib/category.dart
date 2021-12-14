class Category {
  final int categoryID;
  final String categoryName;
  final String categoryDesc;
  final String categoryImage;

  Category._(
      {required this.categoryID,
      required this.categoryName,
      required this.categoryDesc,
      required this.categoryImage});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category._(
      categoryID: json['categoryID'],
      categoryName: json['categoryName'],
      categoryDesc: json['categoryDesc'],
      categoryImage: json['categoryImage'],
    );
  }
}
