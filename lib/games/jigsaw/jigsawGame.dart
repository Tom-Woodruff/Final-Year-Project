import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:mentifit/games/completed.dart';
import 'package:http/http.dart' as http;

import '../../app_database.dart';


class JigsawGame extends StatefulWidget {
  //taking diff from previous screen
  int diff;
  JigsawGame({Key key, @required this.diff}) : super(key: key);
  @override
  _JigsawGameState createState() => _JigsawGameState();
}

class _JigsawGameState extends State<JigsawGame>
    with SingleTickerProviderStateMixin {
  //initalising variables
  ui.Image canvasImage;
  bool _loaded = false;
  List<JigsawPiece> pieceOnBoard = [];
  List<JigsawPiece> pieceOnPool = [];

  JigsawPiece _currentPiece;
  Animation<Offset> _offsetAnimation;

  final _boardWidgetKey = GlobalKey();

  AnimationController _animController;

  bool completed = false;

  var diff;

  Stopwatch s = new Stopwatch();
  int time = 0;

  var count = 0;


  @override
  void initState() {
    _animController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //if the game isn't loaded then run the function
    if (!_loaded) _prepareGame();
  }

  void _prepareGame() async {
    //clearing an objects from the jigsaw and un-placed pieces
    pieceOnPool.clear();
    pieceOnBoard.clear();

    setState(() {
      _loaded = false;
    });
    //setting the dimensions for the image
    final screenPixelScale = MediaQuery.of(context).devicePixelRatio;
    final imageSize = (400 * screenPixelScale).toInt();
    print('image size: $imageSize');
    //pulling images from the API
    final response = await http.get(Uri.https('picsum.photos', '/$imageSize/$imageSize'));
    final imageData = response.bodyBytes;
    print('Loaded ${imageData.length} bytes');

    //
    final image = MemoryImage(imageData, scale: screenPixelScale);
    canvasImage = await _getImage(image);
    pieceOnPool = _createJigsawPiece(widget.diff);
    pieceOnPool.shuffle();

    setState(() {
      _loaded = true;
      print('Loading done');
      s.start();
    });
    //calling function to pre-place 2 pieces on the board to get the user started
    var random1 = Random().nextInt(widget.diff);
    _setPiece(pieceOnPool[random1]);
    var random2 = Random().nextInt(widget.diff-1);
    _setPiece(pieceOnPool[random2]);
  }

  Future<ui.Image> _getImage(ImageProvider image) async {
    final completer = Completer<ImageInfo>();
    image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((info, _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
            leading: BackButton(),
            title: Text("Jigsaw",style: Theme.of(context).textTheme.headline5),
          ),
          body: _loaded
              ? Column(
            children: [
              Container(
                height: 300,
                alignment: Alignment.center,
                child: _buildBoard(),
              ),
              Expanded(
                child:Container(
                  width: size.width*0.8,
                  alignment: Alignment.center,
                  child: GridView.count(
                    padding: EdgeInsets.all(30),
                    crossAxisCount: crossAxisCount(widget.diff, size.width*0.8),
                    children: pieceOnPool.map((item) => Card(
                      child: Draggable(
                        child: item,
                        feedback: item,
                        childWhenDragging: Opacity(
                          opacity: 0.24,
                          child: item,
                        ),
                        onDragEnd: (details) {
                          _onPiecePlaced(item, details.offset, context);
                        },
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ],
          )
              : Center(child: CircularProgressIndicator()),
        ),
        if (_currentPiece != null)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final offset = _offsetAnimation.value;
              return Positioned(
                left: offset.dx,
                top: offset.dy,
                child: child,
              );
            },
            child: _currentPiece,
          )
      ],
    );
  }

  int crossAxisCount(int diff, double width){
    var num = 300/diff;
    var count = width~/num;
    return count-1;
  }

  Widget _buildBoard() {
    return Container(
      key: _boardWidgetKey,
      width: 300,
      height: 300,
      color: Colors.grey.shade800,
      child: Stack(
        children: [
          for (var piece in pieceOnBoard)
            Positioned(
              left: piece.boundary.left,
              top: piece.boundary.top,
              child: piece,
            ),
        ],
      ),
    );
  }

  //producing the jigsaw pieces by splitting the image into equal blocks
  //based on the difficulty passed into it
  List<JigsawPiece> _createJigsawPiece(int diff) {
    return [
      for (int i = 0; i < diff; i++)
        for (int j = 0; j < diff; j++)
          JigsawPiece(
            key: UniqueKey(),
            image: canvasImage,
            imageSize: Size(300, 300),
            points: [
              Offset((i / diff) * 300, (j / diff) * 300),
              Offset(((i + 1) / diff) * 300, (j / diff) * 300),
              Offset(((i + 1) / diff) * 300, ((j + 1) / diff) * 300),
              Offset((i / diff) * 300, ((j + 1) / diff) * 300),
            ],
          ),
    ];
  }

  //function to pre-place item on the board
  void _setPiece(JigsawPiece piece) {
      setState(() {
        pieceOnPool.remove(piece);
        pieceOnBoard.add(piece);
        count++;
      });


  }


  void _onPiecePlaced(JigsawPiece piece, Offset pieceDropPosition, BuildContext context) {
    //finding the target destination for the specific piece
    final RenderBox box = _boardWidgetKey.currentContext.findRenderObject();
    final boardPosition = box.localToGlobal(Offset.zero);
    final targetPosition = boardPosition.translate(piece.boundary.left, piece.boundary.top);

    const threshold = 48.0;

    final distance = (pieceDropPosition - targetPosition).distance;
    //if the piece is dropped in the correct location
    if (distance < threshold) {
      //remove the selected piece from the un-placed piece list
      setState(() {
        _currentPiece = piece;
        pieceOnPool.remove(piece);
        //incrementing count by 1
        count++;
      });

      //animating the movement from the users drop location to the true location
      //on the board
      _offsetAnimation = Tween<Offset>(
        begin: pieceDropPosition,
        end: targetPosition,
      ).animate(_animController);

      //if the animation is completed
      _animController.addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          //add the specific piece to the onBoard list
          setState(() {
            pieceOnBoard.add(piece);
            _currentPiece = null;
          });
          //if the count equals the number of pieces that should be on the
          //jigsaw
          if (count == (widget.diff*widget.diff)){
            count++;
            //stop timer
            s.stop();
            time += s.elapsedMilliseconds;
            s.reset();
            //depending on the difficulty push data to the data with the
            //following parameters
            if (widget.diff ==3){
              await AppDatabase().updateGameData('jigsaw', time, 'easy');
              diff = 'easy';
            }
            if (widget.diff ==4){
              await AppDatabase().updateGameData('jigsaw', time, 'medium');
              diff = 'medium';
            }
            if (widget.diff ==5){
              await AppDatabase().updateGameData('jigsaw', time, 'hard');
              diff = 'hard';
            }
            //navigate to the completed screen
            String userID = FirebaseAuth.instance.currentUser.uid;
            DocumentSnapshot doc = await FirebaseFirestore.instance.collection('user').doc(userID).get();
            String name = doc.get("name");
            Navigator.push(context, MaterialPageRoute(builder: (context) => CompletedScreen(time: time, name: name, diff: diff,)),);
          }
        }
      });
      const spring = SpringDescription(
        mass: 30,
        stiffness: 1,
        damping: 1,
      );

      final simulation = SpringSimulation(spring, 0, 1, -distance);

      _animController.animateWith(simulation);
    }
  }
}

