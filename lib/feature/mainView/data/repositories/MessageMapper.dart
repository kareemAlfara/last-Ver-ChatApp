import 'package:lastu_pdate_chat_app/feature/mainView/data/models/messageModel.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/entities/MessageEtity.dart';

class Messagemapper {
  MessageEntity toEntity(Messagemodel model) {
    return MessageEntity(
      message: model.message,
      image_url: model.image_url,
      Sender_id: model.Sender_id,
      reciver_id: model.reciver_id,
      chat_between:model.chat_between,
      created_at: model.created_at,
      id: model.id,
      deleted: model.deleted,
      message_id: model.message_id,
    );
  }
  Messagemodel toModel(MessageEntity entity) {
    return Messagemodel(
      message: entity.message,
      image_url: entity.image_url,
      Sender_id: entity.Sender_id,
      reciver_id: entity.reciver_id,
      chat_between:entity.chat_between,
      created_at: entity.created_at,
      id: entity.id,
      deleted: entity.deleted,
      message_id: entity.message_id,
    );
  }
}
