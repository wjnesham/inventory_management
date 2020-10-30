import 'package:flutter/material.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:easy_localization/easy_localization.dart';

class HelpScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBarWithShadowText(title: LocaleKeys.help.tr()),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return Container(
            height: viewportConstraints.maxHeight,
            color: myColorArray[1],
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      helpTextContainer(
                          LocaleKeys.sortHelp.tr(), LocaleKeys.sort.tr()),
                      helpTextContainer(LocaleKeys.vcrButtonHelp.tr(),
                          LocaleKeys.arrows.tr()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
