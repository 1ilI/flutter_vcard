import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_vcard/flutter_vcard.dart';

final colors = [
  Colors.blue,
  Colors.yellow,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.pink,
  Colors.grey,
  Colors.purple,
  Colors.teal,
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VCard Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'VCard Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late VCardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VCardController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () {
            _controller.previous();
          },
          icon: Icon(
            Icons.skip_previous,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _controller.next();
            },
            icon: Icon(
              Icons.skip_next,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Center(
        child: Demo1(
          controller: _controller,
        ),
      ),
    );
  }
}

/// demo1
class Demo1 extends StatefulWidget {
  final VCardController? controller;
  Demo1({Key? key, this.controller}) : super(key: key);

  @override
  State<Demo1> createState() => _Demo1State();
}

class _Demo1State extends State<Demo1> {
  List colorList = List.from(colors);

  // load more data
  _addNewData() {
    for (var i = 0; i < 10; i++) {
      Color c = Color.fromRGBO(Random().nextInt(255), Random().nextInt(255),
          Random().nextInt(255), 1);
      colorList.add(c);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 50;
    final height = min(MediaQuery.of(context).size.height, width * 1.8);
    return VCardView(
      size: Size(width, height),
      controller: widget.controller,
      itemCount: colorList.length,
      itemBuild: (context, index) {
        return Card(
          clipBehavior: Clip.hardEdge,
          elevation: 3,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            color: colorList[index],
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(color: Colors.white, fontSize: 50),
              ),
            ),
          ),
        );
      },
      endCallback: () {
        print('---->end');
      },
      indexChangeCallback: (index) {
        print('changed--->$index');
        // loading more data
        if (index > colorList.length - 3) {
          print('loading more data...');
          _addNewData();
        }
      },
      nextCallback: (index) {
        print('next--->$index');
      },
      previousCallback: (index) {
        print('previous--->$index');
      },
    );
  }
}

/// demo
class Demo extends StatelessWidget {
  final VCardController? controller;

  const Demo({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 64;
    final height = min(MediaQuery.of(context).size.height, width * 1.8);

    return Container(
      child: VCardView(
        size: Size(width, height),
        controller: controller,
        itemCount: colors.length,
        itemBuild: (context, index) {
          return Card(
            clipBehavior: Clip.hardEdge,
            elevation: 3,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(color: colors[index]),
          );
        },
        endCallback: () {
          print('---->end');
        },
        indexChangeCallback: (index) {
          print('changed--->$index');
        },
        nextCallback: (index) {
          print('next--->$index');
        },
        previousCallback: (index) {
          print('previous--->$index');
        },
      ),
    );
  }
}
