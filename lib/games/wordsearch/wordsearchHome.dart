import 'package:flutter/material.dart';
import 'package:mentifit/games/wordsearch/wordsearchGame.dart';
import 'package:mentifit/pages/instructions.dart';
import 'package:mentifit/pages/profile_screen.dart';
import 'package:word_search/word_search.dart';

class WordsearchHome extends StatefulWidget {
  @override
  _WordsearchHomeState createState() => _WordsearchHomeState();
}

class _WordsearchHomeState extends State<WordsearchHome> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var kGreyBackground = Colors.grey[500];
    var listViewPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
    int diff = 0;
    List difficulty = [["easy", 6], ["medium", 8], ["hard", 10]];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        leading: BackButton(),
        title: Text("Wordsearch",style: Theme.of(context).textTheme.headline5),
        actions: [
          SizedBox(
            width: size.width*0.2, // <-- Your width
            child: TextButton(
              child: Text("Instructions", style: TextStyle(color: Colors.black), ),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => InstructionsScreen(game: "wordsearch")),);
              },
            ),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: size.height*0.05,),
                  Expanded(
                    child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: difficulty.length,
                      itemBuilder: (context, index) {
                        context = context;
                        return InkWell(
                          onTap: () => {
                            for (int i = 0; i < difficulty.length; i++) {
                              if (difficulty[i] == difficulty[index]) {
                                diff = difficulty[i][1]
                              }
                            },
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WordsearchGame(diff: diff)),)
                          },
                          child: Container(
                            padding: listViewPadding,
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
                                  Icons.grid_on,
                                  color: Colors.white,
                                  size: size.height * 0.1,
                                ),
                                SizedBox(width: 15),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    difficulty[index][0].toUpperCase(),
                                    style: Theme.of(context).textTheme.headline6.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ignore: missing_return
                        );},
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                            height: 10);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
}
