

import 'package:yadplayer/services/logger.dart';
import 'package:yadplayer/services/service_locator.dart';
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
  final _logger = getIt<Logger>();

  YaDPlayerServiceAPI({required this.apiHost}) {
    file = new FileController(host: apiHost, logger: _logger);
    auth = new AuthController(host: apiHost, logger: _logger);
    user = new UserController(host: apiHost, logger: _logger);
    sync = new SyncController(host: apiHost, logger: _logger);
  }


}