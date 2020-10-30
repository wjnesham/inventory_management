import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/model/upcDbHistory.dart';

Widget historyTile(BuildContext context, List<UpcDbHistory> histories, GlobalKey<ScaffoldState> _scaffoldKey,
    {int index = 0}) {
  return Slidable(
    actionPane: SlidableDrawerActionPane(),
    actionExtentRatio: 0.25,
    child: Container(
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: BoxDecoration(
          color: Colors.white60,
          border:
              Border(top: BorderSide(color: myColorArray[2]), bottom: BorderSide(color: myColorArray[2]))),
      child: Center(
        child: ListTile(
          leading: Container(
            child: Text("Image?"),
          ),
          title: darkText(
              "Date: " + (getFormattedDateByMilliseconds(histories[index]?.entryMilliseconds, context) ?? "?"),
              smallTextSize),
          subtitle: darkText("User ID: " + (histories[index]?.entryId?.toString() ?? '?'), smallerTextSize),
          contentPadding: const EdgeInsets.all(8.0),
          onTap: () {
            // TODO: ?
          },
        ),
      ),
    ),
    actions: <Widget>[
      IconSlideAction(
        color: Colors.redAccent,
        icon: Icons.delete_outline,
        onTap: () {
          // TODO: remove this history.
          debugPrint("* Remove me * <- Left button");
        },
      ),
    ],
    secondaryActions: <Widget>[
      IconSlideAction(
        color: Colors.redAccent,
        icon: Icons.delete_outline,
        onTap: () {
          // TODO: remove this history?
          debugPrint("Right button -> * Remove me *");
        },
      ),
    ],
  );
}
