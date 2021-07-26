import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentifit/app_database.dart';
import 'package:mentifit/pages/profile_screen.dart';
import 'appTour.dart';
import 'check_screens/check_home.dart';
import 'games_screen.dart';

class ChallengesScreen extends StatefulWidget {
  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _ChallengesScreenState extends State<ChallengesScreen> {
  final random = new Random();
  //Trivia removed due to API error
  var gameType = ["jigsaw", "wordsearch"];
  var challengeString = [];
  var gameChallenge = [];
  var gameDiff = "";
  List<bool> completed = List<bool>();
  List<DocumentSnapshot> listDocs = new List<DocumentSnapshot>();
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0){
        Navigator.push(context, MaterialPageRoute(builder: (context) => GamesScreen()));
      }
      if (index == 1){
      }
      if (index == 2){
        Navigator.push(context, MaterialPageRoute(builder: (context) => CheckHome()));
      }
      if (index == 3){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
          return
            Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: Text("Challenges",style: Theme.of(context).textTheme.headline5),
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
              body:
              CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kHorizontalPadding,
                          ),
                          child: FutureBuilder(
                              future: checkUpToDate(),
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState != ConnectionState.done) {
                                  return Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                      ]
                                );
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: [
                                    _buildSectionTitle(title: "CHALLENGES WE CHECK FOR YOU:"),
                                    _buildListTile(
                                      titleText: challengeString[0],
                                      leadingIconData: Icons
                                          .account_circle_outlined,
                                    ),
                                    SizedBox(height: size.height*0.1,),
                                    _buildSectionTitle(title: "CHALLENGES YOU CHECK:"),
                                    _buildUserListTile(
                                      titleText: challengeString[1],
                                      cNum: 1,
                                      type: "dComplete",
                                      leadingIconData: Icons
                                          .account_circle_outlined,
                                    ),
                                    _buildUserListTile(
                                      titleText: challengeString[2],
                                      cNum: 2,
                                      type: "eComplete",
                                      leadingIconData: Icons.help_outline,
                                    ),
                                    SizedBox(height: size.height * 0.2),
                                  ],
                                );
                              }
                          ),
                      )
                    ]),
                  ),
                ],
              ),
            );

  }

  Widget _buildSectionTitle({@required String title}) {
    return Column(
      children: [
        SizedBox(height: 32),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            letterSpacing: .5,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListTile(
      {String titleText,
        IconData leadingIconData,
        Color color = Colors.black,}) =>
      Column(
        children: [
          CheckboxListTile(
            value: completed[0],
            contentPadding: EdgeInsets.zero,
            title: Text(
              titleText,
              style: TextStyle(
                color: color,
                fontSize: 18,
              ),
            ),
            onChanged: (bool boo){
            },
          ),
          Divider(),
        ],
      );

  Widget _buildUserListTile(
      {String titleText, int cNum, String type,
        IconData leadingIconData,
        Color color = Colors.black,}) =>
      Column(
        children: [
          CheckboxListTile(
            value: completed[cNum],
            contentPadding: EdgeInsets.zero,
            title: Text(
              titleText,
              style: TextStyle(
                color: color,
                fontSize: 18,
              ),
            ),
            onChanged: (bool boo){
              checked(type);
              setState(() {
                completed[cNum] = true;
              });
          },
          ),
          Divider(),
        ],
      );


  checkUpToDate() async {
    DocumentSnapshot docs = await FirebaseFirestore.instance.collection('user').doc(_auth.currentUser.uid).collection('challenges').doc('set').get();
    //difference between today and the day the challenges we last set (in days)
    var difference = (docs.get('timeSet')).toDate().difference(DateTime.now());
    print("DIFFERENCE: "+difference.inDays.toString());
    //if it has been longer than a day
    if (difference.inDays <= -1){
      //set new challenges
      gameDiff+=gameType[random.nextInt(gameType.length)];
      AppDatabase().newChallenges('games', gameDiff);
      AppDatabase().newChallenges('diet', "mediterranean");
      AppDatabase().newChallenges('exercise', "moving");
      completed.add(false);
      completed.add(false);
      completed.add(false);
    }
    else{
      //retrieving challenge data and adding it to variables
      challengeString.add(docs.get('games'));
      challengeString.add(docs.get('diet'));
      challengeString.add(docs.get('exercise'));
      completed.add(docs.get("gComplete"));
      completed.add(docs.get("dComplete"));
      completed.add(docs.get("eComplete"));
    }
  }

  checked(String type) async{
    //setting specific challenge to true
    await FirebaseFirestore.instance.collection('user').doc(_auth.currentUser.uid).collection('challenges').doc('set').update({
      type: true,
    });
  }
}





