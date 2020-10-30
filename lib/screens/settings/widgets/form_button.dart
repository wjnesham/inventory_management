import 'package:flutter/material.dart';
import 'package:pantryfox/helper/userUtils.dart';

class FormButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final EdgeInsetsGeometry padding;

  const FormButton({
    Key key,
    @required this.onPressed,
    @required this.text,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: buttonContainer(myColorArray[2], text, smallTextSize, height: largeButtonSize),
      ),
    );
  }
}

GestureDetector formTile(VoidCallback onPressed, String text, Switch trailing) {
  return GestureDetector(
    onTap: onPressed,
    child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              trailing: trailing,
              title: Text(text),
            ),
            Divider(
              thickness: 1.0,
              color: myColorArray[2],
            ),
          ],
        )),
  );
}
