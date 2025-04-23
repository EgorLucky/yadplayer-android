import 'dart:convert';

import 'package:http/http.dart' as http;

class ServiceController{
  ServiceController({required this.host, required this.name});

  final String host;
  final String name;

  String get basePath => host + "/" + name;

  Future<T> get<T>({required String functionName, Map<String, String>? queryParameters, Map<String, String>? headers}) async {
    final uri = buildUri(functionName, queryParameters);

    final response = await http.get(uri, headers: headers);

    return getResult<T>(response);
  }

  Future<T> post<T>({required String functionName, 
                    Map<String, String>? queryParameters, 
                    Map<String, String>? headers,
                    Map<String, String>? form,
                    }) async {
    final uri = buildUri(functionName, queryParameters);
    
    if(headers == null)
      headers = Map<String, String>();
    
    if(form != null)
      headers.addAll({ "content-type" : "application/x-www-form-urlencoded"});

    final response = await http.post(uri, headers: headers, body: form);

    return getResult<T>(response);
  }

  Uri buildUri(String functionName, Map<String, String>? queryParameters) {
    var url = basePath + "/" + functionName;

    if(queryParameters != null && queryParameters.isNotEmpty){
      url += "?";
      queryParameters.forEach((key, value) => url += key + "=" + Uri.encodeQueryComponent(value) + "&");
    }

    return Uri.parse(url);
  }

  T getResult<T>(http.Response response) {
    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }
    else if (response.statusCode != 200) {
      throw Error();
    }

    var result = jsonDecode(response.body) as T;

    return result;
  }
}

class UnauthorizedError extends Error {}