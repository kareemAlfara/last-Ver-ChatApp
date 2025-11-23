import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/data/models/messageModel.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/entities/MessageEtity.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/deleteMessageUsecae.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/fetchMessage.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/sendAudioMessageusecase.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/sendmessageUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/uploadFileToSupabaseUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/uploadImageToSupabaseUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/usecase.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/widgets/contactDialog.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/Dependencies_Injection.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({
    required this.sendmessageusecase,
    required this.fetchmessageUsecase,
    required this.deletemessageusecae,
    required this.uploadFileToSupabaseUsecas,
    required this.uploadImageToSupabaseUsecas,
    required this.sendaudiomessageusecase,
  }) : super(MessagesInitial());
  final Sendmessageusecase sendmessageusecase;
  final FetchmessageUsecase fetchmessageUsecase;
  final Deletemessageusecae deletemessageusecae;
  final uploadFileToSupabaseUsecase uploadFileToSupabaseUsecas;
  final uploadImageToSupabaseUsecase uploadImageToSupabaseUsecas;
  final Sendaudiomessageusecase sendaudiomessageusecase;

  Messagemodel? messagemodel;
  bool sendButton = false;
  final ScrollController scrollController = ScrollController();
  static MessagesCubit get(context) => BlocProvider.of(context);
  var messagecontrolle = TextEditingController();
  String generateChatId(String user1, String user2) {
    return (user1.compareTo(user2) < 0) ? '${user1}_$user2' : '${user2}_$user1';
  }

  List<MessageEntity> MessagesList = [];

  Future<void> sendMessage({
    required String receiver_id,
    String? message,
    String? imageUrl,
  }) async {
    try {
      String chatId = generateChatId(uid!, receiver_id);

      await sendmessageusecase.Execute(
        receiver_id: receiver_id,
        message: message,
        imageUrl: imageUrl,
        messageId: const Uuid().v4(),
        chatId: chatId,
      );
      print("1111111111111111111111111111");
      emit(MessagesInsertsuccess());
    } on Exception catch (e) {
      log(e.toString());
      emit(MessagesInsertfailure());
    }
  }

  void FetchMessages({required String receiverId}) {
    String chatId = generateChatId(uid!, receiverId);
    var response = fetchmessageUsecase.Execute(chatId: chatId).listen(
      (messageList) {
        MessagesList = messageList;
        if (!isClosed) {
          emit(FetchmessagesSucess());
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(FetchmessagesError(error: error.toString()));
        }
      },
    );
  }
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
        await sendMessage(receiver_id: receiverId, imageUrl: imageUrl);
      }
    }
  }

  Future<String?> uploadImageToSupabase(File file) async {
    try {
      final resopnse = await uploadImageToSupabaseUsecas.Execute(file);
      return resopnse;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<String?> uploadFileToSupabase({required String receiverId}) async {
    try {
      var response = await uploadFileToSupabaseUsecas.Execute(receiverId);
      await sendMessage(receiver_id: receiverId, imageUrl: response);
      return response;
    } catch (e) {
      print('Upload error: $e');
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
  Future<void> deleteMessage(int messageId) async {
    try {
      await deletemessageusecae.execute(messageId);

      // Remove the message from local data immediately for better UX
      MessagesList.removeWhere((message) => message.id == messageId);

      emit(Messagesuccess());
    } catch (e) {
      emit(Messagefailure(error: e.toString()));
      print("Failed to delete message: $e");
    }
  }

  Future<void> sendAudioMessage({
    required File audioFile,
    required String receiverId,
  }) async {
    try {
      var response = await sendaudiomessageusecase.execute(
        audioFile: audioFile,
        receiverId: receiverId,
      );

      // ✅ Send message with audio URL
      await sendMessage(
        receiver_id: receiverId,
        imageUrl: response,
        message: '', // or "Voice message"
      );

      // ✅ Optional: refresh messages right after sending
      FetchMessages(receiverId: receiverId);

      print('✅ Audio message sent: $response');
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

      await sl<MessagesCubit>().sendMessage(
        receiver_id: receiver_id,
        message: '',
        imageUrl: mapsUrl, // Send as text
      );
      ;
    } catch (e) {
      print("Error getting location: $e");
    }
  }
Future<void> pickAndSendContact({
  required String receiverId,
  required BuildContext context,
}) async {
  try {
    // 1. طلب إذن الوصول لجهات الاتصال
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يجب السماح بالوصول إلى جهات الاتصال')),
      );
      return;
    }

    // 2. جلب كل جهات الاتصال مع الأرقام
    List<Contact> contacts = await FlutterContacts.getContacts(
      withProperties: true, // ✅ مهم جداً: يجلب الأرقام والإيميلات
    );

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا توجد جهات اتصال')),
      );
      return;
    }

    // 3. عرض قائمة جهات الاتصال للاختيار
    Contact? selectedContact = await showDialog<Contact>(
      context: context,
      builder: (BuildContext context) {
        return ContactDialog(contacts: contacts);
      },
    );

    // 4. إرسال جهة الاتصال المحددة
    if (selectedContact != null) {
      await sendContactMessage(
        receiverId: receiverId,
        contact: selectedContact,
      );
    }
  } catch (e) {
    print('❌ Error picking contact: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ في الوصول إلى جهات الاتصال')),
    );
  }
}
Future<void> sendContactMessage({
  required String receiverId,
  required Contact contact,
}) async {
  try {
    // تجهيز معلومات جهة الاتصال
  List<String> contactParts = [];    // الاسم
    contactParts.add('📱 ${contact.displayName.isNotEmpty ? contact.displayName : 'بدون اسم'}');

    // الرقم
    if (contact.phones.isNotEmpty) {
      contactParts.add('📞 ${contact.phones.first.number}');
    }

    // الإيميل
    if (contact.emails.isNotEmpty) {
      contactParts.add('📧 ${contact.emails.first.address}');
    }

    String contactInfo = contactParts.join('\n');

    // إرسال الرسالة
    await sendMessage(
      receiver_id: receiverId,
      message: contactInfo,
    );

    print('✅ Contact sent successfully');
  } catch (e) {
    print('❌ Error sending contact: $e');
  }
}

  // ✅ إضافة متغيرات البحث
  bool isSearching = false;
  String searchQuery = '';
  List<MessageEntity> filteredMessages = [];
  final TextEditingController searchController = TextEditingController();

  // ✅ دالة لتفعيل/إلغاء البحث
  void toggleSearch() {
    isSearching = !isSearching;
    if (!isSearching) {
      searchController.clear();
      searchQuery = '';
      filteredMessages.clear();
    }
    emit(SearchToggleState());
  }

  // ✅ دالة للبحث في الرسائل
  void searchMessages(String query) {
    searchQuery = query;
    
    if (query.isEmpty) {
      filteredMessages.clear();
      emit(SearchResultState());
      return;
    }

    filteredMessages = MessagesList.where((message) {
      final messageText = message.message?.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();
      return messageText.contains(searchLower);
    }).toList();

    emit(SearchResultState());
  }

  // ✅ دالة للحصول على الرسائل المعروضة (عادية أو نتائج بحث)
  List<MessageEntity> get displayedMessages {
    return isSearching && searchQuery.isNotEmpty 
        ? filteredMessages 
        : MessagesList;
  }
  
}


