import 'dart:async';

import 'package:audiobook/models/note.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoExample extends StatefulWidget {
  @override
  _VideoExampleState createState() => _VideoExampleState();
}

class _VideoExampleState extends State<VideoExample> {
  VideoPlayerController videoPlayerController;
  VoidCallback listener;

  Duration position;

  bool isBuffering;

  Size size;

  int bufferedLength;

  GlobalKey<State<Scaffold>> _scaffoldKey = GlobalKey();

  List<Note> notes = [];
  StreamController streamController = StreamController<String>();

  @override
  void dispose() {
    streamController.close();
  }

  @override
  void initState() {
    super.initState();
    listener = () {
      print('_VideoExampleState.initState.listener');
      if (videoPlayerController != null) {
        isBuffering = videoPlayerController.value.isBuffering;
        if (isBuffering) {
          if (!videoPlayerController.value.isPlaying) {
            videoPlayerController.play();
          }
        }
        bufferedLength = videoPlayerController.value.buffered.length;
      }
      setState(() {});
    };
  }

  void createVideo() {
    if (videoPlayerController == null) {
//      videoPlayerController = VideoPlayerController.asset("assets/intro.mp4")
      videoPlayerController = VideoPlayerController.network(
          "https://r4---sn-un57en7l.googlevideo.com/videoplayback?requiressl=yes&lmt=1550259198993579&itag=22&fvip=4&ip=34.230.21.67&dur=20451.160&sparams=dur,ei,expire,id,ip,ipbits,ipbypass,itag,lmt,mime,mip,mm,mn,ms,mv,pl,ratebypass,requiressl,source&source=youtube&id=o-AGNzU9S82xXAlT9dQy2mo_k1wE9oCzRbgXHRqXVBNA8D&ratebypass=yes&expire=1551449699&txp=5432432&key=cms1&mime=video%2Fmp4&signature=6CFA79C34CC88E1353F9AE118710A645F9F0DB4B.539F0070D5ADB909480D4EF964AC2CB419E409D7&ei=A-p4XNfVL9W6hwb5nLO4DA&ipbits=0&pl=22&rm=sn-vgqe7d7z&req_id=e584c60acb25a3ee&ipbypass=yes&mip=211.75.184.211&redirect_counter=2&cm2rm=sn-ipoxu-un5s7s&cms_redirect=yes&mm=29&mn=sn-un57en7l&ms=rdu&mt=1551428014&mv=m")
        ..addListener(listener)
        ..setVolume(1.0)
        ..initialize();
    } else {
      if (videoPlayerController.value.isPlaying) {
        videoPlayerController.pause();
        setState(() {
          position = videoPlayerController.value.position;
        });
      } else {
        if (!videoPlayerController.value.initialized) {
          videoPlayerController.initialize();
        }
        videoPlayerController.play();
      }
    }
  }

  void seekTo(AxisDirection direction) {
    int currentPositionInSeconds =
        videoPlayerController.value.position.inSeconds;
    int videoDurationInSeconds =
        videoPlayerController.value.duration.inMilliseconds;
    int newPositionInSeconds = 0;

    if (direction == AxisDirection.left) {
      newPositionInSeconds = currentPositionInSeconds - 15;
      if (newPositionInSeconds < 0) {
        newPositionInSeconds = 0;
      }
    } else {
      newPositionInSeconds += 15;
      if (videoDurationInSeconds < newPositionInSeconds) {
        newPositionInSeconds = videoDurationInSeconds;
      }
    }

    videoPlayerController.seekTo(Duration(seconds: newPositionInSeconds));
  }

  @override
  void deactivate() {
    videoPlayerController.setVolume(0.0);
    videoPlayerController.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    widgets = notes.map<Widget>((Note note) {
      var title = note.title;
      if (title.length > 20) {
        title = title.substring(0, 20);
      }
      var position = note.getTime.split(".")[0];

      return Dismissible(
        key: Key(note.title),
        onDismissed: (DismissDirection direction) {
          setState(() {
            notes = notes.where((Note n) => n.title != note.title).toList();
          });
        },
        background: Text("Delete"),
        child: Card(
          child: Container(
            margin: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(position),
                Text(title),
                Spacer(),
                IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () {
                      videoPlayerController.seekTo(note.position);
                    }),
                IconButton(
                  icon: Icon(Icons.speaker_notes),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ),
      );
    }).toList();

    widgets.insert(
      0,
      AspectRatio(
        aspectRatio: 1280 / 720,
        child: Container(
            child: videoPlayerController != null
                ? VideoPlayer(videoPlayerController)
                : Container(child: Text("No video"))),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      body: ListView(
        children: widgets,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _addNote();
        },
        icon: Icon(Icons.textsms),
        label: Text("Add note to current time"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            title: Text("-10 secs"),
            icon: IconButton(
              icon: Icon(Icons.fast_rewind),
              onPressed: () => seekTo(AxisDirection.left),
            ),
          ),
          BottomNavigationBarItem(
            title: Text("Play/Pause"),
            icon: IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () => createVideo(),
            ),
          ),
          BottomNavigationBarItem(
            title: Text("+10 secs"),
            icon: IconButton(
              icon: Icon(Icons.fast_forward),
              onPressed: () => seekTo(AxisDirection.right),
            ),
          ),
        ],
        currentIndex: 1,
      ),
    );
  }

  void _addNote() {
    showDialog(
        context: _scaffoldKey.currentState.context,
        builder: (context) {
          TextEditingController textEditingController = TextEditingController();
          TextField textField = TextField(
            controller: textEditingController,
            onSubmitted: (String value) {
              Navigator.of(context).pop();

              setState(() {
                var note = Note();
                note.title = value;
                note.position = videoPlayerController.value.position;
                notes.add(note);
              });
            },
          );

          return Scaffold(
            body: ListView(
              children: <Widget>[
                textField,
              ],
            ),
          );
        });
  }
}
