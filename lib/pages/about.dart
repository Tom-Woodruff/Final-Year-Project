import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentifit/games/trivia/triviaHome_screen.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          leading: BackButton(),
          title: Text("About", style: TextStyle(color: Colors.black),),
        ),
        body: Column(
            children: [
              Container(
                height: size.height-150,
                alignment: Alignment.center,
                padding: EdgeInsets.all(50),
                child: Text(
                "Our app aims to focus your cognitive thinking on to mentally challenging"
                    " games with the hope of improving your mental health. Alongside this"
                    " there is added physical and dietry challenges that you can complete"
                    " throughout the day to aid your brain and make potentially sky rocket"
                    " your progress.", style: style, textAlign: TextAlign.center
                ),
              ),
            ]
        ),
      );
  }

}