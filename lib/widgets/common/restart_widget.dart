import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  const RestartWidget({
    super.key,
    required this.child,
    required this.initFunction,
  });

  final Widget child;
  final Future<void> Function() initFunction;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await widget.initFunction();
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> restartApp() async {
    debugPrint('[RestartWidget] restart start, set initializing=true');
    setState(() {
      _isInitializing = true;
    });

    try {
      debugPrint('[RestartWidget] calling initFunction...');
      await widget.initFunction();
      debugPrint('[RestartWidget] initFunction done');
    } finally {
      debugPrint('[RestartWidget] finally mounted=$mounted');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          key = UniqueKey();
        });
        debugPrint('[RestartWidget] setState done, should show app now');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
