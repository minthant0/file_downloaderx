class DataUrl {
  String name;
  String age;

  DataUrl.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = json['age'];
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
  };
}