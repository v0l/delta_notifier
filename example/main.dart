import 'dart:async';

import 'package:delta_notifier/delta_notifier.dart';
import 'package:flutter/widgets.dart';

enum ModelChangeInfo {
  NoChange,
  FooChange,
  BarChange,
}

class MyModelWidget extends StatelessWidget {
  final Widget child;
  final MyModel model;

  MyModelWidget({this.child, this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedDeltaBuilder<ModelChangeInfo>(
      listenable: model,
      beforeBuild: (c) {
        //some code called before builder
        //can be used for navigation or something else
      },
      builder: (ctx, c) {
        Color col = Color(0xFF000000);

        switch (c) {
          case ModelChangeInfo.NoChange:
            {
              col = Color(0xFFFF0000);
              break;
            }
          case ModelChangeInfo.BarChange:
            {
              col = Color(0xFF00FF00);
              break;
            }
          case ModelChangeInfo.FooChange:
            {
              col = Color(0xFF0000FF);
              break;
            }
        }
        return Column(children: [
          Text(
            model.foo,
            style: TextStyle(color: col),
          ),
          Text(
            model.bar,
            style: TextStyle(color: col),
          ),
        ]);
      },
    );
  }
}

class MyModel extends DeltaNotifer<ModelChangeInfo> {
  int _updateCounter;

  String foo;
  String bar;

  MyModel() {
    Timer(Duration(seconds: 1), () {
      if ((++_updateCounter) % 2 == 0) {
        foo = "Foo: $_updateCounter";
        notifyListeners(ModelChangeInfo.FooChange);
      } else {
        bar = "Bar: $_updateCounter";
        notifyListeners(ModelChangeInfo.BarChange);
      }
    });
  }
}
