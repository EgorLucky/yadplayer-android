import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yadplayer/ya_d_player_service_api/ya_d_player_service_api.dart';
import 'package:yadplayer/ya_d_player_service_api/models/file.dart';

class FileRepository {
  var yadplayerService = new YaDPlayerServiceAPI();
  var secureStorage = new FlutterSecureStorage();

  Future<List<File>> getFiles({String path = "", int page = 1, bool recursive = false}) async {
      var accessToken = (await secureStorage.read(key:"yadplayerAccessToken")).toString();
      var response = await yadplayerService.file.getFiles(accessToken, path, page, recursive);

      return response;
  }

  Future<String?> getAudioUrl(File file) async {
    var accessToken = (await secureStorage.read(key:"yadplayerAccessToken")).toString();
    var oauthToken = (await secureStorage.read(key:"yadplayerOauthToken")).toString();
    var response = await yadplayerService.file.getAudioUrl(accessToken, oauthToken, file.path);

    return response["href"].toString();
  }

  Future<File> getRandomFile(String playingFolder, String? search, bool? recursive) async {
    final accessToken = (await secureStorage.read(key:"yadplayerAccessToken")).toString();
    final response = await yadplayerService.file.getRandomFile(accessToken, playingFolder, search, recursive);

    return response;
  }
}