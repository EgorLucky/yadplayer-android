import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yadplayer/file.dart';

class YaDPlayerServiceAPI{
  YaDPlayerServiceAPI();

  final host = "https://yadplayer.herokuapp.com";

  Future<List<File>> getFiles(String accessToken, String path, int page) async {
    path = Uri.encodeQueryComponent(path);
    var url = Uri.parse(host + "/file/get?page=$page&parentFolderPath=$path");
    var response = await http.get(url, headers: {"Authorization": "Bearer $accessToken"});
    if(response.statusCode != 200) {
      throw Error();
    }
    var jsonResponse = jsonDecode(response.body) as List<dynamic>;

    var result = jsonResponse
                .map(jsonToFile)
                .toList();

    return result;
  }

  Future<Map<String, String>> getAudioUrl(String accessToken, String path) async {
    path = Uri.encodeQueryComponent(path);
    var url = Uri.parse(host + "/file/getUrl?path=$path");

    var response = await http.get(url, headers: {"Authorization": "Bearer $accessToken"});
    if(response.statusCode != 200) {
      throw Error();
    }
    var json = jsonDecode(response.body);

    var result = Map<String, String>();
    result["href"] = json["href"].toString();

    return result;
  }

  Future<File> getRandomFile(String accessToken, String playingFolder, String? search, bool? recursive) async {
    playingFolder = Uri.encodeQueryComponent(playingFolder);
    search = Uri.encodeQueryComponent(search ?? "");
    var url = Uri.parse(host + "/file/getRandomFile?parentFolderPath=$playingFolder&search=$search&recursive=$recursive");
    var response = await http.get(url, headers: {"Authorization": "Bearer $accessToken"});
    if(response.statusCode != 200) {
      throw Error();
    }
    var jsonResponse = jsonDecode(response.body) as dynamic;

    var result = jsonToFile(jsonResponse);

    return result;
  }

  File jsonToFile(e) => File(
      path: e["path"],
      name: e["name"],
      parentFolderPath: e["parentFolderPath"],
      parentFolder: e["parentFolder"],
      type: e["type"],
      yandexUserId: e["yandexUserId"],
      resourceId: e["resourceId"],
      synchronizationProcessId: e["synchronizationProcessId"],
      createDateTime: e["createDateTime"],
      lastUpdateDateTime: e["lastUpdateDateTime"],
    );
}