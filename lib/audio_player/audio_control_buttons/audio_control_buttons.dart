import 'package:flutter/cupertino.dart';
import 'package:yadplayer/audio_player/next_song_button/next_song_button.dart';
import 'package:yadplayer/audio_player/play_button/play_button.dart';
import 'package:yadplayer/audio_player/previous_song_button/previous_song_button.dart';
import 'package:yadplayer/audio_player/repeat_button/repeat_button.dart';
import 'package:yadplayer/audio_player/shuffle_button/shuffle_button.dart';

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RepeatButton(),
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}