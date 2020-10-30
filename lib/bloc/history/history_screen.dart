import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantryfox/bloc/history/index.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    Key key,
    @required HistoryBloc historyBloc,
  })  : _historyBloc = historyBloc,
        super(key: key);

  final HistoryBloc _historyBloc;

  @override
  HistoryScreenState createState() {
    return HistoryScreenState();
  }
}

class HistoryScreenState extends State<HistoryScreen> {
  HistoryScreenState();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
        // cubit: widget._historyBloc,
        builder: (
      BuildContext context,
      HistoryState currentState,
    ) {
      if (currentState is UnHistoryState) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if (currentState is ErrorHistoryState) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(currentState.errorMessage ?? 'Error'),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: RaisedButton(
                color: Colors.blue,
                child: Text('reload'),
                onPressed: _load,
              ),
            ),
          ],
        ));
      }
      if (currentState is InHistoryState) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(currentState.hello),
            ],
          ),
        );
      }
      return Center(
        child: CircularProgressIndicator(),
      );
    });
  }

  void _load() {
    widget._historyBloc.add(LoadHistoryEvent());
  }
}
