import 'dart:async';
import 'dart:core';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantryfox/bloc/details_bloc/details_bloc_state.dart';
import 'package:pantryfox/bloc/upc_event.dart';
import 'package:pantryfox/bloc/upc_event_state_bloc.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/screens/ads/widgets/banner_ad.dart';
import 'package:pantryfox/screens/homepage/widgets/scan_page_bottom_nav_bar.dart';
import 'package:pantryfox/screens/settings/widgets/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pantryfox/helper/userUtils.dart';

import '../../singleton.dart';
import 'widgets/drawer_menu.dart';
import 'widgets/scan_tile.dart';
import 'package:easy_localization/easy_localization.dart';

class ScanHomePage extends StatelessWidget {
  final _scrollController = ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScanHomePage() {
    _scrollController.addListener(_onScroll);
  }

  /// Build Build Build Build Build Build Build Build Build Build ///
  @override
  Widget build(BuildContext context) {
    final UpcEventStateBloc upcBloc = BlocProvider.of<UpcEventStateBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: myAppBarWithShadowText(
        title: "PantryFox", // Title
        rightButton: sortButton(context, LocaleKeys.sortHelp.tr()),
      ),
      drawer: getDrawer(context),
      bottomNavigationBar: scanPageBottomNavigationBar(context, upcBloc, _scaffoldKey),
      body: BlocBuilder<UpcEventStateBloc, UpcState>(
        bloc: upcBloc,
        builder: (context, state) {
          if (state is UpcLoadedDtoState) {
            if (state.upcDtoList.isNotEmpty) {
              return _upcDataContainer(state, upcBloc);
            } else {
              return _buildEmptyResults(context, upcBloc, state);
            }
          } else if (state is ItemUpdatedState) {
            // Don't build this
            return _buildEmptyResults(context, upcBloc, state);
          } else {
            return _buildEmptyResults(context, upcBloc, state);
          }
        },
        buildWhen: (previous, current) => (current is UpcLoadedDtoState),
      ),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll) {
      /// Dispatch?
      debugPrint("Bottom of page hit.");
    }
  }

  Widget _buildEmptyResults(BuildContext context, UpcEventStateBloc upcBloc, UpcState state) {
    upcBloc.add(FirstPageEvent(
        offSet: 0,
        fetchQty: int.parse(Singleton.instance?.prefs?.getString(SettingsFormBloc.pageSize) ??
            SettingsFormBloc.defaultPageSize)));
    return standardContainer(
      Center(
        child: Container(
          color: myColorArray[0],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              title: Text(LocaleKeys.noItemsHelp).tr(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> executeAfterBuild() async {
    // this toast will display after the build method
    showToast(_scaffoldKey, LocaleKeys.scanReady.tr());
  }

  Widget _upcDataContainer(UpcState state, UpcEventStateBloc upcBloc) {
    debugPrint('wjndbg: BlocBuilder returning ListView with ScanTile');
    return standardContainer(
      ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (state is UpcLoadedDtoState) {
            if (state.upcDtoList.asMap().containsKey(index)) {
              return ScanTile(state.upcDtoList[index], _scaffoldKey);
            }
          } else if (state is RefreshedItemDetailsState) {
            return ScanTile(state.props[index], _scaffoldKey);
          } else if (state is ItemUpdatedState) {
            return getBottomBannerAd(context);
          }
          return getBottomBannerAd(context);
        },
        itemCount: upcBloc.state.props.length + 1,
        controller: _scrollController,
      ),
    );
  }
} //end class
