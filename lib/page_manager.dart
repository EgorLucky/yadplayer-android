import 'package:flutter/foundation.dart';
import 'package:yadplayer/services/file_handler.dart';
import 'package:yadplayer/ya_d_player_service_api/models/file.dart';
import 'package:audio_service/audio_service.dart';
import 'package:yadplayer/playlist_state.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'services/file_repository.dart';
import 'services/service_locator.dart';

class PageManager {
  final _audioHandler = getIt<AudioHandler>();
  final _fileHandler = getIt<FileHandler>();

  // Events: Calls coming from the UI
  void init() async {
    await _fileHandler.moveToFolder();
    //_fileCache._listenToChangesInCurrentFolder(currentFolder);
    _fileHandler.listenToChangesInPlaylist();
    _fileHandler.listenToPlaybackState();
    _fileHandler.listenToCurrentPosition();
    _fileHandler.listenToBufferedPosition();
    _fileHandler.listenToTotalDuration();
    _fileHandler.listenToChangesInSong();
  }

  ValueNotifier<bool> get isFirstSongNotifier => _fileHandler.isFirstSongNotifier;
  ValueNotifier<PlaylistState> get playlistNotifier => _fileHandler.playlistNotifier;
  ValueNotifier<String> get currentSongTitleNotifier => _fileHandler.currentSongTitleNotifier;
  ProgressNotifier get progressNotifier => _fileHandler.progressNotifier;
  RepeatButtonNotifier get repeatButtonNotifier => _fileHandler.repeatButtonNotifier;
  PlayButtonNotifier get playButtonNotifier => _fileHandler.playButtonNotifier;
  ValueNotifier<bool> get isLastSongNotifier => _fileHandler.isLastSongNotifier;
  ValueNotifier<bool> get isShuffleModeEnabledNotifier  => _fileHandler.isShuffleModeEnabledNotifier;

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previousAudio() => _fileHandler.previousAudio();

  Future nextAudio() async => _fileHandler.nextAudio();

  void repeat() => _fileHandler.repeat();

  void shuffle() =>_fileHandler.shuffle();

  void dispose() {
    //_audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }


  void loadParentFolderContent() async => _fileHandler.loadParentFolderContent();

  fileTaped({required String name}) async => _fileHandler.fileTaped(name: name);

  changeRecursive(bool? newValue) async => _fileHandler.changeRecursive(newValue);

  bool isAudioIsPlayingByTitle(String title) => _fileHandler.isAudioIsPlayingByTitle(title);

  void loadCurrentFolderNextPage() => _fileHandler.loadCurrentFolderNextPage();
}