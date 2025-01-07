import 'package:flutter/material.dart';

import '../../manager/service_manager.dart';

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
  _RestartWidgetState createState() => _RestartWidgetState();
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
    setState(() {
      _isInitializing = true;
    });

    try {
      await widget.initFunction();
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          key = UniqueKey();
        });
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
