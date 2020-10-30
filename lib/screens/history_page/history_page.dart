import 'package:flutter/material.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/model/upcDbHistory.dart';

import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pantryfox/screens/history_page/widgets/history_list.dart';

class HistoryPage extends StatelessWidget {
  // final HistoryBloc _historyBloc;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  HistoryPage();

  @override
  Widget build(BuildContext context) {
    final List<UpcDbHistory> _upcHistories = ModalRoute.of(context).settings.arguments ?? <UpcDbHistory>[];
    return Scaffold(
        key: _scaffoldKey,
        appBar: myAppBarWithShadowText(
            title: "History", rightButton: sortButton(context, LocaleKeys.sortHelp.tr())),
        body: getHistoryList(context, _upcHistories, _scaffoldKey));
  }
}

// import 'package:flutter/material.dart';
// import 'package:pantryfox/bloc/history/index.dart';

// class HistoryPage extends StatefulWidget {
//   static const String historyRoute = '/history';

//   @override
//   _HistoryPageState createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   final _historyBloc = HistoryBloc(UnHistoryState());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('History'),
//       ),
//       body: HistoryScreen(historyBloc: _historyBloc),
//     );
//   }
// }
