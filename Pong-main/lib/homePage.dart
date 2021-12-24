import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pong/ball.dart';
import 'package:pong/brick.dart';
import 'package:pong/welcomeScreen.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

enum direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {

  //LOGIC
  //player variations
  double playerX =  -0.2;
  double brickWidth = 0.4;
  int playerScore = 0;
  // enemy variable
  double enemyX = -0.2;
 int enemyScore = 0;
  //ball
  double ballx = 0;
  double bally = 0;

  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.RIGHT;
  bool gameStarted = false;
  void startGame() {
    gameStarted = true;
    Timer.periodic(Duration(milliseconds: 1), (timer) {
      updatedDirection();

      moveBall();

      moveEnemy();

      if (isPlayerDead()) {
        enemyScore++;
        timer.cancel();
        _showDialog(false);
        // resetGame();
      }
       if (isEnemyDead()) {
        playerScore++;
        timer.cancel();
        _showDialog(true);
        // resetGame();
      }
    });
  }
  bool isEnemyDead(){
    if (bally <= -1) {
      return true;
    }
    return false;
  }

  void moveEnemy() {
    setState(() {
      enemyX = ballx;
    });
  }

  void _showDialog(bool enemyDied) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: Colors.purple,
            title: Center(
              child: Text(
               enemyDied?"Pink Wins": "Purple Wins",
                style: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                      padding: EdgeInsets.all(7),
                      color: Colors.purple[100],
                      child: Text(
                        "Play Again",
                        style: TextStyle(color:enemyDied?Colors.pink[300]: Colors.purple[000]),
                      )),
                ),
              )
            ],
          );
        });
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      gameStarted = false;
      ballx = 0;
      bally = 0;
      playerX = -0.2;
      enemyX =- 0.2;
    });
  }

  bool isPlayerDead() {
    if (bally >= 1) {
      return true;
    }
    return false;
  }

  void updatedDirection() {
    setState(() {
      //update vertical dirction
      if (bally >= 0.9 && playerX + brickWidth>= ballx && playerX  <= ballx) {
        ballYDirection = direction.UP;
      } else if (bally <= -0.9) {
        ballYDirection = direction.DOWN;
      }
      // ipdate horizontal directions
     if (ballx >= 1) {
        ballXDirection = direction.LEFT;
      } else if (ballx <= -1) {
        ballXDirection = direction.RIGHT;
      }
    });
  }

  void moveBall() {
    //vertical movement
    setState(() {
      if (ballYDirection == direction.DOWN) {
        bally += 0.01;
      } else if (ballYDirection == direction.UP) {
        bally -= 0.01;
      }
    });
    //horizontal movement
    setState(() {
      if (ballXDirection == direction.LEFT) {
        ballx -= 0.01;
      } else if (ballXDirection == direction.RIGHT) {
        ballx += 0.01;
      }
    });
  }

  void moveLeft() {
    setState(() {
      if (!(playerX - 0.1 <= -1)) {
        playerX -= 0.1;
      }
    });
  }

  void moveRight() {
    if (!(playerX + brickWidth >= 1)) {
      playerX += 0.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }
      },
      child: GestureDetector(
        onTap: startGame,
        child: Scaffold(
            backgroundColor: Colors.grey[900],
            body: Center(
                child: Stack(
              children: [
                Welcome(gameStarted),

                //top brick
                Brick(enemyX, -0.9, brickWidth, true),
                //scoreboard
                Score(gameStarted,enemyScore,playerScore),
                // ball
                Ball(ballx, bally),
                // //bottom brick
                Brick(playerX, 0.9, brickWidth, false)
              ],
            ))),

      ),
    );
  }
}

class Score extends StatelessWidget {
  final gameStarted;
  final enemyScore;
  final playerScore;
  Score(this.gameStarted, this.enemyScore,this.playerScore, );

  @override
  Widget build(BuildContext context) {
    return gameStarted? Stack(children: [
      Container(
          alignment: Alignment(0, 0),
          child: Container(
            height: 1,
            width: MediaQuery.of(context).size.width / 3,
            color: Colors.grey[800],
          )),
      Container(
          alignment: Alignment(0, -0.3),
          child: Text(
            enemyScore.toString(),
            style: TextStyle(color: Colors.grey[800], fontSize: 100),
          )),
      Container(
          alignment: Alignment(0, 0.3),
          child: Text(
            playerScore.toString(),
            style: TextStyle(color: Colors.grey[800], fontSize: 100),
          )),
    ]): Container();
  }
}
