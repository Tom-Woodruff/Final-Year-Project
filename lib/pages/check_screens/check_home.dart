import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentifit/pages/check_screens/checkScreens.dart';
import 'dart:math';
import '../challenges_screen.dart';
import '../games_screen.dart';
import '../profile_screen.dart';

class CheckHome extends StatefulWidget {
  @override
  _CheckHomeState createState() => _CheckHomeState();
}

String name;

class _CheckHomeState extends State<CheckHome> {

  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0){
        Navigator.push(context, MaterialPageRoute(builder: (context) => GamesScreen()));
      }
      if (index == 1){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChallengesScreen()));
      }
      if (index == 3){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    var kGreyBackground = Colors.grey[500];
    var listViewPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Statistics",style: Theme.of(context).textTheme.headline5),
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CheckScreens(game: 'trivia')),
                              ),
                          child: Container(
                            height: size.height*0.2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kGreyBackground,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bar_chart,
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
                        ),SizedBox(height: 16),
                        InkWell(
                          onTap: () =>
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CheckScreens(game: 'jigsaw')),
                              ),
                          child: Container(
                            height: size.height*0.2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kGreyBackground,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bar_chart,
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
                        ),SizedBox(height: 16),
                        InkWell(
                          onTap: () =>
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CheckScreens(game: 'wordsearch')),
                              ),
                          child: Container(
                            height: size.height*0.2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kGreyBackground,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bar_chart,
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
