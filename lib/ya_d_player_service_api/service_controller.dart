import 'dart:convert';

import 'package:http/http.dart' as http;

class ServiceController{
  ServiceController({required this.host, required this.name});

  final String host;
  final String name;

  String get basePath => host + "/" + name;

  Future<T> get<T>({required String functionName, Map<String, String>? queryParameters, Map<String, String>? headers}) async {
    var url = basePath + "/" + functionName;

    if(queryParameters != null && queryParameters.isNotEmpty){
      url += "?";
      queryParameters.forEach((key, value) => url += key + "=" + Uri.encodeQueryComponent(value) + "&");
    }

    final uri = Uri.parse(url);

    final response = await http.get(uri, headers: headers);

    if(response.statusCode != 200) {
      throw Error();
    }

    var result = jsonDecode(response.body) as T;

    return result;
  }
}