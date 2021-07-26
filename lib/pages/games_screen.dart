import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentifit/games/jigsaw/jigsawHome.dart';
import 'package:mentifit/games/trivia/triviaHome_screen.dart';
import 'package:mentifit/games/wordsearch/wordsearchHome.dart';
import 'package:mentifit/pages/challenges_screen.dart';
import 'package:mentifit/pages/check_screens/check_home.dart';
import 'package:mentifit/pages/profile_screen.dart';
import 'dart:math';
import 'package:mentifit/pages/signin_screen.dart';

class GamesScreen extends StatefulWidget {
  @override
  _GamesScreenState createState() => _GamesScreenState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _GamesScreenState extends State<GamesScreen> {
  final random = new Random();
  var gameType = ["trivia", "jigsaw", "wordsearch"];
  var challengeString = [];
  var gameChallenge = [];
  List<bool> completed = List<bool>();
  bool upToDate = true;
  List<DocumentSnapshot> listDocs = new List<DocumentSnapshot>();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Games',
      style: optionStyle,
    ),
    Text(
      'Index 1: Challenges',
      style: optionStyle,
    ),
    Text(
      'Index 2: Statistics',
      style: optionStyle,
    ),
    Text(
      'Index 3: Profile',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            ChallengesScreen(
            )));
      }
      if (index == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CheckHome()));
      }
      if (index == 3) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfileScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var kGreyBackground = Colors.grey[500];
    var listViewPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
    var size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Games", style: Theme
            .of(context)
            .textTheme
            .headline5),
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            label: 'Games',
            backgroundColor: Color(0xff0080ff),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Challenges',
            backgroundColor: Color(0xff0080ff),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Stats',
            backgroundColor: Color(0xff0080ff),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
            backgroundColor: Color(0xff0080ff),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      padding: listViewPadding,
                      children: [
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () =>
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => TriviaHome()),
                              ),
                          child: Container(
                            height: size.height * 0.2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kGreyBackground,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.quiz,
                                  color: Colors.white,
                                  size: size.height * 0.1,
                                ),
                                SizedBox(width: 15),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "TRIVIA",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ), SizedBox(height: 16),
                        InkWell(
                          onTap: () =>
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => JigsawHome()),
                              ),
                          child: Container(
                            height: size.height * 0.2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kGreyBackground,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_rounded,
                                  color: Colors.white,
                                  size: size.height * 0.1,
                                ),
                                SizedBox(width: 15),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "JIGSAW",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ), SizedBox(height: 16),
                        InkWell(
                          onTap: () =>
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => WordsearchHome()),
                              ),
                          child: Container(
                            height: size.height * 0.2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kGreyBackground,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_on,
                                  color: Colors.white,
                                  size: size.height * 0.1,
                                ),
                                SizedBox(width: 15),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "WORD SEARCH",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
