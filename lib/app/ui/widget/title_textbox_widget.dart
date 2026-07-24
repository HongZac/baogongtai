
import 'dart:ui';

import 'package:flutter/material.dart';


/// 带标题的文本框
class TitleTextBoxWidget extends StatefulWidget{

  final EdgeInsetsGeometry? margin;
  ///400
  final double? width;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsetsGeometry? titleMargin;
  final String title;
  final String content;
  final Widget? customizeContent;
  ///150
  final double? titleWidth;
  final VoidCallback? onPress;
  final int? maxLines;
  final TextAlign? textAlign;
  ///是否显示冒号
  final bool isShowColon;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final double widthOfSizedBox;
  final String titleTip;
  final Alignment? titleAlignment;


  const TitleTextBoxWidget({
    super.key,
    this.width,
    this.margin,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    required this.title,
    this.titleMargin,
    this.titleWidth,
    this.content = '',
    this.customizeContent,
    this.onPress,
    this.maxLines, // = 1,
    this.textAlign,
    this.isShowColon = true,
    this.titleStyle,
    this.contentStyle,
    this.widthOfSizedBox = 0,
    this.titleTip = '',
    this.titleAlignment,
  });

  @override
  TitleTextBoxWidgetState createState() => TitleTextBoxWidgetState();

}

class TitleTextBoxWidgetState extends State<TitleTextBoxWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      child: Row(
        crossAxisAlignment: widget.crossAxisAlignment,
        mainAxisAlignment: widget.mainAxisAlignment,
        children: [
          Container(
            margin: widget.titleMargin,
            width: widget.titleWidth,
            alignment: widget.titleAlignment ?? Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Tooltip(
                    message: widget.titleTip,
                    child: Text(
                      widget.title,
                      style: widget.titleStyle ?? TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                Text(
                  widget.isShowColon ? '：' : '',
                  style: widget.titleStyle ?? TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          SizedBox(width: widget.widthOfSizedBox,),
          if (widget.customizeContent != null)
            Expanded(
                child: widget.customizeContent!
            )
          else
            Expanded(
                child: SelectableText(
                  widget.content,
                  onTap: (){
                    widget.onPress?.call();
                  },
                  maxLines: widget.maxLines,
                  textAlign: widget.textAlign,
                  style: widget.contentStyle ?? TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                      fontSize: 14
                  ),
                )
            )
        ],
      ),
    );
  }
}