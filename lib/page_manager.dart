import 'package:flutter/foundation.dart';
import 'package:yadplayer/ya_d_player_service_api/models/file.dart';
import 'package:audio_service/audio_service.dart';
import 'package:yadplayer/playlist_state.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'services/file_repository.dart';
import 'services/service_locator.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<PlaylistState>(PlaylistState());
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final _audioHandler = getIt<AudioHandler>();
  final files = List<File>.empty(growable: true);
  final folderStack = List<String>.empty(growable: true);
  String currentFolder = rootPath;
  String? playingFolder;
  final foldersLastPages = Map<String, int>();
  final loadNextPageTasks = List<String>.empty(growable: true);

  final fileRepository = getIt<FileRepository>();

  static const rootPath = "disk:";

  bool get recursive => playlistNotifier.value.recursive;
  bool Function(File, String) get folderFilter => recursive ?
        (File f, String path) => f.parentFolderPath.startsWith(path)
        : (File f, String path) => f.parentFolderPath == path;

  // Events: Calls coming from the UI
  void init() async {
    await moveToFolder(path:currentFolder);
    _listenToChangesInCurrentFolder(currentFolder);
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> _getFiles({String path = "", int page = 1, bool recursive = false}) async {
    final playlist = await fileRepository.getFiles(path: path, page: page, recursive: recursive);

    files.addAll(playlist);

    var newValue = files
        .where((e) => folderFilter(e, path))
        .map((e) => e.name.toString())
        .toList();

    var oldPlaylistState = playlistNotifier.value;
    playlistNotifier.value = oldPlaylistState.cloneWithNewPlayList(newValue);
  }

  void _listenToChangesInCurrentFolder(String newValue){
    currentFolder = newValue;
    playlistNotifier.value = playlistNotifier.value.cloneWithNewCurrentFolder(currentFolder);
  }
  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      _updateSkipButtons();

      if(playlist.isEmpty == false) {
        play();
        final oldPlaylistState = playlistNotifier.value;
        final playingTrackFullname = playingFolder.toString() + "/" + playlist.first.title;
        playlistNotifier.value = oldPlaylistState.cloneWithNewPlayingAudio(playingTrackFullname);
      }
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.pause();
      }
    });
  }

  bool loadNext = false;

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) async {
      final oldState = progressNotifier.value;
      final total = oldState.total;

      if(position >= total && total != Duration.zero && !loadNext){
        loadNext = true;
        await next();
        loadNext = false;
      }

      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );


    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final playingAudio = files
        .where((f) => _audioHandler.mediaItem.value?.title == f.name
                  && f.parentFolderPath == playingFolder);
    final playlist = files.where((f) => f.parentFolderPath == playingFolder);
    if (playlist.length < 2 || playingAudio.isEmpty) {
      isFirstSongNotifier.value = true;
      //isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == playingAudio.first;
      isLastSongNotifier.value = false;
    }
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() {
    if(playingFolder == null)
      return;
    var folder = files
        .where((f) => f.parentFolderPath == playingFolder)
        .toList();

    if(folder.isEmpty)
      return;

    var index = folder.indexWhere((f) => f.name == _audioHandler.mediaItem.value?.title);

    if(index < 1)
      return;

    var previousAudio = folder[--index];

    playAudio(previousAudio);
  }

  Future next() async {
    if(playingFolder == null)
      return;

    File? nextAudio;

    if(this.isShuffleModeEnabledNotifier.value == false)
    {
      nextAudio = await nextByLinearOrder();
    }
    else{
      nextAudio = await nextByRandomOrder();
    }

    if(nextAudio == null)
      return null;

    playAudio(nextAudio);
  }

  Future<File?> nextByLinearOrder() async  {
    var folder = files
        .where((f) => f.parentFolderPath == playingFolder)
        .toList();

    if(folder.isEmpty)
      return null;

    var index = folder.indexWhere((f) => f.name == _audioHandler.mediaItem.value?.title);

    if(index == -1)
      return null;

    if(index == (folder.length - 1)) {
      await loadPlayingFolderNextPage();
      folder = files
          .where((f) => f.parentFolderPath == playingFolder)
          .toList();
    }

    if(index == (folder.length - 1))
      return null;

    var nextAudio = folder[++index];

    return nextAudio;
  }

  Future<File?> nextByRandomOrder() async  {
    if(playingFolder == null)
      return null;

    var nextAudio = await fileRepository.getRandomFile(playingFolder ?? "", "", false);

    return nextAudio;
  }

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }

  getFolderContent({String path = "", bool isForward = true, int page = 1}) async {
    if(isForward == false || page == 1) {
      var newFiles = files
                  .where((f) => folderFilter(f, path))
                  .map((f) => f.name)
                  .toList();

      if(page == 1 && newFiles.length > 0 || isForward == false) {
          var oldPlaylistState = playlistNotifier.value;
          playlistNotifier.value = oldPlaylistState.cloneWithNewPlayList(newFiles);
          return;
      }
    }

    await _getFiles(path: path, page: page, recursive: recursive);
  }

  void loadParentFolderContent() async {
    var iterable = files
        .where((f) => f.path == currentFolder);

    if(iterable.isEmpty)
      return;

    final parentFolder = iterable.first.parentFolderPath;

    await moveToFolder(path: parentFolder.toString(), isForward: false);
  }


  fileTaped({required String name}) async {
    var object = files
        .where((folder) => folder.name == name)
        .first;

    if(object.type == "folder"){
      await this.moveToFolder(path: object.path, isForward: true, page: 1);
    }
    else{
      await this.playAudio(object);
    }
  }

  moveToFolder({String path = "", bool isForward = true, int page = 1}) async {
    if(page == 1 || isForward == false) {
      if(isForward){
        folderStack.add(path);
      }
      else{
        folderStack.removeLast();
        path = folderStack.last;
      }
    }

    await this.getFolderContent(path: path, isForward: isForward, page: page);
    _listenToChangesInCurrentFolder(path);
  }

  void loadCurrentFolderNextPage() => loadNextPage(this.currentFolder);
  Future loadPlayingFolderNextPage() => loadNextPage(this.playingFolder ?? "");

  Future loadNextPage(String folder) async {

    if(loadNextPageTasks.contains(folder))
      return;

    loadNextPageTasks.add(folder);

    var currentPage = foldersLastPages[folder] ?? 0;

    var nextPage = ++currentPage;

    await getFolderContent(path: folder, page: nextPage);

    foldersLastPages[folder] = nextPage;

    loadNextPageTasks.remove(folder);
  }

  playAudio(File object) async {
    final songRepository = getIt<FileRepository>();
    final audioUrl = await songRepository.getAudioUrl(object);

    playingFolder = object.parentFolderPath;

    if(currentSongTitleNotifier.value != "")
      _audioHandler.removeQueueItemAt(0);
    _audioHandler.addQueueItem(MediaItem(
      id: object.path,
      title: object.name,
      extras: { "url": audioUrl }
    ));
  }

  changeRecursive(bool? newValue) async {
    if(newValue == null ||
        recursive == newValue ||
        loadNextPageTasks.length > 0 ||
        loadNext == true)
      return;
    playlistNotifier.value = playlistNotifier.value.cloneWithNewRecursive(newValue);

    files.clear();
    foldersLastPages.clear();

    loadCurrentFolderNextPage();
  }

  bool isAudioIsPlayingByTitle(String title) {
    final playingAudio = playlistNotifier.value.playingAudio;
    if(recursive == false)
      return playingAudio != "" && currentFolder + "/" + title == playingAudio;
    else
      return playingAudio != "" && playingAudio.startsWith(currentFolder) && playingAudio.endsWith(title);
  }
}