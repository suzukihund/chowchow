import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CCButton extends StatelessWidget {
  const CCButton(
      {@required this.child,
      @required this.onPressed,
      this.borderColor,
      this.borderWidth,
      this.padding,
      this.enabled = true});

  final VoidCallback onPressed;
  final Color borderColor;
  final Widget child;
  final EdgeInsets padding;
  final double borderWidth;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
      ),
      child: child,
    );

    if (enabled)
      return FlatButton(
          padding: const EdgeInsets.all(0),
          onPressed: onPressed,
          child: content);
    else
      return content;
  }
}

class TiledButtons extends StatelessWidget {
  const TiledButtons({@required this.buttons, this.height});

  final double height;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    for (final Widget button in buttons) {
      items.add(button);
      if (button != buttons.last) {
        items.add(
            VerticalDivider(width: 2, color: Theme.of(context).primaryColor));
      }
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: Row(
        children: items,
      ),
    );
  }
}
