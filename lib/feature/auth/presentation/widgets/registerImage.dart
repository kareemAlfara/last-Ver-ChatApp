import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/cubit/logincubit/registercubit/register_cubit.dart';


class registerImage extends StatelessWidget {
  const registerImage({
    super.key,
    required this.cubit,
  });

  final RegisterCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                    cubit.imageUrl ??
                        "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg",
                  ),
                ),
                color: Colors.grey,
                borderRadius: BorderRadius.circular(22),
              ),
              width: 150,
              height: 160,
            ),
            IconButton(
              onPressed: () async {
                await cubit.pickAndSendImage(
                  source: ImageSource.gallery,
                );
              },
              icon: Icon(
                Icons.photo_camera,
                color: Colors.blueAccent,
                size: 33,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
