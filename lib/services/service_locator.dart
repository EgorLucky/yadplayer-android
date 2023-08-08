import 'package:audio_service/audio_service.dart';
import 'package:yadplayer/services/file_handler.dart';

import '../page_manager.dart';
import 'audio_handler.dart';
import 'file_repository.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  getIt.registerLazySingleton<FileRepository>(() => FileRepository());
  getIt.registerSingleton<AudioHandler>(await initAudioService());
  getIt.registerLazySingleton<FileHandler>(() => FileHandler());
  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}