import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shiftproof/widgets/network/no_internet_screen.dart';

class ConnectionWrapper extends StatefulWidget {
  const ConnectionWrapper({required this.child, super.key});
  final Widget child;

  @override
  State<ConnectionWrapper> createState() => _ConnectionWrapperState();
}

class _ConnectionWrapperState extends State<ConnectionWrapper> {
  bool _hasInternet = true;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on Exception catch (_) {
      // Return true if failed to avoid false positives blocking the app
      setState(() {
        _hasInternet = true;
      });
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      // The connection list contains .none if there is no connection at all
      _hasInternet = !result.contains(ConnectivityResult.none);
    });
  }

  Future<void> _retryConnection() async {
    // Show a loading indicator briefly or just re-check immediately
    final result = await _connectivity.checkConnectivity();
    unawaited(_updateConnectionStatus(result));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main application content
        widget.child,

        // The overlay No Internet screen
        if (!_hasInternet)
          Positioned.fill(
            child: Material(child: NoInternetScreen(onRetry: _retryConnection)),
          ),
      ],
    );
  }
}
