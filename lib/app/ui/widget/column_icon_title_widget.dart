import 'package:flutter/material.dart';

class ColumnIconTitleWidget extends StatelessWidget {

  final String title;
  final IconData iconData;
  final Widget? trailing;

  ColumnIconTitleWidget({
    required this.title,
    required this.iconData,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
          ),
          SizedBox(width: 4,),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (trailing != null)
            trailing!,
        ],
      ),
    );
  }

}