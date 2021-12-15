import 'package:flutter/cupertino.dart';
import 'package:yadplayer/services/service_locator.dart';

import '../page_manager.dart';
import 'audio_control_buttons/audio_control_buttons.dart';
import 'audio_progress_bar/audio_progress_bar.dart';

class AudioPlayer extends StatelessWidget {
  const AudioPlayer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var pageManager = getIt<PageManager>();

    return ValueListenableBuilder<String?>(
        valueListenable: pageManager.currentSongTitleNotifier,
        builder: (context, title, _) =>
        Column(
          children: [
            Text(title ?? ""),
            AudioProgressBar(),
            AudioControlButtons(),
          ])
      );
    }
  }
