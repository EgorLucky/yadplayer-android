import 'package:flutter/cupertino.dart';
import 'package:yadplayer/services/database/database.dart';

import 'database/models/logs.dart';

class LogHandler {
  ValueNotifier<LogListState> logListNotifier = ValueNotifier(LogListState());

  final _loadLoadAfterIdTasks = List<int>.empty(growable: true);
  int? _lastId = null;

  void init() async {
    loadNextPage();
  }

  void loadNextPage() async {
    var currentLastId = _lastId ?? 0;

    if(_loadLoadAfterIdTasks.contains(currentLastId))
      return;

    _loadLoadAfterIdTasks.add(currentLastId);

    final logs = await _getLogs(currentLastId);

    _lastId = logs.length > 0 ? logs.last.id : null;

    _loadLoadAfterIdTasks.remove(currentLastId);
  }

  void clearAllLogs() async {
    await DBProvider.db.clearAllLogs();
    logListNotifier.value = LogListState(logs: []);
  }

  Future<List<Log>> _getLogs(int lastId) async {
    final logs = await DBProvider.db.getLogs(lastId, 300, true);

    var oldLogListState = logListNotifier.value;
    oldLogListState.logs.addAll(logs);
    logListNotifier.value = LogListState(logs: oldLogListState.logs);

    return logs;
  }
}

class LogListState {
  LogListState({
    List<Log>? logs
  }) {
    this.logs = logs ?? [];
  }
  late List<Log> logs;
}