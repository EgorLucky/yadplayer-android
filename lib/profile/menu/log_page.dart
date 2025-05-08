import 'package:flutter/material.dart';
import 'package:yadplayer/services/log_handler.dart';
import 'package:yadplayer/services/service_locator.dart';

import '../../services/database/models/logs.dart';

class LogPage extends StatefulWidget {
  LogPage({Key? key}) : super(key: key);

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  _LogPageState() : super();

  final handler = getIt<LogHandler>();
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    _controller.addListener(_scrollListener);
    handler.init();
    super.initState();
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      handler.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
              title: Text('Logs')
          ),
          body: Column(
          children: [
            Expanded(
              child:
                ValueListenableBuilder<LogListState>(
                  valueListenable: handler.logListNotifier,
                  builder: (context, logListState, _) {
                    final logs = logListState.logs;
                    return ListView.builder(
                      itemCount: logs.length,
                      controller: _controller,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return ListTile(
                          title: Text('${DateTime
                              .fromMillisecondsSinceEpoch(
                              log.createDateTimeUnix)}'),
                          subtitle: Text(log.logText),
                          isThreeLine: true,
                        );
                      },
                    );
                  }
                ),
              )
            ]
          )
       );
    }
}