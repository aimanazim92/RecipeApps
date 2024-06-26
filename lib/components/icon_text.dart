import 'package:flutter/material.dart';
import 'package:untitled/components/color.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconText({super.key,
     required this.icon,
     required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15.0,
          color: kSecondaryColor,
        ),
        const SizedBox(
          width: 5.0,
        ),
        Text(
          text,
          style: const TextStyle(
            color: kTextColor,
          ),
        ),
      ],
    );
  }
}