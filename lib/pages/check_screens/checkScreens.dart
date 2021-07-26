import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../appTour.dart';

double ePercentage = 0.0;
double mPercentage = 0.0;
double hPercentage = 0.0;

class CheckScreens extends StatefulWidget {
  String game;

  CheckScreens({Key key, @required this.game}) : super(key: key);

  @override
  _CheckScreenState createState() => _CheckScreenState();
}

var size;
var kGreyBackground = Colors.grey[500];
var listViewPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
List<DocumentSnapshot> listDocs = new List<DocumentSnapshot>();

class _CheckScreenState extends State<CheckScreens> with SingleTickerProviderStateMixin{
  final List<String> _listItem = [
    'easy',
    'medium',
    'hard',
  ];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _listItem.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.black, //change your color here
              ),
              leading: BackButton(),
              title: Text(
                  widget.game[0].toUpperCase() + widget.game.substring(1) +
                      " Stats", style: TextStyle(color: Colors.black),),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                tabs: [
                  Tab(text: 'Easy',),
                  Tab(text: 'Medium',),
                  Tab(text: 'Hard',),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: _listItem.map((String tab) {
                return diff(tab);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget diff(String diff) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(title: "Games"),
                  _buildListTile(
                    titleText: "Games Played",
                    leadingIconData: Icons.games,
                    diff: diff,
                  ),
                  _buildSectionTitle(title: "Time"),
                  _buildListTile(
                    titleText: "Best Time",
                    leadingIconData: Icons.access_alarms,
                    diff: diff,
                  ),
                  _buildListTile(
                    titleText: "Average Time",
                    leadingIconData: Icons.access_alarms,
                    diff: diff,
                  ),
                  SizedBox(height: size.height * 0.25),
                ],
              ),
            )
          ]),
        ),
      ],
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

  Widget _buildListTile({String titleText,
    IconData leadingIconData,
    String diff,
    Color color = Colors.black,}) =>
      FutureBuilder(
        future: setListDoc(),
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
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  leadingIconData,
                  color: color,
                  size: 28,
                ),
                title: Text(
                  titleText,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                  ),
                ),
                trailing: Text(getStats(titleText, diff).toStringAsFixed(2)),
              ),
              Divider(),
            ],
          );
        }
      );

  double getStats(String titleText, String diff)  {
    if (titleText == "Average Time") {
      List<int> times = List<int>();
      double average = 0;
      for (int i = 0; i < listDocs.length; i++) {
        if (listDocs[i].get('difficulty') == diff) {
          times.add(listDocs[i].get('time'));
        }
      }
      for (int i = 0; i < times.length; i++) {
        average += times[i];
      }
      if(!((average / times.length).isNaN)) {
        print((average / times.length).toString());
        return (average / times.length) / 1000;
      }
      else {
        return 0.0;
      }
    }
    if (titleText == "Best Time") {
      List<int> times = List<int>();
      double best = double.infinity;
      for (int i = 0; i < listDocs.length; i++) {
        if (listDocs[i].get('difficulty') == diff) {
          times.add(listDocs[i].get('time'));
        }
      }
      for (int i = 0; i < times.length; i++) {
        if (times[i] < best) {
          best = times[i].toDouble();
        }
      }
      if (best != double.infinity) {
        return best / 1000;
      }
      else{
        return 0.0;
      }
    }
    if (titleText == "Games Played") {
      double played = 0;
      for (int i = 0; i < listDocs.length; i++) {
        if (listDocs[i].get('difficulty') == diff) {
          played++;
        }
      }
      return played;
    }
  }

  setListDoc() async {
    String userID = FirebaseAuth.instance.currentUser.uid;
    QuerySnapshot docs = await FirebaseFirestore.instance.collection('user')
        .doc(
        userID).collection(widget.game)
        .get();
    listDocs = docs.docs;
  }
}
