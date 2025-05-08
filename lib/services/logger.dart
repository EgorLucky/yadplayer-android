import 'package:yadplayer/services/database/database.dart';

import 'database/models/logs.dart';

class Logger {
  void log(String text) async {
    final dateTime = DateTime.now();
    final ticks = dateTime.millisecondsSinceEpoch;
    print("$dateTime $text");
    await DBProvider.db.newLog(Log(id:0, createDateTimeUnix: ticks, logText: text));
  }
}