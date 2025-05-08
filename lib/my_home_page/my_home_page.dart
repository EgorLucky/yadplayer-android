import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yadplayer/Authorize/authorize.dart';
import 'package:yadplayer/file_browser/file_browser.dart';
import 'package:yadplayer/key_storage.dart';
import 'package:yadplayer/page_manager.dart';
import 'package:yadplayer/profile/profile.dart';
import 'package:yadplayer/audio_player/audio_player.dart';
import 'package:yadplayer/my_home_page/auth_state.dart';
import 'package:yadplayer/services/service_locator.dart';
import 'package:yadplayer/ya_d_player_service_api/service_controller.dart';

import '../bloc.dart';
import '../sync/sync.dart';
import '../ya_d_player_service_api/models/user.dart';
import '../ya_d_player_service_api/ya_d_player_service_api.dart';

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
  var _loginUrl = "${dotenv.get('API_HOST')}/auth/authorize?returnUrl=com.egorlucky.yadplayer://getToken";
  var _storage = getIt<KeyStorage>();
  var apiService = getIt<YaDPlayerServiceAPI>();
  AuthState _authState = AuthState.undefined;
  bool _isLogoutExecuted = false;
  int _selectedIndex = 0;

  void logoutExecuted(){
    setState(() {
      _selectedIndex = 0;
      _authState = AuthState.unauthorized;
      _isLogoutExecuted = true;
    });
  }

  void onAuthorized(){
    setState(() {
      _authState = AuthState.authorized;
    });
    getIt<PageManager>().init();
  }

  List<Widget>? _widgetOptions;

  @override
  void initState() {
    _widgetOptions = <Widget>[
            FileBrowser(),
            Sync(),
            Profile(logoutExecuted: logoutExecuted),
    ];

    initAsync();
    super.initState();
  }

  void initAsync() async {
    var accessToken = await _storage.getAccessToken();
    User? user;
    try {
      user = accessToken != null
          ? await apiService.user.getUserInfo(accessToken)
          : null;
    }
    on UnauthorizedError
    catch (error) {
      //ignore
    }
    on Error
    catch (error) {
      //think what to do
    }

    setState(() {
      _authState = user != null ? AuthState.authorized: AuthState.unauthorized;
    });

    if (_authState == AuthState.authorized) {
      getIt<PageManager>().init();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _loginButtonClicked() async {
    var loginUri = Uri.parse(_loginUrl);
    //if(await canLaunchUrl(uri)) //always returns false on miui 14
      await launchUrl(loginUri, mode: LaunchMode.externalApplication);
    //else throw 'Could not launch $_loginUrl';
    setState(() {
      _isLogoutExecuted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    DeepLinkBloc _bloc = Provider.of<DeepLinkBloc>(context);

    return Scaffold(
        appBar: _authState == AuthState.authorized ? AppBar(
          // Here we take the value from the my_home_page object that was created by
          // the App.build method, and use it to set our appbar title.
          title:  Text(widget.title),
        ) : null,
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.

            child:
            StreamBuilder<String>(
                  stream: _bloc.state,
                  builder: (context, snapshot) {
                    if(_authState == AuthState.undefined)
                      return Container(
                          child: Center(
                            child: Text('checking auth state...'),
                          ));
                    if(_authState == AuthState.unauthorized) {
                      return Authorize(
                          url: snapshot.data,
                          authorized: onAuthorized,
                          isLogoutExecuted: _isLogoutExecuted,
                          loginButtonClicked: _loginButtonClicked);
                    }
                    else if(_authState == AuthState.authorized) {
                      var currentWidget = _widgetOptions?.elementAt(_selectedIndex) ?? Text('error');
                      return Column(
                              children: [
                                Expanded(
                                    flex: 5,
                                    child: currentWidget),
                                Expanded(
                                    flex: 0,
                                    child: AudioPlayer())
                      ]);
                    }
                    return Text('error');
                }
            )
      ),
      bottomNavigationBar: _authState == AuthState.authorized ? BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sync),
              label: "Sync"),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ) : null
    );
  }
}