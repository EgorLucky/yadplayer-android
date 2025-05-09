import 'package:yadplayer/services/logger.dart';

import '../service_controller.dart';

class AuthController extends ServiceController {
  AuthController({required String host, required Logger logger}) : super(host: host, name: "Auth", logger: logger);

  Future<Map<String, dynamic>> getToken(String code) async {
    final jsonResponse = await super.post<Map<String, dynamic>>(
        functionName: "getToken",
        form: { "code": code });

    return jsonResponse;
  }
}