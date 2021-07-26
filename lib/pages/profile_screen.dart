import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentifit/pages/about.dart';
import 'package:mentifit/pages/signUp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appTour.dart';
import 'challenges_screen.dart';
import 'check_screens/check_home.dart';
import 'games_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
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
      if (index == 0){
        Navigator.push(context, MaterialPageRoute(builder: (context) => GamesScreen()));
      }
      if (index == 1){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChallengesScreen(
        )));
      }
      if (index == 2){
        Navigator.push(context, MaterialPageRoute(builder: (context) => CheckHome()));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Profile",style: Theme.of(context).textTheme.headline5),
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
      body: CustomScrollView(
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
                    _buildSectionTitle(title: "GENERAL"),
                    _buildListTile(
                      titleText: "Account",
                      leadingIconData: Icons.account_circle_outlined,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                      },
                    ),
                    _buildListTile(
                      titleText: "Logout",
                      leadingIconData: Icons.logout,
                      includeTrailingIcon: false,
                      color: Colors.red,
                      onTap: () async {
                        //removing preferences
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        pref.remove('email');
                        //logging user out
                        await _auth.signOut().then((_){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()),);
                        });
                      }
                    ),
                    _buildSectionTitle(title: "HELP"),
                    _buildListTile(
                      titleText: "App Tour",
                      leadingIconData: Icons.account_circle_outlined,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AppTour(previous: "profile",)));
                      },
                    ),
                    _buildSectionTitle(title: "INFO"),
                    _buildListTile(
                      titleText: "About",
                      leadingIconData: Icons.help_outline,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen()));
                      },
                    ),
                    SizedBox(height: size.height*0.2),
                    Center(
                      child: Text(
                        "VERSION 1.0.0",
                        style: Theme.of(context).textTheme.overline,
                      ),
                    ),
                    SizedBox(height: 48),
                  ],
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
        Function onTap,
        Color color = Colors.black,
        bool includeTrailingIcon = true}) =>
      Column(
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
            onTap: onTap,
            trailing: includeTrailingIcon
                ? Icon(
              Icons.chevron_right,
              size: 28,
            )
                : null,
          ),
          Divider(),
        ],
      );
}