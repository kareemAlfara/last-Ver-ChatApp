import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastu_pdate_chat_app/src/presentation/cubits/meesagescubit/messages_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String? uid;

Color Primarycolor = Color(0xff2B475E);
String Notebox = "notebox";
Future<void> saveUserIdToPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId != null) {
    await prefs.setString('user_id', userId);
  }
}

Future<dynamic> navigat(context, {required Widget widget}) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));

Widget defulttext({
  TextDirection? textDirection,
  required String data,
  double? fSize,
  Color? color = Colors.white,
  FontWeight? fw,
  int? maxLines=4,
}) => Text(
  textDirection: textDirection,
  maxLines: maxLines,
  data,
  style: TextStyle(
    fontSize: fSize,
    color: color,
    fontWeight: fw,
  ).copyWith(overflow: TextOverflow.ellipsis),
);
Widget defulitTextFormField({
  int? maxline = 1,
  String? title,
  String? hintText,
  Widget? suffixIcon,
  Widget? label,
  Color? textcolor = Colors.white,
  // Color? bordercolor=Colors.white,
  Color bordercolor = Colors.white,
  void Function(String)? onChanged,
  TextInputAction? textInputAction,
  TextEditingController? controller,
  String? Function(String?)? validator,
  void Function(String)? onFieldSubmitted,
  bool isobscure = false,
  bool filled = false, // Important: enables fillColor
  Color? fillColor, // Inside color
}) => TextFormField(
  keyboardType: TextInputType.multiline,
  obscureText: isobscure,
  onFieldSubmitted: onFieldSubmitted,
  maxLines: maxline,
  onChanged: onChanged,
  validator: validator,
  textInputAction: textInputAction,
  controller: controller,
  style: TextStyle(color: textcolor),
  decoration: InputDecoration(
    hintStyle: TextStyle(color: Colors.black),
    filled: filled, // Important: enables fillColor
    fillColor: fillColor, // Inside color
    hintText: hintText,
    suffixIcon: suffixIcon,
    label: label,
    labelText: title,
    labelStyle: TextStyle(color: Colors.white),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white),
    ),
    // focusColor: Colors.white,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),

      borderSide: BorderSide(color: Colors.black),
    ),
  ),
);
PreferredSizeWidget noteAppbar({
  required String text,
  required IconData icon,
  required void Function()? onPressed,
}) => AppBar(
  title: defulttext(data: text, fSize: 27),
  actions: [
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.2),
      ),
      child: IconButton(onPressed: onPressed, icon: Icon(icon, size: 30)),
    ),
  ],
);

Widget bottomSheet(context, {required String receiverId}) {
  return Container(
    height: 278,
    width: MediaQuery.of(context).size.width,
    child: Card(
      margin: const EdgeInsets.all(18.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconCreation(
                  Icons.insert_drive_file,
                  Colors.indigo,
                  "Document",
                  onTap: () async {
                    Navigator.pop(context);
                    final fileUrl = await MessagesCubit.get(
                      context,
                    ).uploadFileToSupabase(receiverId: receiverId);
                    if (fileUrl != null) {
                      print('File uploaded: $fileUrl');
                      // Optionally send fileUrl as a message
                    }
                  },
                ),
                SizedBox(width: 40),
                iconCreation(
                  Icons.camera_alt,
                  Colors.pink,
                  "Camera",
                  onTap: () async {
                    print("wwwwwww");
                    Navigator.pop(context);

                    await MessagesCubit.get(context).pickAndSendImage(
                      receiverId: receiverId,
                      source: ImageSource.camera,
                    );
                  },
                ),
                SizedBox(width: 40),
                iconCreation(
                  Icons.insert_photo,
                  Colors.purple,
                  "Gallery",
                  onTap: () async {
                    print("wwwwwww");
                    Navigator.pop(context);
                    await MessagesCubit.get(context).pickAndSendImage(
                      receiverId: receiverId,
                      source: ImageSource.gallery,
                    );

                    // await MessagesCubit.get(
                    //   context,
                    // ).pickAndSendImage(receiverId: model!.user_id);
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconCreation(
                  Icons.headset,
                  Colors.orange,
                  "Audio",
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles();

                    if (result != null && result.files.single.path != null) {
                      File file = File(result.files.single.path!);

                      Navigator.pop(context);
                      await MessagesCubit.get(context).sendAudioMessage(
                        receiverId: receiverId,
                        audioFile: file,
                      );
                    }
                    ;
                  },
                ),
                SizedBox(width: 40),
                iconCreation(
                  Icons.location_pin,
                  Colors.teal,
                  "Location",
                  onTap: () async {
                    Navigator.pop(context);
              await      MessagesCubit.get(
                      context,
                    ).sendLocationMessage(receiver_id: receiverId);
                  },
                ),
                SizedBox(width: 40),
                iconCreation(Icons.person, Colors.blue, "Contact",
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles();

                    if (result != null && result.files.single.path != null) {
                      File file = File(result.files.single.path!);

                      Navigator.pop(context);
                      await MessagesCubit.get(context).sendAudioMessage(
                        receiverId: receiverId,
                        audioFile: file,
                      );
                    }
                    ;
                  },),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget iconCreation(
  IconData icons,
  Color color,
  String text, {
  void Function()? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Icon(
            icons,
            // semanticLabel: "Help",
            size: 29,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            // fontWeight: FontWeight.w100,
          ),
        ),
      ],
    ),
  );
}
