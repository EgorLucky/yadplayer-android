import 'package:yadplayer/services/logger.dart';
import 'package:yadplayer/ya_d_player_service_api/models/sync_process.dart';

import '../service_controller.dart';

class SyncController extends ServiceController {
  SyncController({required String host, required Logger logger}) : super(host: host, name: "synchronization", logger: logger);

  Future<List<SyncProcess>> getSyncs(String accessToken, int page) async {
    var jsonResponse = await super.post<List<dynamic>>(
        functionName: "get",
        queryParameters: {
          "page": page.toString()
        },
        headers: {"Authorization": "Bearer $accessToken"});

    var result = jsonResponse
        .map(jsonToSyncProcess)
        .toList();

    return result;
  }

  Future start(String accessToken, String oauthToken, String refreshToken) async {
    var response = await super.post<String>(
        functionName: "start",
        headers: {
          "Authorization": "Bearer $accessToken",
          "oauth-token": oauthToken,
          "refresh-token" : refreshToken
        });

  }

  SyncProcess jsonToSyncProcess(e) => SyncProcess(
    id: e["id"],
    createDateTime: DateTime.parse(e["createDateTime"]),
    startDateTime: e["startDateTime"] == null ? null : DateTime.parse(e["startDateTime"]),
    finishedDateTime: e["finishedDateTime"] == null ? null : DateTime.parse(e["finishedDateTime"]),
    lastUpdateDateTime: e["lastUpdateDateTime"] == null ? null : DateTime.parse(e["lastUpdateDateTime"]),
    yandexUserId: e["yandexUserId"],
    offset: e["offset"],
    lastFileId: e["lastFileId"],
    state: SyncProcessState.values.byName(e["state"])
  );


}