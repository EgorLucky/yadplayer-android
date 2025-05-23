import 'package:yadplayer/key_storage.dart';
import 'package:yadplayer/services/logger.dart';
import 'package:yadplayer/services/service_locator.dart';
import 'package:yadplayer/ya_d_player_service_api/ya_d_player_service_api.dart';
import 'package:yadplayer/ya_d_player_service_api/models/file.dart';

class FileRepository {
  var yadplayerService = getIt<YaDPlayerServiceAPI>();
  var storage = getIt<KeyStorage>();
  final _logger = getIt<Logger>();

  Future<List<File>> getFiles({String path = "", int page = 1, bool recursive = false}) async {
      var accessToken = (await storage.getAccessToken()).toString();
      var response = await yadplayerService.file.getFiles(accessToken, path, page, recursive, 300);

      return response;
  }

  Future<String?> getAudioUrl(File file) async {
    var accessToken = (await storage.getAccessToken()).toString();
    var oauthToken = (await storage.getOauthToken()).toString();
    var response = await yadplayerService.file.getAudioUrl(accessToken, oauthToken, file.path);

    return response["href"].toString();
  }

  Future<File> getRandomFile(String playingFolder, String? search, bool? recursive) async {
    final accessToken = (await storage.getAccessToken()).toString();
    _logger.log("file_repository.getRandomFile: calling yadplayerService.file.getRandomFile");
    final response = await yadplayerService.file.getRandomFile(accessToken, playingFolder, search, recursive);
    _logger.log("file_repository.getRandomFile: got response from yadplayerService.file.getRandomFile");
    return response;
  }
}