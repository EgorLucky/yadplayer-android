import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yadplayer/ya_d_player_service_api/ya_d_player_service_api.dart';
import 'package:yadplayer/services/service_locator.dart';

class Authorize extends StatefulWidget {
  Authorize({Key? key,
      required this.url,
      required this.authorized,
      required this.isLogoutExecuted,
      required this.loginButtonClicked}) : super(key: key);

  final String? url;
  final bool isLogoutExecuted;

  final Function authorized;
  final void Function() loginButtonClicked;

  @override
  _AuthorizeState createState() => _AuthorizeState();
}

class _AuthorizeState extends State<Authorize> {
  _AuthorizeState(): super();

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    var storage = new FlutterSecureStorage();

    if (widget.url != null) {
        final uri = Uri.parse(widget.url.toString());
        var code = uri.queryParameters["code"].toString();

        var yadPlayerService = getIt<YaDPlayerServiceAPI>();

        var jsonResponse = await yadPlayerService.auth.getToken(code);

        var accessToken = jsonResponse['access_token'].toString();
        var oauthToken = jsonResponse['oauth_token'].toString();
        var refreshToken = jsonResponse['refresh_token'].toString();

        await storage.write(key: "yadplayerAccessToken", value: accessToken);
        await storage.write(key: "yadplayerOauthToken", value: oauthToken);
        await storage.write(key: "yadplayerRefreshToken", value: refreshToken);

        widget.authorized.call();
    }
  }


  @override
  void didUpdateWidget(covariant Authorize oldWidget) {
    super.didUpdateWidget(oldWidget);
    initAsync();
  }


  @override
  Widget build(BuildContext context) {
    if((widget.url == null || widget.isLogoutExecuted == true)) {
      return Container(
          child: Center(
              child: ElevatedButton(
                onPressed: widget.loginButtonClicked,
                child: Text('Login via yandex'),
              )));
    }

    return Container(
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Getting access token via code....',
                    style: Theme.of(context).textTheme.titleLarge))));
  }
}