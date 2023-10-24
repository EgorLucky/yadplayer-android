

import 'package:yadplayer/ya_d_player_service_api/controllers/auth_controller.dart';
import 'package:yadplayer/ya_d_player_service_api/controllers/file_controller.dart';
import 'package:yadplayer/ya_d_player_service_api/controllers/sync_controller.dart';
import 'package:yadplayer/ya_d_player_service_api/controllers/user_controller.dart';

class YaDPlayerServiceAPI{
  YaDPlayerServiceAPI();

  static final host = "http://egorluckydevdomain.ru:3003";

  FileController file = new FileController(host: host);
  AuthController auth = new AuthController(host: host);
  UserController user = new UserController(host: host);
  SyncController sync = new SyncController(host: host);
}