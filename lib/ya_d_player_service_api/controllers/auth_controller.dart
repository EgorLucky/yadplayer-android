import '../service_controller.dart';

class AuthController extends ServiceController{
  AuthController({required String host}) : super(host: host, name: "Auth");

  Future<Map<String, dynamic>> getToken(String code) async {
    final jsonResponse = await super.get<Map<String, dynamic>>(
        functionName: "getToken",
        queryParameters: { "code": code });

    return jsonResponse;
  }
}