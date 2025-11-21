
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lastu_pdate_chat_app/src/data/models/usersmodel.dart';
import 'package:lastu_pdate_chat_app/src/presentation/cubits/meesagescubit/messages_cubit.dart';
import 'package:lastu_pdate_chat_app/src/presentation/screens/CallPage%20.dart';
import 'package:lastu_pdate_chat_app/src/presentation/widgets/chatingWidget.dart';
import 'package:lastu_pdate_chat_app/src/presentation/widgets/vicerecord.dart';
import 'package:lastu_pdate_chat_app/src/services/components.dart';

class Chatingscreen extends StatelessWidget {
  const Chatingscreen({super.key, required this.model});
  final Usersmodel model;
  // final String friendId;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MessagesCubit()..fetchMessages(receiverId: model.user_id),
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
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Primarycolor,
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(model.image),
                    radius: 22,
                  ),
                  // SizedBox(width: 22),
                  defulttext(data: model.name, color: Colors.white, fSize: 22),
                ],
              ),
              actions: [
                
                IconButton(
                  icon: Icon(Icons.videocam),
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
                  icon: Icon(Icons.call),
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

                // IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
                // IconButton(icon: Icon(Icons.call), onPressed: () {}),
                PopupMenuButton<String>(
                  padding: EdgeInsets.all(0),
                  onSelected: (value) {
                    print(value);
                  },
                  itemBuilder: (BuildContext contesxt) {
                    return [
                      PopupMenuItem(
                        child: Text("View Contact"),
                        value: "View Contact",
                      ),
                      PopupMenuItem(
                        child: Text("Media, links, and docs"),
                        value: "Media, links, and docs",
                      ),
                      PopupMenuItem(
                        child: Text("Whatsapp Web"),
                        value: "Whatsapp Web",
                      ),
                      PopupMenuItem(child: Text("Search"), value: "Search"),
                      PopupMenuItem(
                        child: Text("Mute Notification"),
                        value: "Mute Notification",
                      ),
                      PopupMenuItem(
                        child: Text("Wallpaper"),
                        value: "Wallpaper",
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
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        itemCount: cubit.data.length,
                        itemBuilder: (context, index) => chatingWidget(
                          messagemodel: cubit.data[index],
                          receiverId: model.user_id,
                          index: index,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: Row(
                          children: [
                            Expanded(
                              child: defulitTextFormField(
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
                                      await cubit.insterMessage(
                                        message: cubit.messagecontrolle.text,
                                        receiver_id: model.user_id,
                                      );
                                      Future.delayed(
                                        Duration(milliseconds: 100),
                                        () async {
                                          await MessagesCubit.get(
                                            context,
                                          ).scrollController.animateTo(
                                            0.0, // top because list is reversed
                                            duration: Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeOut,
                                          );
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
                                            padding: const EdgeInsets.symmetric(
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
