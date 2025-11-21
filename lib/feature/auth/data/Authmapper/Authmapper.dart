import 'package:lastu_pdate_chat_app/feature/auth/data/models/usersmodel.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';

class Authmapper {
  Usersmodel fromEntity(Userentity entity) {
    return Usersmodel(
      image: entity.image,
      email: entity.email,
      name: entity.name,
      user_id: entity.user_id,
    );
  }

  Userentity toEntity(Usersmodel model) {
    return Userentity(
      image: model.image,
      email: model.email,
      name: model.name,
      user_id: model.user_id,
    );
  }
}
