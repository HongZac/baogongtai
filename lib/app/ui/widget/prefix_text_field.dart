import 'package:basement/utils.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';


enum DatePickerEnum {
  today,
  lastDay,
  lastSevenDays,
  lastMonth,
  lastThreeMonth,
  custom,
}


///日期……输入 + 选择 框
class PrefixTextField extends StatefulWidget{

  final double? width;
  ///要和 contentPadding 一起设置
  final double? height;
  final double? maxWidth;
  final EdgeInsets? margin;
  final String? hintText;
  /// 1 日期 + 时间
  ///
  /// 2 日期范围
  ///
  /// 3 下拉列表：今天、昨天、近七天、近一个月、近三个月、自定义（日期范围）
  ///
  /// 4 日期
  final int object;
  final String initText;
  final ValueChanged<String>? valueOnChanged;
  late final EdgeInsets contentPadding;
  final bool readOnly;
  final VoidCallback? textFieldOnTap;
  final Widget? extraPrefixWidget;


  PrefixTextField({
    super.key,
    this.width,
    this.height = 65,
    this.maxWidth = 400,
    this.margin,
    this.hintText,
    required this.object,
    this.initText = '',
    this.valueOnChanged,
    EdgeInsets? contentPadding,
    this.textFieldOnTap,
    this.readOnly = false,
    this.extraPrefixWidget,
  }){
    this.contentPadding = contentPadding ?? (kIsWeb || GetPlatform.isWindows
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 25)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 22));
  }

  @override
  State<StatefulWidget> createState() => PrefixTextFieldState();
}
class PrefixTextFieldState extends State<PrefixTextField>{

  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  Widget dateChoiceWidget({required String title, VoidCallback? onTap}){
    return MenuItemButton(
      onPressed: () { onTap?.call(); },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
            const EdgeInsets.only(top: 32, bottom: 32, left: 16, right: 48)
        ),
      ),
      child: MenuAcceleratorLabel(title),
    );
  }
  late final List<Widget> dateChoiceList = DatePickerEnum.values.map((e) {
    String title;
    void Function()? onTap;
    switch (e){
      //region
      case DatePickerEnum.today:
        title = '今天';
        onTap = () {
          DateTime startDate = DateTime.now();
          DateTime endDate = DateTime.now();
          textEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          widget.valueOnChanged?.call(textEditingController.text);
        };
        break;
      case DatePickerEnum.lastDay:
        title = '昨天';
        onTap = () {
          DateTime startDate = DateTime.now().add(const Duration(days: -1));
          DateTime endDate = DateTime.now().add(const Duration(days: -1));
          textEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          widget.valueOnChanged?.call(textEditingController.text);
        };
        break;
      case DatePickerEnum.lastSevenDays:
        title = '近七天';
        onTap = () {
          DateTime startDate = DateTime.now().add(const Duration(days: -6));
          DateTime endDate = DateTime.now();
          textEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          widget.valueOnChanged?.call(textEditingController.text);
        };
        break;
      case DatePickerEnum.lastMonth:
        title = '近一个月';
        onTap = () {
          DateTime startDate = DateTime.now().add(const Duration(days: -29));
          DateTime endDate = DateTime.now();
          textEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          widget.valueOnChanged?.call(textEditingController.text);
        };
        break;
      case DatePickerEnum.lastThreeMonth:
        title = '近三个月';
        onTap = () {
          DateTime startDate = DateTime.now().add(const Duration(days: -89));
          DateTime endDate = DateTime.now();
          textEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          widget.valueOnChanged?.call(textEditingController.text);
        };
        break;
      case DatePickerEnum.custom:
        title = '自定义';
        onTap = () async {
          DateTime startDate = DateTime.now();
          DateTime endDate = DateTime.now();
          List<String> dateList = textEditingController.text.split('到');
          if (dateList.length == 2){
            startDate = DateTime.tryParse(dateList[0]) ?? DateTime.now();
            endDate = DateTime.tryParse(dateList[1]) ?? DateTime.now();
          }
          //region dateTimeRange
          DateTimeRange? dateTimeRange = await showDateRangePicker(
              locale: Get.locale!,
              context: Get.context!,
              firstDate: DateTime(1900),
              lastDate: DateTime(2200),
              initialDateRange: DateTimeRange(start: startDate, end: endDate),
              builder: (context, child){
                return TextButtonTheme(
                  data: TextButtonThemeData(
                      style: ButtonStyle(
                          textStyle: WidgetStateProperty.all(
                              Theme.of(context).textTheme.titleLarge
                          )
                      )
                  ),
                  child: Localizations(
                      locale: Get.locale!,
                      delegates: const <LocalizationsDelegate>[
                        DefaultMaterialLocalizations.delegate,
                        DefaultCupertinoLocalizations.delegate,
                        DefaultWidgetsLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                      ],
                      child: child
                  ),
                );
              }
          );
          //endregion
          if (dateTimeRange == null){
            return;
          }
          startDate = dateTimeRange.start;
          endDate = dateTimeRange.end;
          textEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          widget.valueOnChanged?.call(textEditingController.text);
        };
        break;
      //endregion
    }
    return dateChoiceWidget(
      title: title,
      onTap: onTap,
    );
  }).toList();

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.initText;
  }

  @override
  void didUpdateWidget(covariant PrefixTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (textEditingController.text != widget.initText) {
      textEditingController.text = widget.initText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      constraints: BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
      child: TextField(
        controller: textEditingController,
        focusNode: focusNode,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
        readOnly: widget.readOnly,
        onTap: widget.textFieldOnTap,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
          ),
          contentPadding: widget.contentPadding,
          prefixIcon: widget.extraPrefixWidget != null ? 
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.extraPrefixWidget!,
              dateIconButton(context) ?? SizedBox.shrink(),
            ],
          ) : 
          dateIconButton(context),
          suffixIcon: textEditingController.text.isEmpty ? null : MineIconButton(
            icon: Icons.cancel,
            tooltip: '清空',
            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
            onPressed: () async{
              textEditingController.text = '';
              setState(() {  });
              widget.valueOnChanged?.call(textEditingController.text);
            },
          ),
        ),
      ),
    );
  }

  Widget? dateIconButton(BuildContext context){
    switch (widget.object){
      case 1: ///1 日期 + 时间
        return MineIconButton(
          icon: Icons.calendar_month_outlined,
          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
          tooltip: '日期时间选择',
          onPressed: () async{
            DateTime dateTime = DateTime.tryParse(textEditingController.text) ?? DateTime.now();
            DateTime? date;
            TimeOfDay? time;
            //region 日期
            date = await showDatePicker(
                locale: Get.locale!,
                context: Get.context!,
                initialDate: dateTime,
                firstDate: DateTime(1900),
                lastDate: DateTime(2200),
                //locale: Get.locale,
                builder: (context, child){
                  return TextButtonTheme(
                    data: TextButtonThemeData(
                        style: ButtonStyle(
                            textStyle: WidgetStateProperty.all(
                                Theme.of(context).textTheme.titleLarge
                            )
                        )
                    ),
                    child: Localizations(
                        locale: Get.locale!,
                        delegates: const <LocalizationsDelegate>[
                          DefaultMaterialLocalizations.delegate,
                          DefaultCupertinoLocalizations.delegate,
                          DefaultWidgetsLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                        ],
                        child: child
                    ),
                  );
                }
            );
            if (date == null){
              return;
            }
            //endregion
            //region 时间
            if (context.mounted){
              time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (context,child){
                    return TimePickerTheme(
                      data: TimePickerThemeData(
                        dayPeriodTextStyle: Theme.of(context).textTheme.titleLarge,
                        helpTextStyle: Theme.of(context).textTheme.titleLarge,
                        hourMinuteTextStyle: Theme.of(context).textTheme.titleLarge,
                      ),
                      child: TextButtonTheme(
                          data: TextButtonThemeData(
                              style: ButtonStyle(
                                  textStyle: WidgetStateProperty.all(
                                      Theme.of(context).textTheme.titleLarge
                                  )
                              )
                          ),
                          child: Localizations(
                              locale: Get.locale!,
                              delegates: const <LocalizationsDelegate>[
                                DefaultMaterialLocalizations.delegate,
                                DefaultCupertinoLocalizations.delegate,
                                DefaultWidgetsLocalizations.delegate,
                                GlobalMaterialLocalizations.delegate,
                                GlobalWidgetsLocalizations.delegate,
                              ],
                              child: child
                          )
                      ),
                    );
                  }
              );
            }
            if (time == null){
              return;
            }
            //endregion
            DateTime? dateWithTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            textEditingController.text = DateUtil.formatDateTime(
                dateWithTime.toString(),
                DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE
            );
            widget.valueOnChanged?.call(textEditingController.text);
          },
        );
      case 2: ///2 日期范围
        return MineIconButton(
          icon: Icons.calendar_month_outlined,
          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
          tooltip: '日期范围选择',
          onPressed: () async{
            DateTime startDate = DateTime.now();
            DateTime endDate = DateTime.now();
            List<String> dateList = textEditingController.text.split('到');
            if (dateList.length == 2){
              startDate = DateTime.tryParse(dateList[0]) ?? DateTime.now();
              endDate = DateTime.tryParse(dateList[1]) ?? DateTime.now();
            }
            //region dateTimeRange
            DateTimeRange? dateTimeRange = await showDateRangePicker(
                locale: Get.locale!,
                context: Get.context!,
                firstDate: DateTime(1900),
                lastDate: DateTime(2200),
                initialDateRange: DateTimeRange(start: startDate, end: endDate),
                builder: (context, child){
                  return TextButtonTheme(
                    data: TextButtonThemeData(
                        style: ButtonStyle(
                            textStyle: WidgetStateProperty.all(
                                Theme.of(context).textTheme.titleLarge
                            )
                        )
                    ),
                    child: Localizations(
                        locale: Get.locale!,
                        delegates: const <LocalizationsDelegate>[
                          DefaultMaterialLocalizations.delegate,
                          DefaultCupertinoLocalizations.delegate,
                          DefaultWidgetsLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                        ],
                        child: child
                    ),
                  );
                }
            );
            //endregion
            if (dateTimeRange == null){
              return;
            }
            startDate = dateTimeRange.start;
            endDate = dateTimeRange.end;
            textEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
                '到'
                '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
            widget.valueOnChanged?.call(textEditingController.text);
          },
        );
      case 3: ///下拉列表：今天、昨天、近七天、近一个月、近三个月、自定义（日期范围）
        return MenuBar(
          style: MenuStyle(
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          ),
          children: [
            SubmenuButton(
              style: ButtonStyle(
                alignment: Alignment.center,
                visualDensity: VisualDensity(horizontal: -4),
                padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
              ),
              menuChildren: dateChoiceList,
              child: Icon(
                Icons.calendar_month_outlined,
                size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                semanticLabel: '日期范围选择',
              )
            )
          ],
        );
      case 4: ///1 日期
        return MineIconButton(
          icon: Icons.calendar_month_outlined,
          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
          tooltip: '日期时间选择',
          onPressed: () async{
            DateTime dateTime = DateTime.tryParse(textEditingController.text) ?? DateTime.now();
            DateTime? date;
            //region 日期
            date = await showDatePicker(
                locale: Get.locale!,
                context: Get.context!,
                initialDate: dateTime,
                firstDate: DateTime(1900),
                lastDate: DateTime(2200),
                //locale: Get.locale,
                builder: (context, child){
                  return TextButtonTheme(
                    data: TextButtonThemeData(
                        style: ButtonStyle(
                            textStyle: WidgetStateProperty.all(
                                Theme.of(context).textTheme.titleLarge
                            )
                        )
                    ),
                    child: Localizations(
                        locale: Get.locale!,
                        delegates: const <LocalizationsDelegate>[
                          DefaultMaterialLocalizations.delegate,
                          DefaultCupertinoLocalizations.delegate,
                          DefaultWidgetsLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                        ],
                        child: child
                    ),
                  );
                }
            );
            if (date == null){
              return;
            }
            //endregion
            DateTime? dateWithTime = DateTime(date.year, date.month, date.day);
            textEditingController.text = DateUtil.formatDateTime(
                dateWithTime.toString(),
                DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE
            );
            widget.valueOnChanged?.call(textEditingController.text);
          },
        );
      default:
        return null;
    }

  }

}
