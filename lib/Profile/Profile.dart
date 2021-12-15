import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  Profile({Key? key, required this.logoutExecuted}) : super(key: key);

  final Function logoutExecuted;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  _ProfileState(): super();
  dynamic userInfo;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    var storage = new FlutterSecureStorage();

    var accessToken = await storage.read(key: "yadplayerAccessToken");

    if (userInfo == null && accessToken != null) {
      var url = Uri.parse("https://yadplayer.herokuapp.com/User/getUserInfo");
      var response = await http.get(url, headers: {"Authorization": "Bearer $accessToken"});
      if(response.statusCode != 200) {
        return;
      }

      var jsonResponse = jsonDecode(response.body) as dynamic;

      this.setState(() {
        this.userInfo = jsonResponse;
      });

    }
  }

  void _logoutPressed() async {
    var storage = new FlutterSecureStorage();

    await storage.delete(key: "yadplayerAccessToken");
    await storage.delete(key: "yadplayerRefreshToken");

    widget.logoutExecuted.call();
  }


  @override
  Widget build(BuildContext context) {
    var status = "";
    if(userInfo == null) {
      status = 'getting user info...';
    }
    else
      status = 'from ${userInfo['email']}';

    return Container(
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _logoutPressed,
                  child: Text('Logout ${userInfo == null? '' : status}')))));
  }

}