import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

class ColorPickerHelper extends StatelessWidget {
  const ColorPickerHelper({super.key, this.nowColor});

  final Color? nowColor;

  @override
  Widget build(BuildContext context) {
    Color? _pickColor = nowColor;

    return Material(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                    icon: const Icon(CupertinoIcons.clear),
                    onPressed: () => Navigator.pop(context)),
                IconButton(
                  icon: const Icon(CupertinoIcons.check_mark),
                  onPressed: () => Navigator.pop(context, _pickColor),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ColorPicker(
                color: _pickColor ?? Colors.red,
                onChanged: (Color c) => _pickColor = c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
