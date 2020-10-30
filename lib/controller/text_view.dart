import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';



TableRow getSimpleTableRow(String fieldName, TextStyle textStyle) {
  return new TableRow(
      children: [
        _getSimpleTextTableCell(fieldName, textStyle),
      ]
  );
}

TableCell _getSimpleTextTableCell(String ptext, TextStyle textStyle) {
  return new TableCell(
      verticalAlignment: TableCellVerticalAlignment.top,
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Flexible(
              fit: FlexFit.tight,
              child: Text(ptext,
                  softWrap: true,
                  style: textStyle))
        ],

      )
  );
}

TableRow getSpanTableRow(String labelText, String ptext, TextStyle textStyle) {
  return new TableRow(
      children: [
        _getSpanTextTableCell(labelText, ptext, textStyle),
      ]
  );
}

TableCell _getSpanTextTableCell(String labelText, String ptext, TextStyle textStyle) {
  return new TableCell(
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Flexible(
              fit: FlexFit.tight,
              child: new RichText(
                text: new TextSpan(
                  style: textStyle,
                  children: <TextSpan>[
                    new TextSpan(text: labelText+" ", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    new TextSpan(text: ptext, ),
                  ],
                ),
              ))
        ],
      )
  );
}


TableRow getClickUrlTableRow(String labelText, String url, TextStyle textStyle) {
  return new TableRow(
      children: [
        _getClickUrlTableCell(labelText, url, textStyle),
      ]
  );
}

TableCell _getClickUrlTableCell(String labelText, String url, TextStyle textStyle) {
  return new TableCell(
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Flexible(
              fit: FlexFit.tight,
              child: new RichText(
                text: new TextSpan(
                  style: textStyle,
                  children: <TextSpan>[
                    //new TextSpan(text: labelText+" ", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    new TextSpan(text: labelText, style: new TextStyle(color: Colors.blue, fontSize: 18), recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          _launchURL(url);
                        }
                    ),
                  ],
                ),
              ))
        ],
      )
  );
}


_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}