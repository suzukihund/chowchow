import 'package:chowchow/provider/popup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

class CCScaffold extends HookWidget {
  const CCScaffold({@required this.child, this.floatingActionButton});

  final Widget child;
  final FloatingActionButton floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final String snackBarText = useProvider(popupProvider.state);
    final double snackPos = snackBarText == null ? -100 : 16;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Column(
              children: <Widget>[
                AppBar(
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    onPressed: Navigator.of(context).pop,
                    icon: const Icon(Icons.house),
                    iconSize: 48,
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
          if (floatingActionButton != null)
            Positioned(
              right: 32,
              bottom: 32,
              child: floatingActionButton,
            ),
          AnimatedPositioned(
            left: 0,
            top: snackPos,
            child: Container(
              margin: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width - 32,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.lightGreen[100],
              ),
              child: Center(
                child: Text(snackBarText ?? '',
                    style: Theme.of(context).textTheme.headline4),
              ),
            ),
            onEnd: () {
              if (snackBarText != null) {
                Future<void>.delayed(const Duration(seconds: 3),
                    context.read(popupProvider).hideSnackBar);
              }
            },
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
