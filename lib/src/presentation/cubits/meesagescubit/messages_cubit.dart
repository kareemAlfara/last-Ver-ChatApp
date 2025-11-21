import 'dart:developer';
import 'dart:io';
// import 'package:location/location.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lastu_pdate_chat_app/src/data/models/messageModel.dart';
import 'package:lastu_pdate_chat_app/src/domain/usecases/usecase.dart';
import 'package:lastu_pdate_chat_app/src/services/components.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  // final player = AudioPlayer();
  // bool isPlaying = false;
  // Duration duration = Duration.zero;
  // Duration position = Duration.zero;
  MessagesCubit() : super(MessagesInitial());
  Messagemodel? messagemodel;
  bool sendButton = false;
  final ScrollController scrollController = ScrollController();
  static MessagesCubit get(context) => BlocProvider.of(context);
  var messagecontrolle = TextEditingController();
  String generateChatId(String user1, String user2) {
    return (user1.compareTo(user2) < 0) ? '${user1}_$user2' : '${user2}_$user1';
  }

  insterMessage({
    required String receiver_id,
    String? message,
    String? imageUrl,
  }) async {
    String chatId = generateChatId(uid!, receiver_id);
    final String messageId = const Uuid().v4(); // generate UUID

    try {
      final response = await Supabase.instance.client
          .from("messages")
          .insert({
            "Sender_id": uid,
            "message_id": messageId, // ADD THIS
            // "message": message,
            'Messages': message ?? '',
            if (imageUrl != null && imageUrl.isNotEmpty) 'files_url': imageUrl,
            "chat_between": chatId,
            "Recever_id": receiver_id,
          })
          .select()
          .single();
      messagemodel = Messagemodel.fromJson(response);
      // log(messagemodel!.created_at);
      print("1111111111111111111111111111");
      emit(MessagesInsertsuccess());
    } on Exception catch (e) {
      // TODO
      log(e.toString());
      emit(MessagesInsertfailure());
    }
  }

  List<Messagemodel> data = [];
  Future<void> fetchMessages({required String receiverId}) async {
    String chatId = generateChatId(uid!, receiverId);
    await Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq(
          'chat_between',
          chatId,
        ) // Use your primary key    (filter by sender in subscribeToMessages)
        .order('created_at')
        .listen((List<Map<String, dynamic>> data) {
          this.data.clear(); // Optional: clear existing data
          for (var row in data) {
            this.data.add(
              Messagemodel.fromJson(row),
            ); // Ensure fromJson is implemented
          }
          if (!isClosed) {
            emit(FetchmessagesSucess());
          }
        });
  }

  // Future<void> deleteMessage(int messageId) async {
  //   try {
  //     await Supabase.instance.client
  //         .from('ka')
  //         .delete()
  //         .eq('id', messageId); // or use your actual primary key

  //     emit(Messagesuccess());
  //   } catch (e) {
  //     emit(Messagefailure(error: e.toString()));
  //     print("Failed to delete message: $e");
  //   }
  // }

  changeSend(value) {
    if (value.length > 0) {
      sendButton = true;
    } else {
      sendButton = false;
    }
    emit(changeSendState());
  }

  Future<void> pickAndSendImage({
    required String receiverId,
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      final imageUrl = await uploadImageToSupabase(file);
      if (imageUrl != null) {
        await insterMessage(receiver_id: receiverId, imageUrl: imageUrl);
      }
    }
  }

  Future<String?> uploadImageToSupabase(File file) async {
    final supabase = Supabase.instance.client;
    final fileExtension = path.extension(file.path); // .jpg أو .png
    final uniqueId = const Uuid().v4(); // مولد UUID فريد
    final fileName = '$uniqueId$fileExtension'; // اسم جديد وفريد
    final fileBytes = await file.readAsBytes();

    try {
      final response = await supabase.storage
          .from('chat-images')
          .uploadBinary('uploads/$fileName', fileBytes);

      // final String publicUrl = supabase.storage
      //     .from('chat-images')
      //     .getPublicUrl('uploads/$fileName');

      final String publicUrl =
          'https://hmyngrmjiqpwqcwegjbi.supabase.co/storage/v1/object/public/chat-images/uploads/$fileName';

      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<String?> uploadFileToSupabase({required String receiverId}) async {
    // Pick any file
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      final supabase = Supabase.instance.client;
      final fileExtension = path.extension(file.path); // Get .jpg, .pdf, etc
      final uniqueId = const Uuid().v4();
      final fileName = '$uniqueId$fileExtension'; // Unique name

      final fileBytes = await file.readAsBytes();

      try {
        await supabase.storage
            .from('chat-files') // 📦 Change bucket name if needed
            .uploadBinary('uploads/$fileName', fileBytes);

        // Get public URL
        final publicUrl = supabase.storage
            .from('chat-files')
            .getPublicUrl('uploads/$fileName');
        await insterMessage(receiver_id: receiverId, imageUrl: publicUrl);
        print('Uploaded File URL: $publicUrl');
        return publicUrl;
      } catch (e) {
        print('Upload error: $e');
        return null;
      }
    } else {
      print('User canceled file picking');
      return null;
    }
  }

  Future<void> openFile(String filePath, BuildContext context) async {
    final fileExtension = filePath.split('.').last.toLowerCase();

    if (fileExtension == 'pdf') {
      final localPath = await downloadFile(filePath);

      if (localPath != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PDFViewerPage(filePath: localPath)),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to download PDF file')));
      }
    } else {
      launchUrl(Uri.parse(filePath), mode: LaunchMode.externalApplication);
    }
  }

  Future<String?> downloadFile(String url) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${url.split('/').last}';
      await Dio().download(url, filePath);
      return filePath;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  // Alternative approach: Listen to specific database events
  Future<void> listenToMessageChanges({required String receiverId}) async {
    String chatId = generateChatId(uid!, receiverId);

    // Listen to all changes (INSERT, UPDATE, DELETE)
    Supabase.instance.client
        .channel('messages_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_between',
            value: chatId,
          ),
          callback: (payload) {
            print('Database change detected: ${payload.eventType}');

            // Refresh messages when any change occurs
            _refreshMessages(receiverId);
          },
        )
        .subscribe();
  }

  // Helper method to refresh messages
  Future<void> _refreshMessages(String receiverId) async {
    String chatId = generateChatId(uid!, receiverId);

    try {
      final response = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('chat_between', chatId)
          .order('created_at');

      data.clear();
      for (var row in response) {
        data.add(Messagemodel.fromJson(row));
      }

      if (!isClosed) {
        emit(FetchmessagesSucess());
      }
    } catch (e) {
      print('Error refreshing messages: $e');
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await Supabase.instance.client
          .from('messages')
          .delete()
          .eq('id', messageId);

      // Remove the message from local data immediately for better UX
      data.removeWhere((message) => message.id == messageId);

      emit(Messagesuccess());
    } catch (e) {
      emit(Messagefailure(error: e.toString()));
      print("Failed to delete message: $e");
    }
  }

  // Future<void> deleteMessage(int messageId) async {
  //   try {
  //     await Supabase.instance.client
  //         .from('messages')
  //         .delete()
  //         .eq('id', messageId); // or use your actual primary key
  //     emit(Messagesuccess());
  //   } catch (e) {
  //     emit(Messagefailure(error: e.toString()));
  //     print("Failed to delete message: $e");
  //   }
  // }
  Future<void> sendAudioMessage({
    required File audioFile,
    required String receiverId,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final fileExtension = path.extension(audioFile.path); // .mp3
      final uniqueId = const Uuid().v4();
      final fileName = '$uniqueId$fileExtension';
      final fileBytes = await audioFile.readAsBytes();

      // Upload audio to Supabase
      await supabase.storage
          .from('chat-files')
          .uploadBinary('uploads/$fileName', fileBytes);

      // ✅ Get public URL
      final publicUrl = supabase.storage
          .from('chat-files')
          .getPublicUrl('uploads/$fileName');

      // ✅ Send message with audio URL
      await insterMessage(
        receiver_id: receiverId,
        imageUrl: publicUrl,
        message: '', // or "Voice message"
      );

      // ✅ Optional: refresh messages right after sending
      await fetchMessages(receiverId: receiverId);

      print('✅ Audio message sent: $publicUrl');
    } catch (e) {
      print('❌ Failed to send audio: $e');
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> sendLocationMessage({required String receiver_id}) async {
    try {
      Position position = await _getCurrentLocation();
      String mapsUrl =
          "https://www.google.com/maps?q=${position.latitude},${position.longitude}";

      await MessagesCubit().insterMessage(
        receiver_id: receiver_id,
        message: '',
        imageUrl: mapsUrl, // Send as text
      );
    } catch (e) {
      print("Error getting location: $e");
    }
  }
}
