import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantryfox/bloc/details_bloc/details_bloc_bloc.dart';
import 'package:pantryfox/bloc/details_bloc/details_bloc_event.dart';
import 'package:pantryfox/bloc/details_bloc/details_bloc_state.dart';
import 'package:pantryfox/bloc/upc_event.dart';
import 'package:pantryfox/bloc/upc_event_state_bloc.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/helper/components.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/model/upcDb.dart';
import 'package:pantryfox/model/upcDbHistory.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pantryfox/route_names.dart';

class DetailsPage extends StatefulWidget {
  DetailsPage();

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final totalController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final weightController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void executeBeforBuild(UpcDb upcDb) {
    if (totalController.text.isEmpty) totalController.text = upcDb.total.toString();
    if (titleController.text.isEmpty) titleController.text = upcDb.title;
    if (descriptionController.text.isEmpty) descriptionController.text = upcDb.description;
    if (brandController.text.isEmpty) brandController.text = upcDb.brand;
    if (modelController.text.isEmpty) modelController.text = upcDb.model;
    if (weightController.text.isEmpty) weightController.text = upcDb.weight;
  }

  @override
  Widget build(BuildContext context) {
    final UpcDb upcDb = ModalRoute.of(context).settings.arguments;
    executeBeforBuild(upcDb);

    // Only use this for updating details.
    final _upcBloc = BlocProvider.of<UpcEventStateBloc>(context);

    final DetailsBlocBloc _detailsBloc = DetailsBlocBloc(InitDetailsState(upcDb));
    _detailsBloc.add(LoadDetailsBlocEvent(upcDb));

    var scaffold = Scaffold(
      key: _scaffoldKey,
      backgroundColor: myColorArray[0],
      appBar: myAppBarWithShadowText(title: LocaleKeys.details.tr()),
      body: BlocBuilder<DetailsBlocBloc, DetailsState>(
        bloc: _detailsBloc,
        builder: (context, state) {
          if (state is SubmittingDetailsState) {
            return Loading();
          }
          if (state is InitDetailsState) {
            debugPrint("Details and histories haven't been loaded yet.");
// Don't build this state.
            _detailsBloc.add(LoadDetailsBlocEvent(upcDb));
            return _detailsPageContainer(context, _detailsBloc, upcDb, _upcBloc);
          } else if (state is RefreshedItemDetailsState) {
            debugPrint("Back to scan page page");

            return Loading();
          } else if (state is RetrievedHistoriesState) {
            // state has histories
            return _detailsPageContainer(context, _detailsBloc, upcDb, _upcBloc, histories: state.histories);
          } else {
            debugPrint("State is -> $state <-");
            return Loading();
          }
        },
        buildWhen: (previous, current) => !(current is InitDetailsState),
      ),
    );

    return scaffold;
  }

  Widget _detailsPageContainer(
      BuildContext context, DetailsBlocBloc detailsBloc, UpcDb upcDto, UpcEventStateBloc _upcBloc,
      {List<UpcDbHistory> histories = const <UpcDbHistory>[]}) {
    return standardContainer(
      GestureDetector(
        child: SingleChildScrollView(
          child: Container(
              child: Column(
            children: <Widget>[
              Container(
                  height: 200.0,
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Hero(tag: upcDto.code, child: Image.network(upcDto.imageLink))),
              detailContainer(LocaleKeys.upc.tr() + ': ' + upcDto.code),

              if (histories.isNotEmpty)
                detailContainer(
                  LocaleKeys.dateAdded.tr() +
                      ': ' +
                      (getFormattedDateByMilliseconds(histories?.first?.entryMilliseconds ?? 0, context)),
                ),

              GestureDetector(
                child: Container(
                  child: detailContainer("Update History: " +
                      // (upcDto?.historyKey) +
                      "\n\tTap for scan history"),
                ),
                onTap: () async {
                  detailsBloc.add(GetUpcHistoriesEvent(histories));

                  Navigator.pushNamed(context, PantryRoute.upcHistory, arguments: histories)
                      .then((value) => "");
                },
              ),

              ///
              getTextField(LocaleKeys.count.tr(), totalController, false, TextInputType.number, context),
              getTextField(LocaleKeys.titleString.tr(), titleController, false, TextInputType.text, context),
              multiLineTextField(LocaleKeys.description.tr(), descriptionController, context),
              getTextField(LocaleKeys.brand.tr(), brandController, false, TextInputType.text, context),
              getTextField(LocaleKeys.model.tr(), modelController, false, TextInputType.text, context),
              getTextField(LocaleKeys.weight.tr(), weightController, false, TextInputType.text, context),
              submitButton(context, detailsBloc, upcDto, _upcBloc),
            ],
          )),
        ),
        onPanDown: (scroll) {
          if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
            // Hide keyboard
            FocusScope.of(context).unfocus();
          }
        },
        onTap: () {
          if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
            // Hide keyboard
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  Widget submitButton(
      BuildContext context, DetailsBlocBloc detailsBloc, UpcDb upcDto, UpcEventStateBloc _upcBloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: GestureDetector(
          onTap: () {
            if (MediaQuery.of(context).viewInsets.bottom.floor() != 0) {
              // Hide keyboard
              FocusScope.of(context).unfocus();
            } else {
              print('Already dismissed keyboard.');
            }

            String totalTemp = totalController.text ?? "";
            int count = int.parse(totalTemp);
            String title = titleController.text ?? "";

            UpcDb updateUpcDto = new UpcDb(
              code: upcDto.code,
              total: count ?? 0,
              title: title.isNotEmpty ? title : LocaleKeys.titleString.tr(),
              description: descriptionController.text ?? "",
              imageLink: upcDto.imageLink,
              cupboard: "",
              brand: brandController.text ?? "",
              model: modelController.text ?? "",
              price: upcDto.price ?? "",
              weight: weightController.text ?? "",
              selected: false,
            );
            // Update
            detailsBloc.add(RefreshItemDetailsEvent(updateUpcDto));
            _upcBloc.add(RefreshItemEvent(upcDto: updateUpcDto));

            if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
              // Hide keyboard
              FocusScope.of(context).unfocus();
            }
            // Back to scan page
            Navigator.pop(context, updateUpcDto);
          },
          child: buttonContainer(myColorArray[1], LocaleKeys.submit.tr(), mediumTextSize)),
    );
  }

  Widget detailContainer(String detail) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration: new BoxDecoration(
            color: myColorArray[0],
            borderRadius: new BorderRadius.all(const Radius.circular(20.0)),
          ),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: darkText(detail, smallTextSize),
          ))),
    );
  }
}
