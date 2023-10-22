class SyncProcess {
  SyncProcess({required this.id,
    required this.createDateTime,
    required this.startDateTime,
    required this.finishedDateTime,
    required this.lastUpdateDateTime,
    required this.offset,
    required this.lastFileId,
    required this.state,
    required this.yandexUserId
  });
  String id;
  DateTime? createDateTime;
  DateTime? startDateTime;
  DateTime? finishedDateTime;
  DateTime? lastUpdateDateTime;
  int offset;
  String? lastFileId;
  SyncProcessState state;
  String yandexUserId;
}

enum SyncProcessState {
  Created,
  Running,
  Paused,
  CanceledByUser,
  CanceledBySystem,
  Finished,
  TokenExpired
}