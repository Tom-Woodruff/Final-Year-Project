import 'package:flutter/material.dart';
import 'package:mentifit/pages/games_screen.dart';
import 'package:mentifit/pages/profile_screen.dart';
import 'package:video_player/video_player.dart';

const double kHorizontalPadding = 32;
const double kVerticalPadding = 32;
VideoPlayerController _controller;
Future<void> _initializeVideoPlayerFuture;

class AppTour extends StatefulWidget {
  AppTour({this.onFinish, this.end, @required this.previous});
  final Function onFinish;
  final Function end;
  final String previous;

  @override
  _AppTourState createState() => _AppTourState();
}

class _AppTourState extends State<AppTour> {
  @override
  void initState() {
    screenIndex = 0;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color myDarkColor = Colors.grey[800];
  Color accentColor = Colors.deepPurple;

  PageController pageController = PageController();
  int screenIndex;

  List<Widget> screens = [
    //setting text for each screen
    _SingleScreen(
      title: "Walk-through",
      subtitle:
      "On the following pages there will be a series of looping, non-interactive videos "
          "accompanied with text to show you how to use the app. Press next to start and end in"
          " the top right when you feel confident to use the app",
      video: "null",
    ),
    _SingleScreen(
      title: "Play Games",
      subtitle:
      "This will be the first screen you arrive on in the app. First you must select a game. "
          "Then you will be taken to a second screen where you select a difficulty to start "
          "the game. There are 3 games: Trivia, Jigsaw and Word Search",
      video: "games.mov",
    ),
    _SingleScreen(
      title: "Complete Daily Challenges",
      subtitle:
      "Navigate to the Challenges page with the bar at the bottom. Then you will be displayed "
          "with the challenges you have for that day. The first challenge will need to be completed "
          "within the application and will be checked by the app. The second two are to be completed "
          "throughout your day and will need to be checked off by you",
      video: "challenges.mov",
    ),
    _SingleScreen(
      title: "Check Progress",
      subtitle:
      "Navigate to the Statistics page with the bar at the bottom. Then you will need to select "
          "the game you want to view the stats for. Once you have selected this you can view "
          "your Number of Games, Best Time and Average Time for each difficulty.",
      video: "stats.mov",
    )
  ];

  void setScreenIndex(int value) {
    setState(() {
      screenIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);

    return Theme(
      data: currentTheme.copyWith(
        textTheme: currentTheme.textTheme
            .copyWith(bodyText2: TextStyle(color: myDarkColor)),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(primary: myDarkColor),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 32.0, vertical: kVerticalPadding),
            child: Stack(
              children: [
                PageViewWithIndicators(
                  dotColor: accentColor,
                  pageController: pageController,
                  onPageChanged: setScreenIndex,
                  children: screens,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    //depending on the previous screen, return to a different location
                    onPressed: (){
                      if (widget.previous == "profile"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                      }
                      if (widget.previous == "signUp"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GamesScreen()));
                      }
                    },
                    child: Text(
                      "End",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      screenIndex != 0
                          ? TextButton(
                        child:
                        Text("Prev", style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          pageController.previousPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease);
                        },
                      )
                          : SizedBox.shrink(),
                      TextButton(
                        onPressed: () {
                          if (screenIndex == screens.length - 1) {
                            widget.onFinish();
                          } else {
                            pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                          }
                        },
                        child: Text(
                          screenIndex == screens.length - 1 ? "" : "Next",
                          style: TextStyle(fontSize: 16, color: accentColor),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleScreen extends StatelessWidget {
  const _SingleScreen({this.title, this.subtitle, this.video});
  final String title;
  final String subtitle;
  final String video;

  @override
  Widget build(BuildContext context) {
    //if video is empty initialise the video
    if (this.video != "null"){
      _controller = VideoPlayerController.asset("assets/videos/" + video );
      _initializeVideoPlayerFuture = _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(0);

      Size size = MediaQuery.of(context).size;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    _controller.play();
                    return
                      Container(
                        height: size.height*0.5,
                        child:
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              SizedBox(height: size.height*0.05,),
              Text(
                title ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
              ),
              SizedBox(height: 12),
              Text(
                subtitle ?? "",
                textAlign: TextAlign.center,
              )
            ],
          ),
        ],
      );
    }
    else{
      Size size = MediaQuery.of(context).size;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height*0.4,),
              Text(
                title ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
              ),
              SizedBox(height: 12),
              Text(
                subtitle ?? "",
                textAlign: TextAlign.center,
              )
            ],
          ),
        ],
      );
    }
  }
}

class PageViewWithIndicators extends StatefulWidget {
  const PageViewWithIndicators({
    this.children,
    this.dotColor = Colors.white,
    this.pageController,
    this.onPageChanged,
  });
  final List<Widget> children;
  final Color dotColor;
  final Function(int) onPageChanged;
  final PageController pageController;

  @override
  _PageViewWithIndicatorsState createState() => _PageViewWithIndicatorsState();
}

class _PageViewWithIndicatorsState extends State<PageViewWithIndicators> {
  int activeIndex;

  @override
  void initState() {
    activeIndex = 0;
    super.initState();
  }

  setActiveIndex(int index) {
    setState(() {
      activeIndex = index;
    });
  }

  _buildDottedIndicators() {
    List<Widget> dots = [];
    const double radius = 8;

    for (int i = 0; i < widget.children.length; i++) {
      dots.add(
        Container(
          height: radius,
          width: radius,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == activeIndex
                ? widget.dotColor
                : widget.dotColor.withOpacity(.6),
          ),
        ),
      );
    }
    dots = intersperse(SizedBox(width: 6), dots)
        .toList(); // Add spacing between dots

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dots,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          children: widget.children,
          onPageChanged: (value) {
            setActiveIndex(value);
            widget.onPageChanged(value);
          },
          controller: widget.pageController,
        ),
        _buildDottedIndicators()

      ],
    );
  }
}
Iterable<T> intersperse<T>(T element, Iterable<T> iterable) sync* {
  final iterator = iterable.iterator;
  if (iterator.moveNext()) {
    yield iterator.current;
    while (iterator.moveNext()) {
      yield element;
      yield iterator.current;
    }
  }
}

