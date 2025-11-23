class Messagemodel {
  final String message;
  final String image_url;
  final String Sender_id;
  final String reciver_id;
  final String chat_between;
  final String created_at;
  final int id;
  final bool deleted;
  final String message_id;

  Messagemodel({
    required this.id,
    required this.created_at,
    required this.message,
    required this.image_url,
    required this.reciver_id,
    required this.Sender_id,
    required this.chat_between,
    required this.deleted,
    required this.message_id,
  });

  factory Messagemodel.fromJson(Map<String, dynamic> json) {
    return Messagemodel(
      id: json['id'],
      Sender_id: json['Sender_id'],
      created_at: json["created_at"],
      message: json['Messages'] ?? "",
      image_url: json['files_url'] ?? "",
      reciver_id: json['Recever_id'].toString(),
      chat_between: json['chat_between'] ?? "",
      deleted: json['deleted'] ?? false,
      message_id: json['message_id'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      "Sender_id":Sender_id,
      "created_at":created_at,
      'Messages': message,
      'files_url': image_url,
      'Recever_id': reciver_id,
      'chat_between': chat_between,
      'deleted': deleted,
        'message_id': message_id,
    };
  }
}
