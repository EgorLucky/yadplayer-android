import 'package:yadplayer/ya_d_player_service_api/models/user.dart';
import 'package:yadplayer/ya_d_player_service_api/service_controller.dart';

class UserController extends ServiceController{
  UserController({required String host}): super(host: host, name: "user");

  Future<User> getUserInfo(String accessToken) async {
    var jsonResponse = await super.get<Map<String, dynamic>>(
        functionName: "getUserInfo",
        headers: {"Authorization": "Bearer $accessToken"});

    final result = jsonToUser(jsonResponse);
    return result;
  }

  jsonToUser(Map<String, dynamic> j) => User(
      yandexId: j["yandexId"],
      email: j["email"],
      firstname: j["lastname"],
      lastname: j["lastname"],
      login: j["login"],
      sex: j["sex"],
      inviteId: j["inviteId"],
      createDateTime: j["createDateTime"],
      deactivateDateTime: j["deactivateDateTime"],
      activateDateTime: j["activateDateTime"],
      isAdmin: j["isAdmin"]?.toString().toLowerCase() == "true"
  );
}