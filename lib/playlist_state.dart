class PlaylistState{

  PlaylistState({List<String>? playlist,
                  String? playingAudio,
                  String? currentFolder}){
    this.playlist = playlist ?? [];
    this.playingAudio = playingAudio ?? "";
    this.currentFolder = currentFolder ?? "";
  }

  List<String> playlist = [];
  String playingAudio = "";
  String currentFolder = "";

  PlaylistState cloneWithNewPlayList(List<String> playList) =>
      PlaylistState(
        playlist: playList,
        playingAudio: this.playingAudio,
        currentFolder: this.currentFolder
      );

  PlaylistState cloneWithNewPlayingAudio(String playingAudio) =>
      PlaylistState(
          playlist: this.playlist,
          playingAudio: playingAudio,
          currentFolder: this.currentFolder
      );

  PlaylistState cloneWithNewCurrentFolder(String currentFolder) =>
      PlaylistState(
          playlist: this.playlist,
          playingAudio: this.playingAudio,
          currentFolder: currentFolder
      );
}