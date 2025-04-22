
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:yadplayer/key_storage.dart';
import 'package:yadplayer/services/service_locator.dart';
import 'package:yadplayer/ya_d_player_service_api/ya_d_player_service_api.dart';

import '../ya_d_player_service_api/models/sync_process.dart';

class Sync extends StatefulWidget {
  Sync({Key? key}) : super(key: key);

  @override
  _SyncState createState() => _SyncState();

}

class _SyncState extends State<Sync> {
  _SyncState(): super();
  List<SyncProcess> syncProcesses = List.empty();
  var isListLoaded = false;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  bool isSynchronizationRunning() => syncProcesses.any((e) => e.state == SyncProcessState.Running || e.state == SyncProcessState.Created);

  void initAsync() async {
    if (!isListLoaded)
      await loadSyncProcesses(1);

    if(isSynchronizationRunning()) {
      startWatchingSyncUpdates();
    }
  }

  Future loadSyncProcesses(int page) async {
    var accessToken = await KeyStorage.getAccessToken();

    if (accessToken != null) {
      var yadPlayerService = getIt<YaDPlayerServiceAPI>();

      var syncProcesses = await yadPlayerService.sync.getSyncs(accessToken, page);

      if(this.mounted)
        this.setState(() {
          this.syncProcesses = syncProcesses;
          this.isListLoaded = true;
        });

    }
  }

  void handleStartSync() async {
    if(isSynchronizationRunning()) {
      return;
    }

    var accessToken = (await KeyStorage.getAccessToken()).toString();
    var oauthToken = (await KeyStorage.getOauthToken()).toString();
    var refreshToken = (await KeyStorage.getRefreshToken()).toString();

    var yadPlayerService = getIt<YaDPlayerServiceAPI>();
    await yadPlayerService.sync.start(accessToken, oauthToken, refreshToken);

    await loadSyncProcesses(1);
    startWatchingSyncUpdates();
  }

  void startWatchingSyncUpdates() async {
    while (this.mounted && isSynchronizationRunning()) {
      await Future.delayed(new Duration(seconds: 2));
      await loadSyncProcesses(1);
    }
  }

  String dateTimeUtcToString(DateTime? dateTime) {
    if(dateTime == null)
      return "";
    dateTime = dateTime.toLocal();

    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    var content = !isListLoaded
        ? Text('getting sync data...')
        : ListView.builder(
                    itemCount: syncProcesses.length,
                    //controller: _controller,
                    itemBuilder: (context, index) {
                      var process = syncProcesses[index];

                      return ListTile(
                        title: Text("${dateTimeUtcToString(process.createDateTime)} - ${process.state.name}"),
                        subtitle: Text("started: ${dateTimeUtcToString(process.startDateTime)} \n"
                            "finished: ${dateTimeUtcToString(process.finishedDateTime)} \n"
                            "offset: ${process.offset}"),
                        isThreeLine: true,
                        tileColor: process.state == SyncProcessState.Running
                            ? Color.fromARGB(127, 134, 134, 139) : null
                      );
                    },
                  );

    return Column(
        children: [
          Container(
              child:Row(
                  children:[
                    Expanded(
                        child: ElevatedButton(
                            onPressed: handleStartSync,
                            child: Text("Start sync")
                        )
                    )
                  ]
              )
          )
          ,
          Expanded(
              child: content
          ),
        ]
    );
  }

}