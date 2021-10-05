import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Profile extends StatefulWidget {
  Profile({Key? key, Function? logoutExecuted}) : super(key: key) {
    _logoutExecuted = logoutExecuted;
  }

  Function? _logoutExecuted;

  @override
  _ProfileState createState() => _ProfileState(_logoutExecuted);
}

class _ProfileState extends State<Profile> {
  _ProfileState(Function? logoutExecuted): super() {
    _logoutExecuted = logoutExecuted;
  }
  dynamic userInfo;
  Function? _logoutExecuted;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
  }

  void _logoutPressed() async {
    var storage = new FlutterSecureStorage();

    await storage.delete(key: "yadplayerAccessToken");
    await storage.delete(key: "yadplayerRefrehToken");

    _logoutExecuted?.call();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _logoutPressed,
                  child: Text('Logout')))));
  }

}