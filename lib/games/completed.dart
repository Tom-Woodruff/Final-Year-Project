import 'package:flutter/material.dart';
import 'package:mentifit/pages/appTour.dart';
import 'package:mentifit/pages/games_screen.dart';

class CompletedScreen extends StatefulWidget {
  final int time;
  final String name;
  final String diff;
  CompletedScreen({Key key, @required this.time, @required this.name, @required this.diff}) : super(key: key);
  @override
  _CompletedScreenState createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  var listViewPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double dTime = widget.time/1000;
    final home = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery
            .of(context)
            .size
            .width,
        height: size.height*0.08,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => GamesScreen()),);
        },
        child: Text("Exit",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Games",style: Theme.of(context).textTheme.headline5),
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: size.height*0.1,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("images/trophy.png", height: size.width*0.1),
                      SizedBox(width: size.width*0.1,),
                      Text("Well Done "+widget.name[0].toUpperCase()+widget.name.substring(1)+"!!!",style: style,),
                      SizedBox(width: size.width*0.1,),
                      Image.asset("images/trophy.png", height: size.width*0.1),
                    ],
                  ),
                  SizedBox(height: size.height*0.1,),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kHorizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.games,
                            color: Colors.black,
                            size: 28,
                          ),
                          title: Text(
                            "Difficulty",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          trailing: Text(widget.diff[0].toUpperCase() + widget.diff.substring(1)),
                        ),
                        Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.access_alarms,
                            color: Colors.black,
                            size: 28,
                          ),
                          title: Text(
                            "Time",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          trailing: Text(dTime.toStringAsFixed(2)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60.0),
                  home,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}