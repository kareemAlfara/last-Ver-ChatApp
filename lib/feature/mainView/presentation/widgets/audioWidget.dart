import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final bool isSentByMe;

  const AudioMessageWidget({
    super.key,
    required this.audioUrl,
    required this.isSentByMe,
  });

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  @override
void initState() {
  super.initState();
  initializePlayer();
}

void initializePlayer() {
  _player.onDurationChanged.listen((d) {
    setState(() => _duration = d);
  });

  _player.onPositionChanged.listen((p) {
    setState(() => _position = p);
  });

  _player.onPlayerComplete.listen((event) {
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
  });
}

  // void initState() async{
  //   super.initState();

  //   _player.onDurationChanged.listen((d) {
  //     setState(() => _duration = d);
  //   });

  //   _player.onPositionChanged.listen((p) {
  //     setState(() => _position = p);
  //   });

  //   _player.onPlayerComplete.listen((event) {
  //     setState(() {
  //       _isPlaying = false;
  //       _position = Duration.zero;
  //     });
  //   });
  // }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return  '${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: Colors.green,
              size: 30,
            ),
            onPressed: () async {
              if (_isPlaying) {
                await _player.pause();
              } else {
                await _player.play(UrlSource(widget.audioUrl));
              }
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                Slider(
                  min: 0,
                  max: _duration.inSeconds.toDouble(),
                  value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
                  onChanged: (value) async {
                    final newPos = Duration(seconds: value.toInt());
                    await _player.seek(newPos);
                  },
                  activeColor: Colors.green,
                  inactiveColor: widget.isSentByMe ? Colors.grey : Colors.white,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDuration(_position)),
                    Text(formatDuration(_duration)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
