import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:delta_notifier/src/delta_listenable.dart';

typedef DeltaTransitionBuilder<T> = Widget Function(BuildContext, T);

class AnimatedDeltaBuilder<T> extends StatefulWidget {
  final DeltaTransitionBuilder<T> builder;

  /// Handler function to call before [setState] is called.
  /// 
  /// This exists to handle some change in model outside the build scope.
  final DeltaHandler<T> beforeBuild;

  const AnimatedDeltaBuilder({
    Key key,
    @required this.builder,
    @required this.listenable,
    this.beforeBuild,
  })  : assert(listenable != null),
        assert(builder != null),
        super(key: key);

  final DeltaListenable<T> listenable;

  @override
  _AnimatedDeltaBuilderState<T> createState() => _AnimatedDeltaBuilderState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<DeltaListenable<T>>('animation', listenable));
  }
}

class _AnimatedDeltaBuilderState<T> extends State<AnimatedDeltaBuilder<T>> {
  T _tmpData;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(AnimatedDeltaBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listenable != oldWidget.listenable) {
      oldWidget.listenable.removeListener(_handleChange);
      widget.listenable.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange(T data) {
    if(widget.beforeBuild != null) {
      widget.beforeBuild(data);
    }
    _tmpData = data;
    setState(() {
      // The listenable's state is our build state, and it changed already.
    });
  }

  @override
  Widget build(BuildContext context) {
    final ret = widget.builder(context, _tmpData);
    _tmpData = null;
    return ret;
  }
}
