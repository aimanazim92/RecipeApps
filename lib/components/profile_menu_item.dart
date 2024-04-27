

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/components/size_config.dart';

import 'color.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    Key? key,
    this.iconSrc,
    this.title,
    required this.press,
  }) : super(key: key);
  final String? iconSrc, title;
  final Function press;

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return InkWell(
      // onTap: press,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: defaultSize * 2, vertical: defaultSize * 3),
        child: SafeArea(
          child: Row(
            children: <Widget>[
              // SvgPicture.asset(iconSrc),
              SizedBox(width: defaultSize * 2),
              Text(
                title!,
                style: TextStyle(
                  fontSize: defaultSize * 1.6, //16
                  color: kTextLightColor,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: defaultSize * 1.6,
                color: kTextLightColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}