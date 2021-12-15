

import 'package:yadplayer/ya_d_player_service_api/controllers/auth_controller.dart';
import 'package:yadplayer/ya_d_player_service_api/controllers/file_controller.dart';
import 'package:yadplayer/ya_d_player_service_api/controllers/user_controller.dart';

class YaDPlayerServiceAPI{
  YaDPlayerServiceAPI();

  static final host = "https://yadplayer.herokuapp.com";

  FileController file = new FileController(host: host);
  AuthController auth = new AuthController(host: host);
  UserController user = new UserController(host: host);
}