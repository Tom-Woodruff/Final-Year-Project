import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mentifit/pages/games_screen.dart';
import 'package:mentifit/pages/signUp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  await Firebase.initializeApp();
  runApp(MaterialApp(
    //if there are no shared preferences then navigate to the sign in screen
    //otherwise go to the game screen
      home: email == null ? SignUpScreen() : GamesScreen()));
}



