import 'package:flutter/material.dart';
import '../../utils/color_helpers.dart';

Widget counterBadge(String counter) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: HexColor.primaryColor,
      shape: BoxShape.circle,
    ),
    constraints: const BoxConstraints(
      minWidth: 15,
      minHeight: 15,
    ),
    child: Text(
      counter,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
