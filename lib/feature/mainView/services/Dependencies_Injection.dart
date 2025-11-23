import 'package:get_it/get_it.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/deleteMessageUsecae.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/sendAudioMessageusecase.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/uploadFileToSupabaseUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/uploadImageToSupabaseUsecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/data/datasources/message_remote_data_source.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/data/datasources/supabase_message_data_source.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/data/repositories/chatapp_repository.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/repositories/repo.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/fetchMessage.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/sendmessageUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/cubits/meesagescubit/messages_cubit.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // 1. Get current user ID
  final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

  // 2. Register SupabaseClient
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // 3. Register DataSource
  sl.registerLazySingleton<MessageRemoteDataSource>(
    () => SupabaseMessageDataSource(sl<SupabaseClient>()),
  );

  // 4. Register Repository
  sl.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(
      sl<MessageRemoteDataSource>(),
      currentUserId,
    ),
  );

  // 5. Register ALL UseCases ✅ (THIS WAS MISSING!)
  sl.registerLazySingleton(() => Sendmessageusecase(sl<MessageRepository>()));
  sl.registerLazySingleton(() => FetchmessageUsecase(sl<MessageRepository>()));
  sl.registerLazySingleton(() => Deletemessageusecae(sl<MessageRepository>()));
  sl.registerLazySingleton(() => uploadFileToSupabaseUsecase(messageRepository: sl<MessageRepository>()));
  sl.registerLazySingleton(() => uploadImageToSupabaseUsecase(messageRepository: sl<MessageRepository>()));
  sl.registerLazySingleton(() => Sendaudiomessageusecase(sl<MessageRepository>()));

  // 6. Register Cubit
  sl.registerFactory(() => MessagesCubit(
    sendmessageusecase: sl<Sendmessageusecase>(),
    fetchmessageUsecase: sl<FetchmessageUsecase>(),
    deletemessageusecae: sl<Deletemessageusecae>(),
    uploadFileToSupabaseUsecas: sl<uploadFileToSupabaseUsecase>(),
    uploadImageToSupabaseUsecas: sl<uploadImageToSupabaseUsecase>(),
    sendaudiomessageusecase: sl<Sendaudiomessageusecase>(),
  ));
}