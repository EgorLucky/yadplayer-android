import 'package:audio_service/audio_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yadplayer/key_storage.dart';
import 'package:yadplayer/services/file_handler.dart';
import 'package:yadplayer/services/log_handler.dart';
import 'package:yadplayer/services/logger.dart';
import 'package:yadplayer/ya_d_player_service_api/ya_d_player_service_api.dart';

import '../page_manager.dart';
import 'audio_handler.dart';
import 'file_repository.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  print("setupServiceLocator: start executing");
  var apiHost = dotenv.get('API_HOST');

  print("setupServiceLocator: got API_HOST from env: $apiHost");
  // services
  getIt.registerLazySingleton<KeyStorage>(() => KeyStorage());

  print("setupServiceLocator: registred KeyStorage");

  getIt.registerLazySingleton<Logger>(() => Logger());

  print("setupServiceLocator: registred Logger");

  getIt.registerLazySingleton<YaDPlayerServiceAPI>(() => YaDPlayerServiceAPI(apiHost: apiHost));

  print("setupServiceLocator: registred YaDPlayerServiceAPI");

  getIt.registerLazySingleton<FileRepository>(() => FileRepository());

  print("setupServiceLocator: registred FileRepository");

  getIt.registerSingleton<AudioHandler>(await initAudioService());

  print("setupServiceLocator: registred AudioHandler");

  getIt.registerLazySingleton<FileHandler>(() => FileHandler());

  print("setupServiceLocator: registred FileHandler");

  getIt.registerLazySingleton<LogHandler>(() => LogHandler());

  print("setupServiceLocator: registred LogHandler");

  getIt.registerLazySingleton<PageManager>(() => PageManager());

  print("setupServiceLocator: registred PageManager");
}