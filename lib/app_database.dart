import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentifit/pages/check_screens/checkScreens.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final now = DateTime.now();
//trivia has been removed due to API error
var gameType = ["jigsaw", "wordsearch"];
final random = new Random();
var challengeString = [];
var gameChallenge = [];
var gameDiff = "";

class AppDatabase {
  //collection reference
  final CollectionReference user = FirebaseFirestore.instance.collection('user');

  updateUserData(String name,) async {
    await user.doc(_auth.currentUser.uid).set({
      'name': name,
      'jigsawEasy' : 0,
      'jigsawMedium' : 0,
      'jigsawHard' : 0,
      'wordsearchEasy' : 0,
      'wordsearchMedium' : 0,
      'wordsearchHard' : 0,
      'triviaEasy' : 0,
      'triviaMedium' : 0,
      'triviaHard' : 0,
    });
    await user.doc(_auth.currentUser.uid).collection('challenges').doc('set').set({
      'timeSet': DateTime(now.year, now.month, now.day-2),
      'gComplete': false,
      'eComplete': false,
      'dComplete': false,
      'games' : '',
      'diet' : '',
      'exercise' : '',
      'gameDiff': '',
      'gameCount': 0,
    });

    newChallenges('games', gameType[random.nextInt(gameType.length)]);
    newChallenges('diet', "mediterranean");
    newChallenges('exercise', "moving");
  }

  newChallenges(String type, String coll) async {
    QuerySnapshot docs = await FirebaseFirestore.instance.collection('challenges')
        .doc(type).collection(coll)
        .get();
    listDocs = docs.docs;
    int rand = random.nextInt(listDocs.length);
    challengeString.add(listDocs[rand].get('challenge'));
    if (type == "games"){
      gameDiff+=coll;
      gameDiff+=listDocs[rand].get('diff')[0].toUpperCase() + listDocs[rand].get('diff').substring(1);
    }
    await FirebaseFirestore.instance.collection('user').doc(_auth.currentUser.uid).collection('challenges').doc('set').update(
        {
          'timeSet': DateTime.now(),
          type: challengeString.last,
          type[0]+'Complete': false,
          'gameDiff': gameDiff,
          'gameCount': 0,
        });
    gameDiff="";
  }

  updateGameData(String game, int time, String difficulty) async {
    print(_auth.currentUser.uid);
    DocumentSnapshot docs = await user.doc(_auth.currentUser.uid).get();
    DocumentSnapshot challengeDoc = await user.doc(_auth.currentUser.uid).collection('challenges').doc('set').get();
    if (challengeDoc.get('gameDiff') == game+difficulty[0].toUpperCase()+difficulty.substring(1)){
      await user.doc(_auth.currentUser.uid).collection('challenges').doc('set').update({
        'gameCount' : challengeDoc.get('gameCount')+1,
      });
      if (difficulty == "hard") {
        if (challengeDoc.get("gameCount")+1>0){
          await user.doc(_auth.currentUser.uid).collection('challenges').doc('set').update(
              {
                'gComplete': true,
              });
        }
      }
      if (difficulty == "medium"){
        if (challengeDoc.get("gameCount")+1>1){
          await user.doc(_auth.currentUser.uid).collection('challenges').doc('set').update(
              {
                'gComplete': true,
              });
        }
      }
      else{
        if (challengeDoc.get("gameCount")+1>2){
          await user.doc(_auth.currentUser.uid).collection('challenges').doc('set').update(
              {
                'gComplete': true,
              });
        }
      }
    }
    await user.doc(_auth.currentUser.uid).collection(game).add({
      'time': time,
      'difficulty': difficulty,
      'date': DateTime.now(),
    });
    updateCount(docs, game, difficulty);

  }

  updateCount(DocumentSnapshot docs, String game, String difficulty) async {
    String diff = difficulty[0].toUpperCase()+difficulty.substring(1);
    print(game+diff);
    await user.doc(_auth.currentUser.uid).update({
      game+diff : docs.get(game+diff)+1,
    });
  }
}
