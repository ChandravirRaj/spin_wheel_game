import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spin_the_wheel/custom/core/core.dart';

Future pumpFortuneWidget(WidgetTester tester, FortuneWidget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    ),
  );
}

const List<FortuneItem> testItems = <FortuneItem>[
  FortuneItem(child: Text('1')),
  FortuneItem(child: Text('2')),
];