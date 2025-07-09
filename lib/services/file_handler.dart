import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:yadplayer/services/logger.dart';
import 'package:yadplayer/services/service_locator.dart';

import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../notifiers/repeat_button_notifier.dart';
import '../playlist_state.dart';
import '../ya_d_player_service_api/models/file.dart';
import 'file_repository.dart';

class FileHandler {
  final _fileRepository = getIt<FileRepository>();
  final _audioHandler = getIt<AudioHandler>();
  final _logger = getIt<Logger>();

  static const rootPath = "disk:";
  final files = List<File>.empty(growable: true);
  final folderStack = List<String>.empty(growable: true);
  final foldersLastPages = Map<String, int>();
  final loadNextPageTasks = List<String>.empty(growable: true);

  String currentFolder = rootPath;
  String? playingFolder;
  bool loadNext = false;

  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<PlaylistState>(PlaylistState());
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  bool get recursive => playlistNotifier.value.recursive;
  bool Function(File, String) get folderFilter => recursive
      ? (File f, String path) => f.parentFolderPath.startsWith(path)
      : (File f, String path) => f.parentFolderPath == path;

  moveToFolder({String path = "", bool isForward = true, int page = 1}) async {
    if (path.isEmpty)
      path = rootPath;

    if (isForward && page == 1) {
      folderStack.add(path);
    }
    else if (isForward == false) {
      folderStack.removeLast();
      path = folderStack.last;
    }

    await this.getFolderContent(path: path, isForward: isForward, page: page);
    _listenToChangesInCurrentFolder(path);
  }

  void _listenToChangesInCurrentFolder(String newValue){
    currentFolder = newValue;
    playlistNotifier.value = playlistNotifier.value.cloneWithNewCurrentFolder(currentFolder);
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

  Future<void> _getFiles({String path = "", int page = 1, bool recursive = false}) async {
    final playlist = await _fileRepository.getFiles(path: path, page: page, recursive: recursive);

    files.addAll(playlist);

    var newValue = files
        .where((e) => folderFilter(e, path))
        .map((e) => e.name.toString())
        .toList();

    var oldPlaylistState = playlistNotifier.value;
    playlistNotifier.value = oldPlaylistState.cloneWithNewPlayList(newValue);
  }

  void listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) async {
      _updateSkipButtons();

      if(playlist.isEmpty == false) {
        await _audioHandler.play();
        final oldPlaylistState = playlistNotifier.value;
        if (playlist.isNotEmpty) {
          final playingTrackFullname = playingFolder.toString() + "/" + playlist.first.title;
          playlistNotifier.value = oldPlaylistState.cloneWithNewPlayingAudio(playingTrackFullname);
        }
      }
    });
  }

  void _updateSkipButtons() {
    final playingAudio = files
        .where((f) => _audioHandler.mediaItem.value?.title == f.name
        && folderFilter(f, playingFolder ?? ""));
    final playlist = files.where((f) => folderFilter(f, playingFolder ?? ""));
    if (playlist.length < 2 || playingAudio.isEmpty) {
      isFirstSongNotifier.value = true;
      //isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == playingAudio.first;
      isLastSongNotifier.value = false;
    }
  }

  void listenToPlaybackState() {
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

  void listenToCurrentPosition() {
    AudioService.position.listen((position) async {
      final oldState = progressNotifier.value;
      final total = oldState.total;
      
      //_logger.log("listening to current position");

      if(position >= total && total != Duration.zero && !loadNext) {
        loadNext = true;
        _logger.log("calling nextAudio position = $position total = $total loadNext = $loadNext");
        try {
          await nextAudio(); 
        }
        catch (e) {
          _logger.log("file_handler.listenToCurrentPosition: caught exception while trying to get next audio " + e.toString());
        }
        loadNext = false;
      }
      else {
        //_logger.log("nextAudio was not called position = $position total = $total loadNext = $loadNext");
      }

      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  Future nextAudio() async {
    if(playingFolder == null) {
      _logger.log("fileHandler.nextAudio: playingFolder is null, returning");
      return;
    }

    File? nextAudio;

    if(this.isShuffleModeEnabledNotifier.value == false)
    {
      _logger.log("fileHandler.nextAudio: calling nextByLinearOrder");
      nextAudio = await nextByLinearOrder();
    }
    else {
      _logger.log("fileHandler.nextAudio: calling nextByRandomOrder");
      nextAudio = await nextByRandomOrder();
    }

    if(nextAudio == null)
      return null;

    _logger.log("fileHandler.nextAudio: calling playAudio");

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

  Future<File?> nextByRandomOrder() async {
    if(playingFolder == null) {
      _logger.log("fileHandler.nextByRandomOrder: playingFolder is null, returning");
      return null;
    }

    _logger.log("fileHandler.nextByRandomOrder: calling _fileRepository.getRandomFile, playingFolder = $playingFolder recursive = $recursive");
    var nextAudio = await _fileRepository.getRandomFile(playingFolder ?? "", "", recursive);
    _logger.log("fileHandler.nextByRandomOrder: got result from _fileRepository.getRandomFile, nextaudio is null: ${nextAudio == null} name = ${nextAudio.name}");
    return nextAudio;
  }

  void loadCurrentFolderNextPage() => loadNextPage(this.currentFolder);
  Future loadPlayingFolderNextPage() => loadNextPage(this.playingFolder ?? "");

  Future loadNextPage(String folder) async {

    if(loadNextPageTasks.contains(folder))
      return;

    loadNextPageTasks.add(folder);

    var currentPage = foldersLastPages[folder] ?? 1;

    var nextPage = ++currentPage;

    await getFolderContent(path: folder, page: nextPage);

    foldersLastPages[folder] = nextPage;

    loadNextPageTasks.remove(folder);
  }

  playAudio(File object) async {
    final songRepository = getIt<FileRepository>();
    final audioUrl = await songRepository.getAudioUrl(object);

    playingFolder = folderStack.last;

    var audioQueueIsNotEmpty = _audioHandler.queue.value.isNotEmpty;
    //if(currentSongTitleNotifier.value != "")
      if(audioQueueIsNotEmpty) {
        await _audioHandler.removeQueueItemAt(0);
      }
      _audioHandler.addQueueItem(MediaItem(
          id: object.path,
          title: object.name,
          extras: { "url": audioUrl }
      ));

  }

  void listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      _updateSkipButtons();
    });
  }

  Future<void> previousAudio() async {
    //_audioHandler.skipToPrevious();
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

  changeRecursive(bool? newValue) async {
    if(newValue == null ||
        recursive == newValue ||
        loadNextPageTasks.length > 0 ||
        loadNext == true)
      return;
    playlistNotifier.value = playlistNotifier.value.cloneWithNewRecursive(newValue);

    files.clear();
    foldersLastPages.clear();

    getFolderContent(path: currentFolder);
  }

  bool isAudioIsPlayingByTitle(String title) {
    final playingAudio = playlistNotifier.value.playingAudio;
    if(recursive == false)
      return playingAudio != "" && currentFolder + "/" + title == playingAudio;
    else
      return playingAudio != "" && playingAudio.startsWith(currentFolder) && playingAudio.endsWith(title);
  }
}