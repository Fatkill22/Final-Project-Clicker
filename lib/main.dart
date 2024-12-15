import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/joke_service.dart';
import 'services/iap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: JokeScreen(),
    );
  }
}

class JokeScreen extends StatefulWidget {
  @override
  _JokeScreenState createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> {
  int jokeCounter = 0;
  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;
  final GlobalKey dadJokeKey = GlobalKey();
  final GlobalKey punJokeKey = GlobalKey();
  final GlobalKey darkJokeKey = GlobalKey();
  Offset confettiPosition = Offset(0, 0);
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _audioPlayer = AudioPlayer();
    _audioPlayer.setSource(AssetSource('Assets/laughing.wav'));
    InAppPurchase.instance.purchaseStream.listen((purchaseDetailsList) {
      IAPService.handlePurchaseUpdates(purchaseDetailsList);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchJoke(String type, int cost, GlobalKey buttonKey) async {
    if (jokeCounter >= cost) {
      String newJoke = await JokeService.getJoke(type);
      _showConfetti(buttonKey);
      _playLaughSound();
      _showJokeDialog(newJoke);
      setState(() {
        jokeCounter -= cost;
      });
    } else {
      setState(() {
        _showJokeDialog("Not enough credits! Add more jokes to continue.");
      });
    }
  }

  void _showConfetti(GlobalKey buttonKey) {
    RenderBox box = buttonKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    setState(() {
      confettiPosition = position.translate(box.size.width / 2, box.size.height / 2);
    });
    _confettiController.play();
  }

  void _showJokeDialog(String joke) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Here's Your Joke!"),
          content: Text(joke),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _playLaughSound() {
    if (!isMuted) {
      _audioPlayer.resume();
    }
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      if (isMuted) {
        _audioPlayer.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'Assets/Background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        jokeCounter++;
                        _playLaughSound();
                      });
                    },
                    child: Image.asset(
                      'Assets/joke.png',
                      height: 300,
                      width: 300,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Credits Available: $jokeCounter',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    key: dadJokeKey,
                    onPressed: () => _fetchJoke("https://icanhazdadjoke.com/", 5, dadJokeKey),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text("Dad Joke (5 Credits)"),
                  ),
                  ElevatedButton(
                    key: punJokeKey,
                    onPressed: () => _fetchJoke("https://v2.jokeapi.dev/joke/Programming", 20, punJokeKey),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text("Programming Joke (20 Credits)"),
                  ),
                  ElevatedButton(
                    key: darkJokeKey,
                    onPressed: () => _fetchJoke(
                      "https://v2.jokeapi.dev/joke/Dark?blacklistFlags=nsfw,religious,political,racist,sexist,explicit",
                      50,
                      darkJokeKey,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text("Dark Jokes (50 Credits)"),
                  ),
                  ElevatedButton(
                    onPressed: () => print("almost worked"),//IAPService.buyJokeCredits()
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text("Buy 500 Jokes for 10 PHP"),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: confettiPosition.dx,
            top: confettiPosition.dy,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              shouldLoop: false,
              colors: [Colors.blue, Colors.green, Colors.orange, Colors.purple],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _toggleMute,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
