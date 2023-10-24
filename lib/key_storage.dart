import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyStorage {
  static FlutterSecureStorage storage = new FlutterSecureStorage();

  static const String accessTokenKey = 'yadplayerAccessToken';
  static const String oauthTokenKey = 'yadplayerOauthToken';
  static const String refreshTokenKey = 'yadplayerRefreshToken';

  static Future<String?> getAccessToken() async {
    return await storage.read(key: accessTokenKey);
  }

  static Future setAccessToken(String accessToken) async {
    await storage.write(key: accessTokenKey, value: accessToken);
  }

  static Future<String?> getOauthToken() async {
    return await storage.read(key: oauthTokenKey);
  }

  static Future setOauthToken(String oauthToken) async {
    await storage.write(key: oauthTokenKey, value: oauthToken);
  }

  static Future<String?> getRefreshToken() async {
    return await storage.read(key: refreshTokenKey);
  }

  static Future setRefreshToken(String oauthToken) async {
    await storage.write(key: refreshTokenKey, value: oauthToken);
  }
}