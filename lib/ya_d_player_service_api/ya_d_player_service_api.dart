

import 'package:yadplayer/ya_d_player_service_api/controllers/auth_controller.dart';
import 'package:yadplayer/ya_d_player_service_api/controllers/file_controller.dart';
import 'package:yadplayer/ya_d_player_service_api/controllers/sync_controller.dart';
import 'package:yadplayer/ya_d_player_service_api/controllers/user_controller.dart';

class YaDPlayerServiceAPI{
  final String apiHost;

  late FileController file;
  late AuthController auth;
  late UserController user;
  late SyncController sync;

  YaDPlayerServiceAPI({required this.apiHost}) {
    file = new FileController(host: apiHost);
    auth = new AuthController(host: apiHost);
    user = new UserController(host: apiHost);
    sync = new SyncController(host: apiHost);
  }


}