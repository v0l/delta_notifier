library delta_notifier;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef DeltaHandler<T> = void Function(T);
typedef DeltaTransitionBuilder<T> = Widget Function(BuildContext, T);

abstract class DeltaListenable<T> {
  void addListener(DeltaHandler<T> listener);
  void removeListener(DeltaHandler<T> listener);
}

class DeltaNotifer<T> implements DeltaListenable<T> {
  ObserverList<DeltaHandler<T>> _listeners = ObserverList<DeltaHandler<T>>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }

  @override
  void addListener(DeltaHandler<T> listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(listener);
  }

  @override
  void removeListener(DeltaHandler<T> listener) {
    assert(_debugAssertNotDisposed());
    _listeners.remove(listener);
  }

  @protected
  void notifyListeners(T delta) {
    assert(_debugAssertNotDisposed());
    if (_listeners != null) {
      final localListeners = List<DeltaHandler<T>>.from(_listeners);
      for (var listener in localListeners) {
        try {
          if (_listeners.contains(listener)) listener(delta);
        } catch (exception, stack) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'foundation library',
            context: ErrorDescription(
                'while dispatching notifications for $runtimeType'),
            informationCollector: () sync* {
              yield DiagnosticsProperty<DeltaNotifer<T>>(
                'The $runtimeType sending notification was',
                this,
                style: DiagnosticsTreeStyle.errorProperty,
              );
            },
          ));
        }
      }
    }
  }
}

class AnimatedDeltaBuilder<T> extends StatefulWidget {
  final DeltaTransitionBuilder<T> builder;

  const AnimatedDeltaBuilder({
    Key key,
    @required this.builder,
    @required this.listenable,
  })  : assert(listenable != null),
        super(key: key);

  final DeltaListenable<T> listenable;
  
  @override
  _AnimatedDeltaBuilderState createState() => _AnimatedDeltaBuilderState();

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
