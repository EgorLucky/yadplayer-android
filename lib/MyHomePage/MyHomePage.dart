import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:yadplayer/Authorize/Authorize.dart';
import 'package:yadplayer/Profile/Profile.dart';
import 'package:yadplayer/MyHomePage/AuthState.dart';

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
  FlutterSecureStorage _storage = new FlutterSecureStorage();
  AuthState _authState = AuthState.Undefined;
  bool? _isLogoutExecuted;
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void LogoutExecuted(){
    setState(() {
      _selectedIndex = 0;
      _authState = AuthState.Unauthorized;
      _isLogoutExecuted = true;
    });
  }

  List<Widget>? _widgetOptions;

  @override
  void initState() {
    // TODO: implement initState
    _widgetOptions = <Widget>[
            Text(
              'Index 0: Home',
              style: optionStyle,
            ),
            Profile(logoutExecuted: LogoutExecuted),
            Text(
              'Index 2: School',
              style: optionStyle,
            ),
    ];

    initAsync();
    super.initState();
  }

  void initAsync() async {
    var isAuthorized = await _storage.containsKey(key: "yadplayerAccessToken");

    setState(() {
      _authState = isAuthorized? AuthState.Authorized: AuthState.Unauthorized;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                if(_authState == AuthState.Undefined && _selectedIndex == 0)
                  return Container(
                      child: Center(
                        child: Text('checking auth state...'),
                      ));
                else if(_authState == AuthState.Unauthorized &&
                        (snapshot.hasData == false || _isLogoutExecuted == true)) {
                  return Container(
                      child: Center(
                          child: ElevatedButton(
                            onPressed: _loginButtonClicked,
                            child: Text('Login via yandex'),
                          )));
                }
                else if(_selectedIndex == 0)
                  return Authorize(url: snapshot.data, authorized: onAuthorized);
                else if(_authState == AuthState.Authorized)
                  return _widgetOptions?.elementAt(_selectedIndex) ?? Text('error');
                return Text('error');
            }
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        )
    );
  }

  void _loginButtonClicked() async {
    await canLaunch(_loginUrl) ? await launch(_loginUrl) : throw 'Could not launch $_loginUrl';
    _isLogoutExecuted = false;
  }
}