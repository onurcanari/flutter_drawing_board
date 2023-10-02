import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) {
      exit(1);
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DrawingController _drawingController = DrawingController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  Future<void> _getImageData() async {
    final Uint8List? data =
        (await _drawingController.getImageData())?.buffer.asUint8List();
    if (data == null) {
      return;
    }

    if (mounted) {
      showDialog<void>(
        context: context,
        builder: (BuildContext c) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () => Navigator.pop(c), child: Image.memory(data)),
          );
        },
      );
    }
  }

  Future<void> _getJson() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext c) {
        return Center(
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () => Navigator.pop(c),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 500, maxHeight: 800),
                padding: const EdgeInsets.all(20.0),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ')
                      .convert(_drawingController.getJsonList()),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _getHistory() {
    debugPrint(_drawingController.getHistory
        .take(_drawingController.currentIndex)
        .toString());
  }

  Future<String?> _showDialogToGetObjectName() async => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Enter the object's name"),
            content: TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(hintText: 'Type something...'),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context, _textEditingController.text);
                  _textEditingController.clear();
                },
              ),
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    _drawingController.setPaintContent(EmptyContent());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Drawing Test'),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.history), onPressed: _getHistory),
          IconButton(
              icon: const Icon(Icons.javascript_outlined), onPressed: _getJson),
          IconButton(icon: const Icon(Icons.check), onPressed: _getImageData),
          const SizedBox(width: 40),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return DrawingBoard(
                  controller: _drawingController,
                  background: Container(
                    width: 300,
                    height: constraints.maxHeight,
                    color: Colors.white,
                  ),
                  onPanUpPosition: (_) {
                    if (_drawingController.getHistory.isNotEmpty) {
                      if (_drawingController.getHistory.last
                          is RectangleWithText) {
                        _drawingController.setPaintContent(EmptyContent());
                      }
                    }
                  },
                  showDefaultActions: true,
                  showDefaultTools: true,
                  defaultActionsBuilder: (_) =>
                      DrawingBoard.defaultActions(_drawingController)
                          .sublist(1, 4),
                  defaultToolsBuilder: (Type t, _) => <DefToolItem>[
                    DefToolItem(
                      icon: Icons.mouse_outlined,
                      isActive: t == EmptyContent,
                      onTap: () =>
                          _drawingController.setPaintContent(EmptyContent()),
                    ),
                    DefToolItem(
                      icon: Icons.add_box_outlined,
                      isActive: t == RectangleWithText,
                      onTap: () async {
                        final String? result =
                            await _showDialogToGetObjectName();
                        if (result != null) {
                          if (result.isNotEmpty) {
                            debugPrint('Result: $result');
                            _drawingController
                                .setPaintContent(RectangleWithText(result));
                          }
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SelectableText(
              'https://github.com/fluttercandies/flutter_drawing_board',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
