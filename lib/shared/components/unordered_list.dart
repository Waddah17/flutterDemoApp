import 'package:flutter/material.dart';

import '../../utils/color_helpers.dart';

class UnorderedList extends StatelessWidget {
  const UnorderedList(this.texts);

  final List<String> texts;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var text in texts) {
      // Add list item
      widgetList.add(UnorderedListItem(text));
    }

    return Column(children: widgetList);
  }
}

class UnorderedListItem extends StatelessWidget {
  const UnorderedListItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "• ",
          style: TextStyle(color: HexColor.primaryColor, fontSize: 24),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: HexColor.cardTextPrimaryColor, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
