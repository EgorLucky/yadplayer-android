import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyStorage {
  static FlutterSecureStorage storage = new FlutterSecureStorage();

  static const String accessTokenKey = 'yadplayerAccessToken';
  static const String oauthTokenKey = 'yadplayerOauthToken';
  static const String refreshTokenKey = 'yadplayerRefreshToken';

  Future<String?> getAccessToken() async {
    return await storage.read(key: accessTokenKey);
  }

  Future setAccessToken(String? accessToken) async {
    await setValue(accessTokenKey, accessToken);
  }

  Future<String?> getOauthToken() async {
    return await storage.read(key: oauthTokenKey);
  }

  Future setOauthToken(String? oauthToken) async {
    await setValue(oauthTokenKey, oauthToken);
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: refreshTokenKey);
  }

  Future setRefreshToken(String? refreshToken) async {
    await setValue(refreshTokenKey, refreshToken);
  }

  Future setValue(String key, String? value) async {
    if (value == null)
      await storage.delete(key: key);
    else
      await storage.write(key: key, value: value);
  }
}