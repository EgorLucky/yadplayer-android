import 'package:flutter/material.dart';
import '../page_manager.dart';
import '../playlist_state.dart';
import '../services/service_locator.dart';


class FileBrowser extends StatefulWidget {
  FileBrowser({Key? key}) : super(key: key);

  
  @override
  FileBrowserState createState() => FileBrowserState();
}

class FileBrowserState extends State<FileBrowser> {
  FileBrowserState(): super();

  List<String> folderStack = List.empty();
  int explorerPage = 0;
  String? playingFolder;
  String? currentPath;
  List<dynamic> folders = List.empty();
  ScrollController _controller = new ScrollController();


  @override
  void initState() {
    _controller.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      final pageManager = getIt<PageManager>();
      pageManager.loadCurrentFolderNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
      final pageManager = getIt<PageManager>();

      return ValueListenableBuilder<PlaylistState>(
          valueListenable: pageManager.playlistNotifier,
          builder: (context, playlistState, _) {
            final playlist = playlistState.playlist;
            final playingAudio = playlistState.playingAudio;
            final currentFolder = playlistState.currentFolder;

            return Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 1,
                  child: ElevatedButton(
                        onPressed: pageManager.loadParentFolderContent,
                        child: Text("../" + currentFolder),
                        style: ButtonStyle(),
                    ),
                ),
                // ElevatedButton(
                //     onPressed: pageManager.loadParentFolderContent,
                //     child: Text("../" + currentFolder),
                //     style: ButtonStyle(),
                // )
                Expanded(
                  child: ListView.builder(
                        itemCount: playlist.length,
                        controller: _controller,
                        itemBuilder: (context, index) {
                          return ListTile(
                              title: Text('${playlist[index]}'),
                              onTap: () => pageManager.fileTaped(name: playlist[index]),
                              tileColor: playingAudio != "" && currentFolder + "/" + playlist[index] == playingAudio
                                  ? Color.fromARGB(127, 134, 134, 139) : null
                          );
                        },
                      )
                  ),
                ]
              );

      });
  }
}