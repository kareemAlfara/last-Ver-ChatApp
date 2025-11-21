class Usersmodel {
  final String image;
  final String name;
  final String user_id;

  Usersmodel({required this.image, required this.name, required this.user_id});
  factory Usersmodel.fromJson(json) {
    return Usersmodel(
      image: json['image'],
      name: json['name'],
      user_id: json['user_uid'],
    );
  }
}
