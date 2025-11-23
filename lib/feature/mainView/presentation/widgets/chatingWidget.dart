import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/entities/MessageEtity.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/cubits/meesagescubit/messages_cubit.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/widgets/audioWidget.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' as intl;

class chatingWidget extends StatelessWidget {
  const chatingWidget({
    super.key,
    required this.messagemodel,
    required this.receiverId,
    required this.index,
    this.searchQuery,
  });
  
  final int index;
  final MessageEntity messagemodel;
  final String receiverId;
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessagesCubit, MessagesState>(
      listener: (context, state) {},
      builder: (context, state) {
        DateTime parsedDate = DateTime.parse(messagemodel.created_at);
        DateTime localTime = parsedDate.toLocal();
        bool showDate = false;
        
        // ✅ استخدم displayedMessages بدلاً من MessagesList
        final cubit = MessagesCubit.get(context);
        final messagesList = cubit.displayedMessages;
        
        if (index == messagesList.length - 1) {
          showDate = true;
        } else {
          DateTime prevParsedDate = DateTime.parse(
            messagesList[index + 1].created_at,
          );
          DateTime prevLocalTime = prevParsedDate.toLocal();

          if (localTime.year != prevLocalTime.year ||
              localTime.month != prevLocalTime.month ||
              localTime.day != prevLocalTime.day) {
            showDate = true;
          } else {
            showDate = false;
          }
        }
        
        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text("Delete Message"),
                content: Text("Are you sure you want to delete this message?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await MessagesCubit.get(context).deleteMessage(messagemodel.id);
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    },
                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          child: Column(
            children: [
              showDate
                  ? defulttext(
                      data: intl.DateFormat.yMMMMd().format(localTime),
                      color: Colors.white,
                      fSize: 18,
                      fw: FontWeight.bold,
                    )
                  : SizedBox.shrink(),
              Align(
                alignment: messagemodel.Sender_id == uid
                    ? Alignment.topLeft
                    : Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: messagemodel.Sender_id == uid
                          ? Primarycolor
                          : Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: messagemodel.Sender_id == uid
                            ? Radius.circular(0)
                            : Radius.circular(20),
                        topRight: messagemodel.Sender_id == uid
                            ? Radius.circular(20)
                            : Radius.circular(0),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: buildMessageContent(context),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4.0,
                            right: 18,
                            bottom: 2,
                          ),
                          child: messagemodel.Sender_id == uid
                              ? Container(
                                  color: Primarycolor,
                                  child: defulttext(
                                    data: intl.DateFormat('HH:mm').format(localTime),
                                    color: Colors.grey,
                                    fw: FontWeight.bold,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: defulttext(
                                    data: intl.DateFormat('HH:mm').format(localTime),
                                    color: Colors.black,
                                    fw: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildMessageContent(BuildContext context) {
    final fileUrl = messagemodel.image_url ?? '';
    final messageText = messagemodel.message ?? '';

    // ✅ 1. Contact
    if (messageText.startsWith('📱')) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.blue, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                messageText,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ 2. Text only (with search highlight)
    if (fileUrl.isEmpty && messageText.isNotEmpty) {
      // إذا كان في بحث، ميّز النص
      if (searchQuery != null &&
          searchQuery!.isNotEmpty &&
          messageText.toLowerCase().contains(searchQuery!.toLowerCase())) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: _highlightSearchText(messageText, searchQuery!),
          ),
        );
      }

      // نص عادي بدون بحث
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: defulttext(data: messageText, fSize: 17),
      );
    }

    // ✅ 3. Files (audio, location, video, pdf, images)
    final uri = Uri.tryParse(fileUrl);
    final fileExtension = uri?.path.split('.').last.toLowerCase() ?? '';
    final isLocation = fileUrl.startsWith("https://www.google.com/maps");

    // Audio
    if (fileExtension == 'mp3' || fileUrl.contains('.mp3')) {
      return AudioMessageWidget(
        audioUrl: fileUrl,
        isSentByMe: messagemodel.Sender_id == uid,
      );
    }
    // Location
    else if (isLocation) {
      return GestureDetector(
        onTap: () async {
          Uri url = Uri.parse(fileUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: Column(
          children: [
            Image.asset(
              "assets/images/location_image.jpg",
              width: 180,
              height: 100,
              fit: BoxFit.cover,
            ),
            Text(
              "📍 View current Loc",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 17,
              ),
            ),
          ],
        ),
      );
    }
    // Video
    else if (fileExtension == 'mp4' || fileUrl.contains('.mp4')) {
      return AudioMessageWidget(
        audioUrl: fileUrl,
        isSentByMe: messagemodel.Sender_id == uid,
      );
    }
    // PDF
    else if (fileExtension == 'pdf') {
      final fileName = fileUrl.split('uploads/').last;
      return GestureDetector(
        onTap: () => MessagesCubit.get(context).openFile(fileUrl, context),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
              SizedBox(width: 5),
              Expanded(child: defulttext(data: '$fileName', maxLines: 1)),
            ],
          ),
        ),
      );
    }
    // Images
    else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
      return GestureDetector(
        onTap: () => MessagesCubit.get(context).openFile(fileUrl, context),
        child: Image.network(
          fileUrl,
          width: 200,
          height: 130,
          fit: BoxFit.cover,
        ),
      );
    }

    // ✅ Fallback: رسالة نصية
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: defulttext(data: messageText, fSize: 17),
    );
  }

  // ✅ دالة لتمييز النص المطابق بالأصفر
  TextSpan _highlightSearchText(String text, String query) {
    if (query.isEmpty) {
      return TextSpan(
        text: text,
        style: TextStyle(color: Colors.white, fontSize: 17),
      );
    }

    final matches = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          matches.add(TextSpan(
            text: text.substring(start),
            style: TextStyle(color: Colors.white, fontSize: 17),
          ));
        }
        break;
      }

      if (index > start) {
        matches.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(color: Colors.white, fontSize: 17),
        ));
      }

      matches.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          color: Colors.black,
          backgroundColor: Colors.yellow,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + query.length;
    }

    return TextSpan(children: matches);
  }
}