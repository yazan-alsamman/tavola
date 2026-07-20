import 'package:flutter/material.dart';

/// Keeps phone numbers, dial codes, and similar values readable in RTL locales.
class AppLtrText extends StatelessWidget {
  const AppLtrText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
  }
}
