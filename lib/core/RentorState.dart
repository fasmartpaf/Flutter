import 'package:flutter/cupertino.dart';
import 'package:rentors/core/InheritedStateContainer.dart';

abstract class Hireleaptate<T extends StatefulWidget> extends State<T> {
  static Hireleaptate of(BuildContext context) {
    return (context
            .dependOnInheritedWidgetOfExactType<InheritedStateContainer>())
        .state;
  }

  void update();

  void updateView(item) {}
}
