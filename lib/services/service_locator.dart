import 'package:audio_service/audio_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yadplayer/key_storage.dart';
import 'package:yadplayer/services/file_handler.dart';
import 'package:yadplayer/ya_d_player_service_api/ya_d_player_service_api.dart';

import '../page_manager.dart';
import 'audio_handler.dart';
import 'file_repository.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  var apiHost = dotenv.get('API_HOST');
  // services
  getIt.registerLazySingleton<KeyStorage>(() => KeyStorage());
  getIt.registerLazySingleton<YaDPlayerServiceAPI>(() => YaDPlayerServiceAPI(apiHost: apiHost));
  getIt.registerLazySingleton<FileRepository>(() => FileRepository());
  getIt.registerSingleton<AudioHandler>(await initAudioService());
  getIt.registerLazySingleton<FileHandler>(() => FileHandler());
  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}