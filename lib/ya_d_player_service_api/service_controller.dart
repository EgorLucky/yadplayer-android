import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:yadplayer/services/logger.dart';

class ServiceController {
  ServiceController({required this.host, required this.name, required this.logger});

  final String host;
  final String name;
  final Logger logger;

  String get basePath => host + "/" + name;

  Future<T> get<T>({required String functionName, Map<String, String>? queryParameters, Map<String, String>? headers}) async {
    final uri = buildUri(functionName, queryParameters);

    final response = await sendRequest("get", uri: uri, headers: headers);

    return getResult<T>(response);
  }

  Future<T> post<T>({required String functionName, 
                    Map<String, String>? queryParameters, 
                    Map<String, String>? headers,
                    Map<String, String>? form,
                    }) async {
    final uri = buildUri(functionName, queryParameters);
    
    if (headers == null)
      headers = Map<String, String>();
    
    if (form != null)
      headers.addAll({ "content-type" : "application/x-www-form-urlencoded"});

    final response = await sendRequest("post", uri: uri, headers: headers, body: form);

    return getResult<T>(response);
  }

  Uri buildUri(String functionName, Map<String, String>? queryParameters) {
    var url = basePath + "/" + functionName;

    if (queryParameters != null && queryParameters.isNotEmpty) {
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

  Future<Response> sendRequest(String method, {required Uri uri, Map<String, String>? headers, Object? body}) {
    try {
      if (method == "get")
        return http.get(uri, headers: headers);
      if (method == "post")
        return http.post(uri, headers: headers, body: body);
    } on Error
    catch (e) {
      logger.log("ServiceController.sendRequest: exception was thrown: " + e.toString());
      throw e;
    }

    throw ErrorDescription("unknown http method");
  }
}

class UnauthorizedError extends Error {}