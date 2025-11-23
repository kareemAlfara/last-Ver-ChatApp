import 'package:flutter/material.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/screens/ChatingScreen.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class Frindeswidget extends StatelessWidget {
  const Frindeswidget({super.key, required this.model});
  final Userentity model;
  @override
  Widget build(BuildContext context) {
    final currentUid = Supabase.instance.client.auth.currentUser?.id;
    if (currentUid == null) return SizedBox.shrink();

    return model.user_id == uid
        ? SizedBox.shrink()
        : GestureDetector(
            onTap: () {
              navigat(context, widget: Chatingscreen(model: model));
              print("uid $uid");
              print("recever.user_id ${model.user_id}");
            },
            child: Container(
              color: Colors.black.withOpacity(0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(model.image),
                      radius: 33,
                    ),
                    SizedBox(width: 22),
                    defulttext(data: model.name, fSize: 22),
                  ],
                ),
              ),
            ),
          );
  }
}
