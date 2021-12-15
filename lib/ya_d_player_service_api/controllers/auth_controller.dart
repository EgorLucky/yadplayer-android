import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthController{
  AuthController({required this.host});

  String host;

  Future<Map<String, dynamic>> getToken(String code) async {
    var url = Uri.parse(host + "/Auth/getToken?code=${code}");
    var response = await http.get(url);
    if(response.statusCode != 200) {
      throw Error();
    }

    var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

    return jsonResponse;
  }
}