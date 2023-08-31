import 'package:yadplayer/ya_d_player_service_api/models/file.dart';
import 'package:yadplayer/ya_d_player_service_api/service_controller.dart';

class FileController extends ServiceController{
  FileController({required String host}) : super(host: host, name: "file");

  Future<List<File>> getFiles(String accessToken, String path, int page, bool recursive) async {
    var jsonResponse = await super.get<List<dynamic>>(
            functionName: "get",
            queryParameters: {
              "page": page.toString(),
              "parentFolderPath": path,
              "recursive" : recursive.toString()
            },
            headers: {"Authorization": "Bearer $accessToken"});

    var result = jsonResponse
        .map(jsonToFile)
        .toList();

    return result;
  }

  Future<Map<String, String>> getAudioUrl(String accessToken, String oauthToken, String path) async {
    var json = await super.get<Map<String, dynamic>>(
        functionName: "getUrl",
        queryParameters: { "path": path },
        headers: {
          "Authorization": "Bearer $accessToken",
          "oauth-token": oauthToken
        });

    var result = Map<String, String>();
    result["href"] = json["href"].toString();

    return result;
  }

  Future<File> getRandomFile(String accessToken, String playingFolder, String? search, bool? recursive) async {
    var jsonResponse = await super.get<dynamic>(
        functionName: "getRandomFile",
        queryParameters: {
          "parentFolderPath": playingFolder,
          "search": search ?? "",
          "recursive": recursive == null? "false" : recursive.toString()
        },
        headers: {"Authorization": "Bearer $accessToken"});

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