//jigsaw piece class
class JigsawPiece extends StatelessWidget {
  JigsawPiece({
    Key key,
    @required this.image,
    this.points,
    this.imageSize,
  })  : assert(points != null && points.length > 0),
        boundary = _getBounds(points),
        super(key: key);

  final Rect boundary;
  final ui.Image image;
  final List<Offset> points;
  final Size imageSize;

  Size get size => boundary.size;

  @override
  Widget build(BuildContext context) {
    final pixelScale = MediaQuery.of(context).devicePixelRatio;

    return CustomPaint(
      painter: JigsawPainter(
        image: image,
        boundary: boundary,
        points: points,
        pixelScale: pixelScale,
        elevation: 0,
      ),
      size: size,
    );
  }

  static Rect _getBounds(List<Offset> points) {
    final pointsX = points.map((e) => e.dx);
    final pointsY = points.map((e) => e.dy);
    return Rect.fromLTRB(
      pointsX.reduce(min),
      pointsY.reduce(min),
      pointsX.reduce(max),
      pointsY.reduce(max),
    );
  }
}

//adds the image to the jigsaw object
class JigsawPainter extends CustomPainter {
  final ui.Image image;
  final List<Offset> points;
  final Rect boundary;
  final double pixelScale;
  final double elevation;

  const JigsawPainter({
    @required this.image,
    @required this.points,
    @required this.boundary,
    @required this.pixelScale,
    this.elevation = 0,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint();
    final path = getClip(size);
    if (elevation > 0) {
      canvas.drawShadow(path, Colors.black, elevation, false);
    }

    canvas.clipPath(path);
    canvas.drawImageRect(
        image,
        Rect.fromLTRB(boundary.left * pixelScale, boundary.top * pixelScale,
            boundary.right * pixelScale, boundary.bottom * pixelScale),
        Rect.fromLTWH(0, 0, boundary.width, boundary.height),
        paint);
  }

  Path getClip(Size size) {
    final path = Path();
//    print("Points");
    for (var point in points) {
//      print('${point.dx - boundary.left}, ${point.dy - boundary.top}');
      if (points.indexOf(point) == 0) {
        path.moveTo(point.dx - boundary.left, point.dy - boundary.top);
      } else {
        path.lineTo(point.dx - boundary.left, point.dy - boundary.top);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(oldDelegate) => true;
}