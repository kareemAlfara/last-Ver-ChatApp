class  MessageEntity {
        final String message;
  final String image_url;
  final String Sender_id;
  final String reciver_id;
  final String chat_between;
  final String created_at;
  final int id;
  final bool deleted;
  final String message_id;


  MessageEntity({
    required this.message,
    required this.image_url,
    required this.Sender_id,
    required this.reciver_id,
    required this.chat_between,
    required this.created_at,
    required this.id,
    required this.deleted,
    required this.message_id,
  });
  
}