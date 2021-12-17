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
            final currentFolder = playlistState.currentFolder;
            final recursive = playlistState.recursive;

            return Column(
              children: [
                Container(
                    child:Row(
                        children:[
                          Expanded(
                              child: ElevatedButton(
                                        onPressed: pageManager.loadParentFolderContent,
                                        child: Text("../" + currentFolder)
                                      )
                          ),
                          Expanded(
                              flex: 0,
                              child:
                                Checkbox(
                                    value: recursive,
                                    onChanged: pageManager.changeRecursive
                                )),
                          Expanded(
                              flex: 0,
                              child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text("recursive"))
                          )
                        ]
                    )
                  )
                ,
                Expanded(
                  child: ListView.builder(
                        itemCount: playlist.length,
                        controller: _controller,
                        itemBuilder: (context, index) {
                          return ListTile(
                              title: Text('${playlist[index]}'),
                              onTap: () => pageManager.fileTaped(name: playlist[index]),
                              tileColor: pageManager.isAudioIsPlayingByTitle(playlist[index])
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