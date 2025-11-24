class Usersmodel {
  final String image;
  final String name;
  final String user_id;
  final String email;
  final int phone;

  Usersmodel({required this.image, required this.name, required this.user_id, required this.email, required this.phone});
  factory Usersmodel.fromJson(json) {
    return Usersmodel(
      image: json['image'],
      email: json['email'],
      name: json['name'],
      user_id: json['user_uid'],
      phone: json['phonenumber'],
    );
  }
  Map<String, dynamic> toJson() => {
    "image": image,
    "name": name,
    'user_uid': user_id,
    "email": email,
    "phonenumber": phone,
  };
}
