// supabase_remote_data_source.dart
import 'package:lastu_pdate_chat_app/src/data/models/messageModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseRemoteDataSource {
  Future<void> sendMessage(Messagemodel message);
  Stream<List<Messagemodel>> streamMessages(String chatId);
  Future<void> deleteMessage(String messageId);
}

class SupabaseRemoteDataSourceImpl implements SupabaseRemoteDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<void> sendMessage(Messagemodel message) async {
    await supabase.from('messages').insert(message.toJson());
  }

  @override
  Stream<List<Messagemodel>> streamMessages(String chatId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .map((data) => data
            .map((e) => Messagemodel.fromJson(e))
            .where((msg) => msg.deleted == false) // hide deleted msgs
            .toList());
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await supabase
        .from('messages')
        .update({'deleted': true})
        .eq('id', messageId);
  }
}
