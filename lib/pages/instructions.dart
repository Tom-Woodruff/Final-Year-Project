import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class InstructionsScreen extends StatefulWidget {
  final String game;
  InstructionsScreen({Key key, @required this.game}) : super(key: key);
  @override
  _InstructionsScreenState createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller =
        VideoPlayerController.asset("assets/videos/" + widget.game + ".mov");
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    print(size.width);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.transparent,
        title: Text("Instructions", style: Theme
            .of(context)
            .textTheme
            .headline5),
        elevation: 0,
      ),
      body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: size.height*0.5,
                        child:
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      SizedBox(height: size.height*0.025,),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        child:
                        Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                      SizedBox(height: size.height*0.05,),
                      Container(
                        padding: EdgeInsets.only(bottom: size.height*0.05, left: size.height*0.05, right: size.height*0.05),
                        child: Text(text(), style: style,textAlign: TextAlign.center,),
                      ),

                    ],
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
      ),
    );
  }

  String text() {
    //setting text for each instruction
    if (widget.game == "jigsaw"){
      return "Drag and drop pieces into the board until the puzzle is "
          "complete. Press the play arrow to watch the video";
    }
    if (widget.game == "trivia"){
      return "Select the answer you think is correct, keep going until you have the correct "
          "answer but remember every wrong answer adds a second. Press the play arrow to watch the video";
    }
    if (widget.game == "wordsearch"){
      return "Select and drag to highlight words. Continue until all words "
          "are found. Press the play arrow to watch the video";
    }
  }
}


