import 'package:flutter/material.dart';
import 'package:pantryfox/helper/userUtils.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myColorArray[2],
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                // colorFilter: ColorFilter.mode(Colors.white, BlendMode.colorDodge),
                // image: AssetImage("assets/images/fox.png"),
                image: AssetImage("assets/images/bag_o_stuff_icon.png"),
                fit: BoxFit.fitWidth,
              ),
            ),
            child: loadingWheel(context),
          ),
        ),
      ),
    );
  }
}
