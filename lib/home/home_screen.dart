import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../custom/core/core.dart';
import '../custom/indicators/indicators.dart';
import '../custom/wheel/wheel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  StreamController<int> selected = StreamController<int>();
  late ConfettiController _centerController;
  bool isSpinning = false; // To track if the wheel is spinning

  final items = <String>[
    '\$100',
    '\$200',
    '\$300',
    '\$400',
    '\$500',
    '\$600',
    '\$700',
    '\$800',
    '\$900',
    '\$1000',
  ];

  final colors = <Color>[
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.yellow,
    Colors.cyan,
    Colors.teal,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _centerController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    selected.close();
    _centerController.dispose();
    super.dispose();
  }

  var selectedName = "";
  Color selectedColor = Colors.transparent;

  void setValue(int index) {
    selectedName = items[index];
    selectedColor = colors[index];
  }

  void startSpin() {
    setState(() {
      isSpinning = true;
      selected.add(Fortune.randomInt(0, items.length)); // Start the spin
    });
  }

  void stopSpin() {
    setState(() {
      isSpinning = false; // Stop the spin
    });
  }

  @override
  Widget build(BuildContext context) {
    var flag = false;

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.purple.shade300,
      //   title: Center(
      //       child: Text(
      //     'Spin The Wheel',
      //     style: TextStyle(color: Colors.white),
      //   )),
      // ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blueGrey.shade100,
        child: Stack(
          children: [
            SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/home_bg_th.jpg',
                  fit: BoxFit.cover,
                )),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 200,
                ),
                Container(
                  child: SizedBox(
                    height: 300,
                    width: 300,
                    child: FortuneWheel(
                      animateFirst: false,
                      selected: selected.stream,
                      indicators: const <FortuneIndicator>[
                        FortuneIndicator(
                          alignment: Alignment.topCenter,
                          child: TriangleIndicator(
                            color: Colors.black45,
                            width: 35.0,
                            height: 35.0,
                            elevation: 30,
                          ),
                        ),
                      ],
                      items: [
                        for (var i = 0; i < items.length; i++)
                          FortuneItem(
                            style: FortuneItemStyle(
                                color: colors[i],
                                borderWidth: 4,
                                borderColor: Colors.grey),
                            child: Text(
                              items[i],
                              style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                      onAnimationEnd: () {
                        setState(() {
                          isSpinning = false; // Stop the spin
                        });

                        _centerController.play();
                        showWinningDialog(
                            context, selectedName, selectedColor);
                      },
                      onFocusItemChanged: (value) {
                        if (flag == true) {
                          setValue(value);
                        } else {
                          flag = true;
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                        ),
                        onPressed: isSpinning ? null : startSpin,
                        child: Text("Start Spin",
                            style:
                                TextStyle(color: Colors.white, fontSize: 25)),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.pink.shade500),
                        ),
                        onPressed: isSpinning ? stopSpin : null,
                        child: Text(
                          "Stop Spin",
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void showWinningDialog(
      BuildContext context, String selectedName, Color selectedColor) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            backgroundColor: Colors.blue.shade100,
            scrollable: true,
            title: Text(
              "Congratulations! You have won!",
              style: TextStyle(
                fontSize: 30,
                color: selectedColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              children: [
                ConfettiWidget(
                  confettiController: _centerController,
                  blastDirection: pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 1,
                  emissionFrequency: 0.03,
                  numberOfParticles: 10,
                  gravity: 0,
                ),
                SizedBox(height: 10),
                Text(
                  selectedName,
                  style: TextStyle(
                    fontSize: 50,
                    color: selectedColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 30,
                  color: selectedColor,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Closes the dialog
                },
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(Colors.red),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
