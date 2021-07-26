import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mentifit/games/trivia/question.dart';
import 'package:mentifit/games/trivia/quiz.dart';
import 'package:mentifit/pages/instructions.dart';

class TriviaHome extends StatefulWidget {
  @override
  _TriviaHomeState createState() => _TriviaHomeState();
}

List categories = [
  "General Knowledge", "Books",  "Film", "Music", "Musicals & Theatres", "Television", "Video Games", "Board Games", "Science & Nature",
  "Computer", "Maths", "Mythology", "Sports", "Geography", "History", "Politics", "Art", "Celebrities", "Animals", "Vehicles", "Comics",
  "Gadgets", "Japanese Anime & Manga", "Cartoon & Animation"];
TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
List difficulty = ["easy", "medium", "hard"];
List<bool> isSelected = [false, true, false];
String diff;
int cat;
List<Quiz> results;

class _TriviaHomeState extends State<TriviaHome> {

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var kGreyBackground = Colors.grey[500];
    var listViewPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        title: Text("Category",style: Theme.of(context).textTheme.headline5),
        elevation: 0,
        actions: [
          SizedBox(
            width: size.width*0.2, // <-- Your width
            child: TextButton(
              child: Text("Instructions", style: TextStyle(color: Colors.black), ),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => InstructionsScreen(game: "trivia")),);
              },
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
               Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      ToggleButtons(
                        constraints: BoxConstraints.tightFor(width: size.width*0.25, height: size.height*0.05),
                        children: [
                          Text(difficulty[0].toString().toUpperCase()),
                          Text(difficulty[1].toString().toUpperCase()),
                          Text(difficulty[2].toString().toUpperCase()),
                        ],
                        isSelected: isSelected,
                        onPressed: (int newIndex) {
                          setState(() {
                            for (int i = 0; i < isSelected.length; i++) {
                              if (i == newIndex) {
                                isSelected[i] = true;
                              }
                              else {
                                isSelected[i] = false;
                              }
                            }
                          });
                        },
                      ),
                    ],
                  ),
              SizedBox(height: 20,),
              Expanded(
                  child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      context = context;
                        return InkWell(
                          onTap: () => {
                            selection(context, cat, diff, categories[index])
                          },
                          child: Container(
                            padding: listViewPadding,
                            height: size.height*0.1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kGreyBackground,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    categories[index].toUpperCase(),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

selection(BuildContext context, int cat, String diff, dynamic item){
  for (int i = 0; i < isSelected.length; i++) {
    if (isSelected[i] == true) {
      diff = difficulty[i];
    }
  }
  for (int i = 0; i < categories.length; i++) {
  if (categories[i] == item) {
  cat = i+10;
  }
  }
  Navigator.push(context, MaterialPageRoute(builder: (context) => Questions(cat: cat, diff: diff)),);
}