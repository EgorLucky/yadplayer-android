import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:yadplayer/page_manager.dart';
import 'package:yadplayer/services/service_locator.dart';

import 'my_home_page/my_home_page.dart';
import 'bloc.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  try {
    await setupServiceLocator();
  }
  catch(ex) {
    log('Failed to setup service locator: ' + ex.toString());
  }

  try {
    runApp(MyApp());
  }
  catch(ex) {
    log('Failed to start app: ' + ex.toString());
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DeepLinkBloc _bloc = DeepLinkBloc();

    return MaterialApp(
      title: 'YaDPlayer',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          body: Provider<DeepLinkBloc>(
              create: (context) => _bloc,
              dispose: (context, bloc) => bloc.dispose(),
              child: MyHomePage(title: 'YaDPlayer')))
      //home: my_home_page(title: 'Flutter Demo Home Page'),
    );
  }
}





