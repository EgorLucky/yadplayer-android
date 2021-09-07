
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Authorize extends StatefulWidget {
  Authorize({Key? key, String? url}) : super(key: key) {
    this.url = url;
  }

  String? url;

  @override
  _AuthorizeState createState() => _AuthorizeState(this.url);
}

class _AuthorizeState extends State<Authorize> {
  _AuthorizeState(String? url): super(){
    _codeUri = url;
  }

  String? _codeUri;
  String? accessToken;
  String? refreshToken;
  dynamic userInfo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    if (_codeUri != null && accessToken == null) {
        var code = _codeUri?.replaceAll("com.egorlucky.yadplayer://getToken?code=", "");
        var url = Uri.parse("https://yadplayer.herokuapp.com/Auth/getToken?code=${code?.toString()}");
        var response = await http.get(url);
        if(response.statusCode != 200) {
          //show error
          return;
        }

        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        var accessToken = jsonResponse['accessToken'].toString();
        var refreshToken = jsonResponse['refreshToken'].toString();

        //save accessToken

        this.setState(() {
          this.accessToken = accessToken;
          this.refreshToken = refreshToken;
        });
    }

    if (userInfo == null) {
      var url = Uri.parse("https://yadplayer.herokuapp.com/User/getUserInfo");
      var response = await http.get(url, headers: {"Authorization": "Bearer ${this.accessToken}"});
        if(response.statusCode != 200) {
          return;
        }

        var jsonResponse = jsonDecode(response.body) as dynamic;

        this.setState(() {
          this.userInfo = jsonResponse;
        });

    }
  }


  @override
  Widget build(BuildContext context) {
    var status = "";
    if (_codeUri != null && accessToken == null) {
      status = 'Getting access token via code....';
    } else if (userInfo == null) {
      status = 'getting user info...';
    }
    else
      status = 'Hello, ${userInfo['email']}!';
    return Container(
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(status,
                    style: Theme.of(context).textTheme.headline6))));
  }
}