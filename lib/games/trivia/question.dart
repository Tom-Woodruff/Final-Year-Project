import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentifit/games/completed.dart';
import 'package:mentifit/games/trivia/quiz.dart';
import 'package:http/http.dart' as http;
import '../../app_database.dart';

int score = 0;
Stopwatch s = new Stopwatch();
int time = 0;

class Questions extends StatefulWidget {
  //taking the category and diff from previous screen
  final int cat;
  final String diff;
  Questions({Key key, @required this.cat, @required this.diff}) : super(key: key);
  @override
  _QuestionsState createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  List<Quiz> _quiz = List<Quiz>();

  @override
  void initState() {
    super.initState();
    populateQuestions();
  }

  void populateQuestions() async {
    //calling functions and storing result in list of quiz objects
    final quiz = await fetchQuestions();
    setState(() {
      _quiz = quiz;
    });
  }

  var kGreyBackground = Colors.grey[500];

  Future<List<Quiz>> fetchQuestions() async {
    //setting the URL using diff and cat
    String url = "/api.php?amount=10&category="+widget.cat.toString();
    url = url+"&difficulty="+widget.diff+"&type=multiple";

    //making connection with the API
    final response = await http.get((Uri.https('www.opentdb.com', url)));

    //if the connection is successful then map the json that is returned
    if (response.statusCode == 200) {
      s.start();
      final result = jsonDecode(response.toString());
      Iterable list = result["results"];
      return list.map((e) => Quiz.fromJson(e)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Quiz');
    }
    }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    score = 0;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        title: Text("Questions",style: Theme.of(context).textTheme.headline5),
        elevation: 0,
      ),
      body: questionList(_quiz),
    );
  }


  ListView questionList(List<Quiz> _quiz) {
    //formatting some unknown special characters in the questions
    for (int i=0;i<_quiz.length;i++){
      if (_quiz[i].question.contains('&quot;')){
        _quiz[i].question = _quiz[i].question.replaceAll('&quot;', '"');
      }
      if (_quiz[i].question.contains('&#039;')){
        _quiz[i].question = _quiz[i].question.replaceAll('&#039;', "'");
      }
      if (_quiz[i].question.contains('&amp;')){
        _quiz[i].question = _quiz[i].question.replaceAll('&amp;', "&");
      }
    };
    return ListView.builder(
      itemCount: _quiz.length,
      itemBuilder: (context, index) => Card(
        color: kGreyBackground,
        elevation: 0.0,
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  //displaying the question
                  _quiz[index].question,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ],
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: Text(((index+1).toString())),
          ),
          //displaying the answers
          children: _quiz[index].allAnswers.map((m) {
            return AnswerWidget(_quiz, index, m, widget.diff, false);
          }).toList(),
        ),
      ),
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Quiz> results;
  final int index;
  final String m;
  final String diff;
  bool answered;

  AnswerWidget(this.results, this.index, this.m, this.diff, this.answered);

  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color c = Colors.black;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        //if all questions have been answered correctly then push data to firebase
        //and move to the completed screen
        if (score == 10){
          s.stop();
          time = time+s.elapsedMilliseconds;
          s.reset();
          String userID = FirebaseAuth.instance.currentUser.uid;
          DocumentSnapshot doc = await FirebaseFirestore.instance.collection('user').doc(userID).get();
          String name = doc.get("name");
          Navigator.push(context, MaterialPageRoute(builder: (context) => CompletedScreen(time: time, name: name, diff: widget.diff,)),);
          await AppDatabase().updateGameData('trivia', time, widget.diff);
          print('done');
        }
        setState(() {
          if (widget.m == widget.results[widget.index].correctAnswer) {
            c = Colors.green;
            score++;
            print(score);
          } else {
            c = Colors.red;
            time+=1000;
          }
        });
      },
      title: Text(
        widget.m,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
