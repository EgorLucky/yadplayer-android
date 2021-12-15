import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yadplayer/YaDPlayerServiceAPI.dart';
import 'package:yadplayer/file.dart';

class FileRepository {
  var yadplayerService = new YaDPlayerServiceAPI();
  var secureStorage = new FlutterSecureStorage();

  @override
  Future<List<File>> getFiles({String path = "", int page = 1}) async {
      var accessToken = (await secureStorage.read(key:"yadplayerAccessToken")).toString();
      var response = await yadplayerService.getFiles(accessToken, path, page);

      return response;
  }

  @override
  Future<String?> getAudioUrl(File file) async {
    var accessToken = (await secureStorage.read(key:"yadplayerAccessToken")).toString();
    var response = await yadplayerService.getAudioUrl(accessToken, file.path);

    return response["href"].toString();
  }

  @override
  Future<File> getRandomFile(String playingFolder, String? search, bool? recursive) async {
    final accessToken = (await secureStorage.read(key:"yadplayerAccessToken")).toString();
    final response = await yadplayerService.getRandomFile(accessToken, playingFolder, search, recursive);

    return response;
  }
}