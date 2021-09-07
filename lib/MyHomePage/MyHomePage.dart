import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../bloc.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  String _loginUrl = "https://oauth.yandex.ru/authorize?client_id=3b45d777976d49aea146b1d79bcd13d1&response_type=code&redirect_uri=com.egorlucky.yadplayer://getToken";
  String? accessToken;
  String? refreshToken;
  dynamic userInfo;

  @override
  void initState() {
    // TODO: implement initState

    initAsync();
    super.initState();
  }

  void initAsync() async {

  }


  @override
  Widget build(BuildContext context) {
    DeepLinkBloc _bloc = Provider.of<DeepLinkBloc>(context);

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
            child:
            StreamBuilder<String>(
              stream: _bloc.state,
              builder: (context, snapshot) {
                if (!snapshot.hasData && accessToken == null) {
                  return Container(
                      child: Center(
                          child: ElevatedButton(
                            onPressed: _launchURL,
                            child: Text('Login via yandex'),
                          )));
                } else if(accessToken == null){

                  var code = snapshot.data?.replaceAll("com.egorlucky.yadplayer://getToken?code=", "");
                  var url = Uri.parse("https://yadplayer.herokuapp.com/Auth/getToken?code=${code?.toString()}");
                  http.get(url)
                  .then((response) async {
                    if(response.statusCode != 200) {
                      return response;
                    }

                    var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
                    var accessToken = jsonResponse['accessToken'].toString();
                    var refreshToken = jsonResponse['refreshToken'].toString();

                    //save accessToken

                    this.setState(() {
                      this.accessToken = accessToken;
                      this.refreshToken = refreshToken;
                    });

                    return response;

                  });

                  return Container(
                      child: Center(
                          child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('Getting access token via code = ${code as String}',
                                  style: Theme.of(context).textTheme.title))));
                } else if (userInfo == null) {
                  var url = Uri.parse("https://yadplayer.herokuapp.com/User/getUserInfo");
                  http.get(url, headers: {"Authorization": "Bearer ${this.accessToken}"})
                      .then((response) async {
                        if(response.statusCode != 200) {
                          return response;
                        }

                        var jsonResponse = jsonDecode(response.body) as dynamic;

                        //save accessToken

                        this.setState(() {
                          this.userInfo = jsonResponse;
                        });

                        return response;

                      });
                  return Container(
                        child: Center(
                              child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Text('getting user info...',
                                        style: Theme.of(context).textTheme.title))));
              }
              return Container(
                    child: Center(
                          child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text('Hello, ${userInfo['email']}!',
                                    style: Theme.of(context).textTheme.title))));
            }
        )
      )
    );
  }

  void _launchURL() async =>
      await canLaunch(_loginUrl) ? await launch(_loginUrl) : throw 'Could not launch $_loginUrl';
}