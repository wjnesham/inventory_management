import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pantryfox/bloc/upc_event.dart';
import 'package:pantryfox/bloc/upc_event_state_bloc.dart';
import 'package:pantryfox/helper/upcUtils.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/model/upcDb.dart';
import 'package:pantryfox/route_names.dart';

class ScanTile extends StatefulWidget {
  final UpcDb _upcDto;

  final GlobalKey<ScaffoldState> _scaffoldKey;

  ScanTile(this._upcDto, this._scaffoldKey);

  @override
  _ScanTileState createState() => _ScanTileState();
}

class _ScanTileState extends State<ScanTile> {
  @override
  Widget build(BuildContext context) {
    final UpcEventStateBloc _upcBloc = BlocProvider.of<UpcEventStateBloc>(context);
    return _scanTile(context, widget._upcDto, _upcBloc, widget._scaffoldKey);
  }

  Widget _scanTile(
      BuildContext context, UpcDb upcDto, UpcEventStateBloc upcBloc, GlobalKey<ScaffoldState> _scaffoldKey) {
    const PLENTY = 9000;

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
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.width * 0.15,
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
                color: Colors.white,
              ),
              child: ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
                  child: Hero(
                    tag: upcDto.code,
                    child: Image.network(
                      upcDto?.imageLink ?? noImage,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) {
                          return Center(child: child);
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print(error);
                        return Image.asset(noImage);
                      },
                    ),
                  )),
            ),
            title: darkText(upcDto.title ?? "Unknown Item", smallTextSize),
            subtitle: darkText("Count: ${widget._upcDto.total.toString()}", smallTextSize),
            contentPadding: const EdgeInsets.all(8.0),
            onTap: () {
              Navigator.pushNamed(context, PantryRoute.upcDetails, arguments: upcDto)
                  .then((_update) async => {
                        if (_update != null)
                          setState(() {
                            if (_update is UpcDb) {
                              UpcDb updatedUpcDb = _update;
                              widget._upcDto.total = updatedUpcDb.total;
                              widget._upcDto.title = updatedUpcDb.title;
                              debugPrint(
                                  "wjndbg: count after item was updated: '${updatedUpcDb.total.toString()}'");
                            }
                          })
                      });
            },
          ),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
          color: Colors.redAccent,
          icon: Icons.delete_outline,
          onTap: () {
            if (upcDto != null) {
              upcBloc.add(ZeroOutItemEvent(upcDto: upcDto));
              setState(() {
                widget._upcDto.total = 0;
              });
              showToast(_scaffoldKey, 'You are out of this item');
            } else {
              debugPrint("Null upcDto?? ScanTile line 44");
            }
          },
        ),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.blue,
          icon: Icons.add_box,
          onTap: () {
            if (upcDto.total <= PLENTY && widget._upcDto.total <= PLENTY) {
              setState(() {
                widget._upcDto.total++;
              });
              upcBloc.add(IncrementItemEvent(upcDto: upcDto));
              showToast(_scaffoldKey, 'Added one.');
            } else {
              debugPrint("You have ${upcDto.total}. It's over 9000!!");
              showToast(_scaffoldKey, 'You have plenty of this item');
            }
          },
        ),
        IconSlideAction(
          color: Colors.indigo,
          icon: Icons.indeterminate_check_box,
          onTap: () {
            if (upcDto.total > 0 && widget._upcDto.total > 0) {
              setState(() {
                widget._upcDto.total--;
              });
              upcBloc.add(DecrementItemEvent(upcDto: upcDto));
              showToast(_scaffoldKey, 'Subtracted one');
            } else {
              showToast(_scaffoldKey, 'You are out of this item');
            }
          },
        ),
      ],
    );
  }
}
