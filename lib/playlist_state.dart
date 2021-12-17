class PlaylistState{

  PlaylistState({List<String>? playlist,
                  String? playingAudio,
                  String? currentFolder,
                  bool? recursive
  }){
    this.playlist = playlist ?? [];
    this.playingAudio = playingAudio ?? "";
    this.currentFolder = currentFolder ?? "";
    this.recursive = recursive ?? false;
  }

  List<String> playlist = [];
  String playingAudio = "";
  String currentFolder = "";
  bool recursive = false;

  PlaylistState cloneWithNewPlayList(List<String> playList) =>
      PlaylistState(
        playlist: playList,
        playingAudio: this.playingAudio,
        currentFolder: this.currentFolder,
        recursive: this.recursive
      );

  PlaylistState cloneWithNewPlayingAudio(String playingAudio) =>
      PlaylistState(
          playlist: this.playlist,
          playingAudio: playingAudio,
          currentFolder: this.currentFolder,
          recursive: this.recursive
      );

  PlaylistState cloneWithNewCurrentFolder(String currentFolder) =>
      PlaylistState(
          playlist: this.playlist,
          playingAudio: this.playingAudio,
          currentFolder: currentFolder,
          recursive: this.recursive
      );

  PlaylistState cloneWithNewRecursive(bool recursive) =>
      PlaylistState(
          playlist: this.playlist,
          playingAudio: this.playingAudio,
          currentFolder: currentFolder,
          recursive: recursive
      );
}