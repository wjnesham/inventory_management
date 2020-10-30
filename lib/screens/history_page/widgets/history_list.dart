import 'package:flutter/material.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/model/upcDbHistory.dart';
import 'package:pantryfox/screens/ads/widgets/banner_ad.dart';

import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

import 'history_tile.dart';

final _scrollController = ScrollController();

Widget getHistoryList(
    BuildContext context, List<UpcDbHistory> _upcHistories, GlobalKey<ScaffoldState> _scaffoldKey) {
  _scrollController.addListener(_onScroll);

  if (_upcHistories.isNotEmpty) {
    return standardContainer(
      ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (_upcHistories.asMap().containsKey(index)) {
            return historyTile(context, _upcHistories, _scaffoldKey, index: index);
          }
          return getBottomBannerAd(context);
        },
        itemCount: _upcHistories.length + 1,
        controller: _scrollController,
      ),
    );
  } else {
    return _buildEmptyResults(context);
  }
}

void _onScroll() {
  final maxScroll = _scrollController.position.maxScrollExtent;
  final currentScroll = _scrollController.position.pixels;
  if (currentScroll >= maxScroll) {
    /// Dispatch?
    debugPrint("Bottom of page hit.");
  }
}

Widget _buildEmptyResults(BuildContext context) {
  return standardContainer(Center(child: Text(LocaleKeys.noItemsHelp).tr()));
}

Future<void> executeAfterBuild() async {
  // this toast will display after the build method
}
