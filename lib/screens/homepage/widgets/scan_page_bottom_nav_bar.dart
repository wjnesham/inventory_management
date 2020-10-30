import 'package:flutter/material.dart';
import 'package:pantryfox/bloc/upc_event_state_bloc.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'scan_qr.dart';

Widget scanPageBottomNavigationBar(
    BuildContext context, UpcEventStateBloc upcBloc, GlobalKey<ScaffoldState> _scaffoldKey) {
  // final UpcEventStateBloc upcBloc = BlocProvider.of<UpcEventStateBloc>(context);
  return BottomAppBar(
    color: myColorArray[1],
    child: new Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        scanButton(context, upcBloc, _scaffoldKey),
        Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              /// << < > >>
              dbFirstPageButton(context, upcBloc),
              dbPagePrevButton(context, upcBloc),
              dbPageNextButton(context, upcBloc),
              dbLastPageButton(context, upcBloc),
            ]),
      ],
    ),
  );
}

/////////////////
///
Widget scanButton(BuildContext context, UpcEventStateBloc upcBloc, GlobalKey<ScaffoldState> _scaffoldKey) {
  return GestureDetector(
    onTap: () async {
      await scanQR(context, upcBloc, _scaffoldKey);
      // do this in event or new event: Create event to go to page where item is inserted or updated.

      debugPrint("fix scrolling - this record may not be in view!");
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: new BoxDecoration(color: myColorArray[2], borderRadius: new BorderRadius.circular(18.0)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.camera, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                LocaleKeys.scan.tr(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
