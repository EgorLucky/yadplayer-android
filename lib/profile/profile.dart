import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yadplayer/key_storage.dart';
import 'package:yadplayer/ya_d_player_service_api/models/user.dart';
import 'package:yadplayer/ya_d_player_service_api/ya_d_player_service_api.dart';
import 'package:yadplayer/services/service_locator.dart';

class Profile extends StatefulWidget {
  Profile({Key? key, required this.logoutExecuted}) : super(key: key);

  final Function logoutExecuted;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  _ProfileState(): super();
  User? userInfo;
  var storage = getIt<KeyStorage>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {

    var accessToken = await storage.getAccessToken();

    if (userInfo == null && accessToken != null) {
      var yadPlayerService = getIt<YaDPlayerServiceAPI>();

      var jsonResponse = await yadPlayerService.user.getUserInfo(accessToken);

      this.setState(() {
        this.userInfo = jsonResponse;
      });

    }
  }

  void _logoutPressed() async {

    await storage.setAccessToken(null);
    await storage.setRefreshToken(null);

    widget.logoutExecuted.call();
  }


  @override
  Widget build(BuildContext context) {
    var status = "";
    if(userInfo == null) {
      status = 'getting user info...';
    }
    else
      status = 'from ${userInfo?.email}';

    return Container(
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _logoutPressed,
                  child: Text('Logout ${userInfo == null? '' : status}')))));
  }

}