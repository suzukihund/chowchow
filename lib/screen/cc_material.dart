import 'package:flutter/material.dart';

class CCMaterial extends StatelessWidget {
  const CCMaterial({@required this.child, this.onScreenTap});

  final Widget child;
  final VoidCallback onScreenTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xac000000),
      child: GestureDetector(
        onTap: onScreenTap,
        child: Container(
          margin: const EdgeInsets.all(64),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 8, color: Theme.of(context).primaryColor),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Colors.black38,
                blurRadius: 16,
                offset: Offset(2, 8),
              )
            ],
            color: Colors.white,
          ),
          child: child,
        ),
      ),
    );
  }
}
