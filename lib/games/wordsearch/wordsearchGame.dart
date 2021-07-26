import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentifit/games/completed.dart';
import 'package:random_words/random_words.dart';
import 'package:word_search/word_search.dart';

import '../../app_database.dart';

class WordsearchGame extends StatefulWidget {
  final int diff;
  WordsearchGame({Key key, @required this.diff}) : super(key: key);

  @override
  _WordsearchGameState createState() => _WordsearchGameState();
}

class _WordsearchGameState extends State<WordsearchGame> {
  var diff;
  int numBoxPerRow = 0;
  double padding = 5;
  Size sizeBox = Size.zero;
  int count = 0;
  Stopwatch s = new Stopwatch();
  int time = 0;

  ValueNotifier<List<List<String>>> listChars;
  // save all answers on generate crossword data
  ValueNotifier<List<CrosswordAnswer>> answerList;
  ValueNotifier<CurrentDragObj> currentDragObj;
  ValueNotifier<List<int>> charsDone;

  @override
  void initState() {
    super.initState();
    //indirectly setting the size of the wordsearch to be proportional to diff
    numBoxPerRow = widget.diff;
    listChars = new ValueNotifier<List<List<String>>>([]);
    answerList = new ValueNotifier<List<CrosswordAnswer>>([]);
    currentDragObj = new ValueNotifier<CurrentDragObj>(new CurrentDragObj());
    charsDone = new ValueNotifier<List<int>>(new List<int>());
    // generate char array crossword
    generateRandomWord();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var kGreyBackground = Colors.grey[500];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        leading: BackButton(),
        title: Text("Wordsearch",style: Theme.of(context).textTheme.headline5),
      ),
    body: Container(
      child: Column(
        children: [
          SizedBox(height: size.height*0.075,),
          Container(
            width: 350,
            height: 350,
            color: kGreyBackground,
            alignment: Alignment.center,
            padding: EdgeInsets.all(padding),
            margin: EdgeInsets.all(padding),
            child: drawCrosswordBox(),
          ),
          SizedBox(height: size.height*0.02,),
          Text("Words", textAlign: TextAlign.center,style: TextStyle(decoration: TextDecoration.underline, fontSize: 30),),
          SizedBox(height: size.height*0.02,),
          Container(
            alignment: Alignment.center,
            // show list word we need solve
            child: drawAnswerList(),
          ),
        ],
      ),
    ),
    );
  }

  Future<void> onDragEnd(PointerUpEvent event) async {
    print("PointerUpEvent");
    print("TIME: "+time.toString());
    // check if drag line object got value or not. if not no need to clear
    if (currentDragObj.value.currentDragLine == null) return;

    currentDragObj.value.currentDragLine.clear();
    currentDragObj.notifyListeners();

    //if the count equals the diff
    if (count == widget.diff){
      count+= 5;
      //stop timer
      s.stop();
      time = s.elapsedMilliseconds;
      //push data to the database
      if (widget.diff ==6){
        await AppDatabase().updateGameData('wordsearch', time, 'easy');
        diff = 'easy';
      }
      if (widget.diff ==8){
        await AppDatabase().updateGameData('wordsearch', time, 'medium');
        diff = 'medium';
      }
      if (widget.diff ==10){
        await AppDatabase().updateGameData('wordsearch', time, 'hard');
        diff = 'hard';
      }
      //navigate to the completed screen
      String userID = FirebaseAuth.instance.currentUser.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('user').doc(userID).get();
      String name = doc.get("name");
      Navigator.push(context, MaterialPageRoute(builder: (context) => CompletedScreen(time: time, name: name, diff: diff,)));
    }
  }

  void onDragUpdate(PointerMoveEvent event) {
    // generate ondragLine so we know to highlight path later & clear if condition dont meet
    generateLineOnDrag(event);

    // get index on drag
    int indexFound = answerList.value.indexWhere((answer) {
      return answer.answerLines.join("-") ==
          currentDragObj.value.currentDragLine.join("-");
    });

    print(currentDragObj.value.currentDragLine.join("-"));
    if (indexFound >= 0) {
      answerList.value[indexFound].done = true;
      count++;
      //save answerList when complete
      charsDone.value.addAll(answerList.value[indexFound].answerLines);
      charsDone.notifyListeners();
      answerList.notifyListeners();
      onDragEnd(null);
    }
  }

  int calculateIndexBasePosLocal(Offset localPosition) {
    // get size max per box
    double maxSizeBox =
    ((sizeBox.width - (numBoxPerRow - 1) * padding) / numBoxPerRow);

    if (localPosition.dy > sizeBox.width || localPosition.dx > sizeBox.width)
      return -1;

    int x = 0, y = 0;
    double yAxis = 0, xAxis = 0;
    double yAxisStart = 0, xAxisStart = 0;

    for (var i = 0; i < numBoxPerRow; i++) {
      xAxisStart = xAxis;
      xAxis += maxSizeBox +
          (i == 0 || i == (numBoxPerRow - 1) ? padding / 2 : padding);

      if (xAxisStart < localPosition.dx && xAxis > localPosition.dx) {
        x = i;
        break;
      }
    }

    for (var i = 0; i < numBoxPerRow; i++) {
      yAxisStart = yAxis;
      yAxis += maxSizeBox +
          (i == 0 || i == (numBoxPerRow - 1) ? padding / 2 : padding);

      if (yAxisStart < localPosition.dy && yAxis > localPosition.dy) {
        y = i;
        break;
      }
    }

    return y * numBoxPerRow + x;
  }

  void generateLineOnDrag(PointerMoveEvent event) {
    // if current drag line is null, declare new list for we can save value
    if (currentDragObj.value.currentDragLine == null)
      currentDragObj.value.currentDragLine = new List<int>();

    // calculate index array base local position on drag
    int indexBase = calculateIndexBasePosLocal(event.localPosition);

    if (indexBase >= 0) {
      // check drag line already pass 2 box
      if (currentDragObj.value.currentDragLine.length >= 2) {
        // check drag line is straight line
        WSOrientation wsOrientation;

        if (currentDragObj.value.currentDragLine[0] % numBoxPerRow ==
            currentDragObj.value.currentDragLine[1] % numBoxPerRow)
          wsOrientation =
              WSOrientation.vertical; // this should vertical.. my mistake.. :)
        else if (currentDragObj.value.currentDragLine[0] ~/ numBoxPerRow ==
            currentDragObj.value.currentDragLine[1] ~/ numBoxPerRow)
          wsOrientation = WSOrientation.horizontal;

        if (wsOrientation == WSOrientation.horizontal) {
          if (indexBase ~/ numBoxPerRow !=
              currentDragObj.value.currentDragLine[1] ~/ numBoxPerRow)
            onDragEnd(null);
        } else if (wsOrientation == WSOrientation.vertical) {
          if (indexBase % numBoxPerRow !=
              currentDragObj.value.currentDragLine[1] % numBoxPerRow)
            onDragEnd(null);
        } else
          onDragEnd(null);
      }

      if (!currentDragObj.value.currentDragLine.contains(indexBase))
        currentDragObj.value.currentDragLine.add(indexBase);
      else if (currentDragObj.value.currentDragLine.length >=
          2) if (currentDragObj.value.currentDragLine[
      currentDragObj.value.currentDragLine.length - 2] ==
          indexBase) onDragEnd(null);
    }
    currentDragObj.notifyListeners();
  }

  void onDragStart(int indexArray) {
    try {
      List<CrosswordAnswer> indexSelecteds = answerList.value
          .where((answer) => answer.indexArray == indexArray)
          .toList();

      // check indexSelecteds got any match , if 0 no proceed!
      if (indexSelecteds.length == 0) return;
      currentDragObj.value.indexArrayOnTouch = indexArray;
      currentDragObj.notifyListeners();
    } catch (e) {}
  }

  Widget drawCrosswordBox() {
    s.start();
    // add listener to catch drag, push down & up
    return Listener(
      onPointerUp: (event) => onDragEnd(event),
      onPointerMove: (event) => onDragUpdate(event),
      child: LayoutBuilder(
        builder: (context, constraints) {
          sizeBox = Size(constraints.maxHeight, constraints.maxHeight);
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisCount: numBoxPerRow,
              crossAxisSpacing: padding,
              mainAxisSpacing: padding,
            ),
            itemCount: numBoxPerRow * numBoxPerRow,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // merge 2d array to become 1d
              String char = listChars.value.expand((e) => e).toList()[index];
              return Listener(
                onPointerDown: (event) => onDragStart(index),
                child: ValueListenableBuilder(
                  valueListenable: currentDragObj,
                  builder: (context, CurrentDragObj value, child) {
                    Color color = Colors.white;

                    if (value.currentDragLine.contains(index))
                      color = Colors
                          .blue; // change color when path line is contain index
                    else if (charsDone.value.contains(index))
                      color =
                          Colors.green; // change color box already path correct

                    return Container(
                      decoration: BoxDecoration(
                        color: color,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        char.toUpperCase(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void generateRandomWord() {
    final List<String> wl = new List<String>();
    // words we want put on crossword game
    generateNoun().take(widget.diff).forEach((e) {
      wl.add(e.toString());
    });
    // setup configuration to generate crossword
    // Create the puzzle setting object
    final WSSettings ws = WSSettings(
      width: numBoxPerRow,
      height: numBoxPerRow,
      orientations: List.from([
        WSOrientation.horizontal,
        WSOrientation.horizontalBack,
        WSOrientation.vertical,
        WSOrientation.verticalUp,
        // WSOrientation.diagonal,
        // WSOrientation.diagonalUp,
      ]),
    );
    // Create new instance of the WordSearch class
    final WordSearch wordSearch = WordSearch();
    // Create a new puzzle
    final WSNewPuzzle newPuzzle = wordSearch.newPuzzle(wl, ws);

    // if there are no errors generated while creating the puzzle
    if (newPuzzle.errors.isEmpty) {

      // List<List<String>> charsArray = newPuzzle.puzzle;
      listChars.value = newPuzzle.puzzle;
      // done pass..ez

      // Solve puzzle for given word list
      final WSSolved solved = wordSearch.solvePuzzle(newPuzzle.puzzle, wl);

      answerList.value = solved.found
          .map((solve) => new CrosswordAnswer(solve, numPerRow: numBoxPerRow))
          .toList();
    }
  }
 //creating the answer list to sit beneath the wordsearch
  drawAnswerList() {
    return Container(
      child: ValueListenableBuilder(
        valueListenable: answerList,
        builder: (context, List<CrosswordAnswer> value, child) {
          // lets make custom widget using Column & Row

          // setting number of words per rwo
          int perColTotal = 4;

          // generate using list.generate
          List<Widget> list = List.generate(
              (value.length ~/ perColTotal) +
                  ((value.length % perColTotal) > 0 ? 1 : 0), (int index) {
            int maxColumn = (index + 1) * perColTotal;
            return Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                // generate child row per row
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    maxColumn > value.length
                        ? maxColumn - value.length
                        : perColTotal, ((indexChild) {
                  // declare array to access answerList
                  int indexArray = (index) * perColTotal + indexChild;
                  return
                    Text(
                    // make text more clear to read
                    "${value[indexArray].wsLocation.word}",
                    style: TextStyle(
                      fontSize: 18,
                      //changing colour and style if word is completed
                      color:
                      value[indexArray].done ? Colors.green : Colors.black,
                      decoration: value[indexArray].done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  );
                })).toList(),
              ),
            );
          }).toList();

          return Container(
            child: Column(
              children: list,
            ),
          );
        },
      ),
    );
  }
}

class CurrentDragObj {
  Offset currentDragPos;
  Offset currentTouch;
  int indexArrayOnTouch;
  List<int> currentDragLine = new List<int>();

  CurrentDragObj({
    this.indexArrayOnTouch,
    this.currentTouch,
  });
}

class CrosswordAnswer {
  bool done = false;
  int indexArray;
  WSLocation wsLocation;
  List<int> answerLines;

  CrosswordAnswer(this.wsLocation, {int numPerRow}) {
    this.indexArray = this.wsLocation.y * numPerRow + this.wsLocation.x;
    generateAnswerLine(numPerRow);
  }

  // get answer index for each character word
  void generateAnswerLine(int numPerRow) {
    // declare new list<int>
    this.answerLines = new List<int>();

    // push all index based base word array
    this.answerLines.addAll(List<int>.generate(this.wsLocation.overlap,
            (index) => generateIndexBaseOnAxis(this.wsLocation, index, numPerRow)));
  }

// calculate index base axis x & y
  generateIndexBaseOnAxis(WSLocation wsLocation, int i, int numPerRow) {
    int x = wsLocation.x, y = wsLocation.y;

    if (wsLocation.orientation == WSOrientation.horizontal ||
        wsLocation.orientation == WSOrientation.horizontalBack)
      x = (wsLocation.orientation == WSOrientation.horizontal) ? x + i : x - i;
    else
      y = (wsLocation.orientation == WSOrientation.vertical) ? y + i : y - i;

    return x + y * numPerRow;
  }
}
