import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:yadplayer/ya_d_player_service_api/models/user.dart';

class UserController{
  UserController({required this.host});

  String host;

  Future<User> getUserInfo(String accessToken) async {
    var url = Uri.parse(host + "/User/getUserInfo");
    var response = await http.get(url, headers: {"Authorization": "Bearer $accessToken"});
    if(response.statusCode != 200) {
      throw Error();
    }

    var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

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