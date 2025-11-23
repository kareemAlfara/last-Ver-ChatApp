import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lastu_pdate_chat_app/feature/auth/data/models/usersmodel.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/data/repositories/chatapp_repository.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/fetchMessage.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/sendmessageUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/cubits/meesagescubit/messages_cubit.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/screens/CallPage%20.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/widgets/chatingWidget.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/widgets/vicerecord.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/Dependencies_Injection.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';

class Chatingscreen extends StatelessWidget {
  const Chatingscreen({super.key, required this.model});
  final Userentity model;
  // final String friendId;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<MessagesCubit>()..FetchMessages(receiverId: model.user_id),

      child: BlocConsumer<MessagesCubit, MessagesState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          var cubit = MessagesCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  // ✅ إذا كان البحث مفعل، أغلقه أولاً
                  if (cubit.isSearching) {
                    cubit.toggleSearch();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Primarycolor,
              title: cubit.isSearching
                  ? TextField(
                      controller: cubit.searchController,
                      autofocus: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search messages...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        cubit.searchMessages(value);
                      },
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(model.image),
                          radius: 22,
                        ),
                        SizedBox(width: 22),
                        Expanded(
                          child: defulttext(
                            data: model.name,
                            color: Colors.white,
                            fSize: 22,
                          ),
                        ),
                      ],
                    ),

              actions: [
                // ✅ زر البحث
                if (!cubit.isSearching) ...[
                  IconButton(
                    icon: Icon(Icons.videocam, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CallPage(
                            callID: model.user_id.toString(),
                            userID: model.user_id.toString(),
                            userName: model.name,
                            isVideo: true,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CallPage(
                            callID: model.user_id.toString(),
                            userID: model.user_id.toString(),
                            userName: model.name,
                            isVideo: false,
                          ),
                        ),
                      );
                    },
                  ),
                ],

                if (!cubit.isSearching)
                  PopupMenuButton<String>(
                    padding: EdgeInsets.all(0),
                    onSelected: (value) async {
                      if (value == "Search") {
                        cubit.toggleSearch();
                      } else if (value == "View Contact") {
                        MessagesCubit.get(context).pickAndSendContact(
                          receiverId: model.user_id,
                          context: context,
                        );
                        // Handle View Contact action
                      } else if (value == "Media, links, and docs") {
                        final fileUrl = await MessagesCubit.get(
                          context,
                        ).uploadFileToSupabase(receiverId: model.user_id);
                        if (fileUrl != null) {
                          print('File uploaded: $fileUrl');
                          // Optionally send fileUrl as a message
                        }
                        // Handle Media, links, and docs action
                      }

                      print(value);
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(child: Text("Search"), value: "Search"),
                        PopupMenuItem(
                          child: Text("View Contact"),
                          value: "View Contact",
                        ),
                        PopupMenuItem(
                          child: Text("Media, links, and docs"),
                          value: "Media, links, and docs",
                        ),
                      ];
                    },
                  ),
              ],
            ),
            body: Stack(
              children: [
                Image.network(
                  "https://web.whatsapp.com/img/bg-chat-tile-dark_a4be512e7195b6b733d9110b408f075d.png",
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),

                Column(
                  children: [
                    // ✅ عرض نتائج البحث
                    if (cubit.isSearching && cubit.searchQuery.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        color: Colors.grey[300],
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Found ${cubit.filteredMessages.length} message(s)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: cubit.displayedMessages.isEmpty
                          ? Center(
                              child: Text(
                                cubit.isSearching
                                    ? 'No messages found'
                                    : 'No messages yet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: cubit.scrollController,
                              reverse: true,
                              itemCount: cubit.displayedMessages.length, // ✅ صح
                              itemBuilder: (context, index) => chatingWidget(
                                messagemodel:
                                    cubit.displayedMessages[index], // ✅ صح
                                receiverId: model.user_id,
                                index: index,
                                searchQuery: cubit.isSearching
                                    ? cubit.searchQuery
                                    : null, // ✅ مهم جداً!
                              ),
                            ),
                    ),
                    //#################################################
                    if (!cubit.isSearching)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 70,
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: defulitTextFormField(
                                  minLines: 1, // ✅ Start with 1 line
                                  maxline: 5,
                                  filled: true, // Important: enables fillColor
                                  fillColor: Colors.grey[200], // Inside color,
                                  onChanged: (value) {
                                    cubit.changeSend(value);
                                  },
                                  controller: cubit.messagecontrolle,
                                  // bordercolor: const Color.fromARGB(255, 245, 6, 6),
                                  textcolor: Colors.black,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.attach_file,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (builder) => bottomSheet(
                                          context,
                                          receiverId: model.user_id,
                                        ),
                                      );
                                    },
                                  ),
                                  hintText: "type anything here.....",
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8,
                                  right: 2,
                                  left: 2,
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Color(0xFF128C7E),
                                  child: IconButton(
                                    icon: Icon(
                                      cubit.sendButton ? Icons.send : Icons.mic,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      if (cubit.sendButton) {
                                        await cubit.sendMessage(
                                          message: cubit.messagecontrolle.text,
                                          receiver_id: model.user_id,
                                        );
                                        Future.delayed(
                                          Duration(milliseconds: 100),
                                          () async {
                                            if (cubit
                                                .scrollController
                                                .hasClients) {
                                              await MessagesCubit.get(
                                                context,
                                              ).scrollController.animateTo(
                                                0.0, // top because list is reversed
                                                duration: Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeOut,
                                              );
                                            }
                                          },
                                        );
                                        cubit.messagecontrolle.clear();

                                        FocusScope.of(context).unfocus();
                                        cubit.sendButton = false;
                                      } else {
                                        print("object is recorder");
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 18.0,
                                                    horizontal: 8,
                                                  ),
                                              child: VoiceRecordingWidget(
                                                onAudioRecorded: (audioFile) async {
                                                  await MessagesCubit.get(
                                                    context,
                                                  ).sendAudioMessage(
                                                    audioFile: audioFile,
                                                    receiverId: model.user_id,
                                                  );
                                                  Navigator.pop(
                                                    context,
                                                  ); // Close the bottom sheet after sending
                                                },
                                                onCancel: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 11),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
