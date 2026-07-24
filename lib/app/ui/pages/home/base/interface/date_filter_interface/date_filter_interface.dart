
import 'dart:convert';

import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///单据日期查询接口
mixin DateFilterInterface on GetxController {

  ///是否显示单据日期选择器
  bool isShowDatePicker = AppConfig.isShowDatePicker;

  ///日期选择器的初始值
  ///
  /// y年 m月 d日 h时 s分；
  ///
  /// {
  ///   "startDate": {"m": {"interval": -1}, "d": {"value": "first"}, "h": {"value": 7}, "s": {"value": 30}}, /*上个月的第一天，时间：7:30*/
  ///   "endDate": {"m": {"interval": 0}, "d": {"value": "last"}}, /*本月最后一天*/
  /// }
  Map<String, dynamic> _datePickerValueMap = {};
  Map<String, dynamic> get datePickerValueMap => _datePickerValueMap;
  set datePickerValueMap(Map<String, dynamic> map){
    _datePickerValueMap = map;
    DateTime nowDate = DateTime.now().copyWith(second: 0, millisecond: 0, microsecond: 0);
    _startDate = null;
    _endDate = null;
    if (_datePickerValueMap['startDate'] != null
        && _datePickerValueMap['startDate']!.isNotEmpty
        && _datePickerValueMap['startDate']! is Map<String, dynamic>){
      Map<String, dynamic> dMap = _datePickerValueMap['startDate'];
      _startDate = getDateByMap(map: dMap, nowDate: nowDate);
    }
    if (_datePickerValueMap['endDate'] != null
        && _datePickerValueMap['endDate']!.isNotEmpty
        && _datePickerValueMap['endDate']! is Map<String, dynamic>){
      Map<String, dynamic> dMap = _datePickerValueMap['endDate'];
      _endDate = getDateByMap(map: dMap, nowDate: nowDate);
    }
  }

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get startDateStrWithNoTime => '${DateUtil.getDateStrByDateTime(
      startDate,
      format: DateFormat.YEAR_MONTH_DAY,
      dateSeparate: '-', timeSeparate: ':'
  ) ?? ''} 00:00:00';
  String? get endDateStrWithNoTime => '${DateUtil.getDateStrByDateTime(
      endDate,
      format: DateFormat.YEAR_MONTH_DAY,
      dateSeparate: '-', timeSeparate: ':'
  ) ?? ''} 00:00:00';
  String? get endDateStrWithEndTime => '${DateUtil.getDateStrByDateTime(
      endDate,
      format: DateFormat.YEAR_MONTH_DAY,
      dateSeparate: '-', timeSeparate: ':'
  ) ?? ''} 23:59:5';

  String get dateStr => startDate == null || endDate == null
      ? ''
      : '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
      '到'
      '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';

  ///日期查询类型，该值是[dateSearchTypeList]中对应项的索引
  int dateSearchTypeIndex = AppConfig.dateSearchTypeIndex;
  ///日期查询类型列表
  List<ChoiceChipModel> get dateSearchTypeList => List.unmodifiable([]);
  ///日期查询时对应的关键字段名称，可能会有多个，用“,”分隔
  List<String> get dateSearchQueryDataList => List.unmodifiable([]);



  ///根据存储的数据获取日期选择器的初始值（存储数据是 String 格式的）
  Map<String, dynamic> _getDatePickerValueMapByStorage(String str){
    Map<String, dynamic> map = {};

    try {
      var jsonD = jsonDecode(str);
      if (jsonD is Map<String, dynamic>){
        map = jsonD;
      }
    } catch (e){}

    return map;
  }
  ///根据存储的数据获取日期选择器的初始值（存储数据是 String 格式的）
  Map<String, dynamic> Function(String str) get getDatePickerValueMapByStorage => _getDatePickerValueMapByStorage;

  ///日期查询类型列表 选择回调
  Future<void> dateSearchTypeOnChanged(ChoiceChipModel item, int index) async {  }

  ///日期选择变化 需要重写
  Future<void> dateOnChanged(String string) async{
    if (string.isEmpty){
      _startDate = null;
      _endDate = null;
    }
    else {
      List<String> dateList = string.split('到');
      if (dateList.length != 2){
        ToastNotification(Get.overlayContext!).error("日期数据错误！");
        return;
      }
      _startDate = DateTime.tryParse(dateList[0]) ?? DateTime.now();
      _endDate = DateTime.tryParse(dateList[1]) ?? DateTime.now();
    }
  }


  ///Input 风格的日期选择器
  Widget dateFilterInputWidget(BuildContext context) {
    List<Widget> dateSearchTypeMenuList = List.generate(dateSearchTypeList.length, (index) {
      ChoiceChipModel e = dateSearchTypeList[index];
      return MenuItemButton(
        onPressed: () {
          dateSearchTypeOnChanged(e, index);
        },
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
              const EdgeInsets.only(top: 24, bottom: 24, left: 12, right: 44)
          ),
        ),
        child: MenuAcceleratorLabel(e.title),
      );
    }).toList();
    return TitleTextBoxWidget(
      title: dateSearchTypeList.length == 1
          ? dateSearchTypeList[0].title
          : '',
      isShowColon: false,
      widthOfSizedBox: 6,
      titleWidth: dateSearchTypeList.length == 1
          ? 70
          : 0,
      width: dateSearchTypeList.length == 1
          ? kIsWeb || GetPlatform.isWindows ? 355 : 360
          : kIsWeb || GetPlatform.isWindows ? 398 : 403,
      customizeContent: PrefixTextField(
        object: 3, height: 50, readOnly: true,
        contentPadding: kIsWeb || GetPlatform.isWindows
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),

        initText: dateStr,
        valueOnChanged: (String string) async{
          await dateOnChanged(string);
        },
        extraPrefixWidget: dateSearchTypeList.length == 1 ?
        null :
        MenuBar(
          style: MenuStyle(
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
          children: [
            SubmenuButton(
              menuChildren: dateSearchTypeMenuList,
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 20)
                )
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 14,),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                    ),
                    child: Text(
                      dateSearchTypeList[dateSearchTypeIndex].title,
                      style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                      ),
                    ),
                  ),
                  const SizedBox(width: 2,),
                  const Icon(
                    Icons.arrow_drop_down,
                  ),
                  const SizedBox(width: 8,),
                ],
              ),
            ),
            VerticalDivider(
              indent: 0, endIndent: 0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }



  //region 设置

  int datePickerEnumIndex = DatePickerEnum.custom.index;
  final TextEditingController dataPickerValueTC = TextEditingController();
  final FocusNode dataPickerValueFN = FocusNode();


  void _getDatePickerEnumIndex(String datePickerValueStr) {
    Map<String, dynamic> datePickerValueMap = getDatePickerValueMapByStorage(datePickerValueStr);
    DateTime? startDate;
    DateTime? endDate;
    DateTime nowDate = DateTime.now().copyWith(second: 0, millisecond: 0, microsecond: 0);
    if (datePickerValueMap['startDate'] != null
        && datePickerValueMap['startDate']!.isNotEmpty
        && datePickerValueMap['startDate']! is Map<String, dynamic>){
      Map<String, dynamic> map = datePickerValueMap['startDate'];
      startDate = getDateByMap(map: map, nowDate: nowDate);
    }
    if (datePickerValueMap['endDate'] != null
        && datePickerValueMap['endDate']!.isNotEmpty
        && datePickerValueMap['endDate']! is Map<String, dynamic>){
      Map<String, dynamic> map = datePickerValueMap['endDate'];
      endDate = getDateByMap(map: map, nowDate: nowDate);
    }
    //region datePickerEnumIndex
    Duration? startDateDuration = startDate?.difference(nowDate);
    Duration? endDateDuration = endDate?.difference(nowDate);
    if (startDateDuration == Duration()
        && endDateDuration == Duration()){
      datePickerEnumIndex = DatePickerEnum.today.index;
    }
    else if (startDateDuration == Duration(days: -1)
        && endDateDuration == Duration(days: -1)) {
      datePickerEnumIndex = DatePickerEnum.lastDay.index;
    }
    else if (startDateDuration == Duration(days: -6)
        && endDateDuration == Duration()) {
      datePickerEnumIndex = DatePickerEnum.lastSevenDays.index;
    }
    else if (startDateDuration == Duration(days: -29)
        && endDateDuration == Duration()) {
      datePickerEnumIndex = DatePickerEnum.lastMonth.index;
    }
    else if (startDateDuration == Duration(days: -89)
        && endDateDuration == Duration()) {
      datePickerEnumIndex = DatePickerEnum.lastThreeMonth.index;
    }
    else {
      datePickerEnumIndex = DatePickerEnum.custom.index;
      dataPickerValueTC.text = datePickerValueStr;
    }
    //endregion
  }
  void Function(String datePickerValueStr) get getDatePickerEnumIndex => _getDatePickerEnumIndex;

  ///是否显示日期选择器 选择变化
  void _isShowDatePickerOnChanged(){
    isShowDatePicker = !isShowDatePicker;
    update();
  }

  ///日期选择器的初始值 选择变化
  void _dataPickerValueOnChanged(int index){
    datePickerEnumIndex = index;
    update();
  }


  Widget isShowDatePickerWidget(BuildContext context){
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      value: isShowDatePicker,
      onChanged: (bool? bool) {
        _isShowDatePickerOnChanged();
      },
      title: Text(
        '显示日期筛选器',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget datePickerEnumIndexChoiceWidget(BuildContext context){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      title: Text(
        '日期过滤初始值',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      children: [
        ...DatePickerEnum.values.map((e) {
          String title;
          switch (e){
          //region
            case DatePickerEnum.today:
              title = '今天';
              break;
            case DatePickerEnum.lastDay:
              title = '昨天';
              break;
            case DatePickerEnum.lastSevenDays:
              title = '近七天';
              break;
            case DatePickerEnum.lastMonth:
              title = '近一个月';
              break;
            case DatePickerEnum.lastThreeMonth:
              title = '近三个月';
              break;
            case DatePickerEnum.custom:
              title = '自定义';
              break;
          //endregion
          }
          return RadioListTile(
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            controlAffinity: ListTileControlAffinity.trailing,
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            value: e.index,
            groupValue: datePickerEnumIndex,
            onChanged: (int? index){
              _dataPickerValueOnChanged(index!);
            },
          );
        }),
        ListTile(
          title: Text(
            '自定义内容',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          trailing: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints){
              return SizedBox(
                  width: constraints.maxWidth == double.infinity
                      ? 300
                      : constraints.maxWidth - 110,
                  height: 50,
                  child: TextField(
                    controller: dataPickerValueTC,
                    focusNode: dataPickerValueFN,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 1,
                    onChanged: (String string){
                      update();
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      suffixIcon: dataPickerValueTC.text.isEmpty ? null : MineIconButton(
                        icon: Icons.cancel,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        tooltip: '清空',
                        onPressed: () {
                          dataPickerValueTC.text = '';
                          update();
                        },
                      ),
                    ),
                  )
              );
            },
          ),
        ),
      ],
    );
  }

  //endregion

  @override
  void onClose() {
    dataPickerValueTC.dispose();
    dataPickerValueFN.dispose();
    super.onClose();
  }

}