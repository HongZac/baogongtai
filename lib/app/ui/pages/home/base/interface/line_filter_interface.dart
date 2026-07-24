
import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产产线选择接口（产线管理 660003；生产班组 660021 ; 生产工位 660025 ;）
mixin LineFilterInterface on GetxController {

  ///是否显示生产产线选择器
  bool isShowLinePicker = AppConfig.isShowLinePicker;
  MoBeltLineWithNoPageAdapter? lineAdapter;
  ///产线筛选 选择的产线（可多选，“,”分隔）
  String lineIds = '';


  Future<void> _getLineAdapter() async {
    List<PickerDataModel> list = lineIds.split(',').map((e) => PickerDataModel(id: e)).toList();
    lineAdapter = await AdapterHelper.getAsyncAdapter(
      'line',
      multipleSelection: true,
      selectedItems: list,
      isNeedLoadData: false,
    ) as MoBeltLineWithNoPageAdapter;
  }
  Future<void> Function() get getLineAdapter => _getLineAdapter;


  ///产线选择变化 需要重写
  Future<void> lineOnChanged(List<PickerDataModel> list) async {
    lineIds = list.map((e) => e.id).join(',');
  }


  ///Input 风格的产线选择器
  Widget lineFilterInputWidget(BuildContext context) {
    return TitleTextBoxWidget(
      title: '产线筛选',
      isShowColon: false,
      widthOfSizedBox: 6,
      titleWidth: 70, width: 270,
      customizeContent: PickerInputWidget(
        adapter: lineAdapter,
        height: 50,
        onTap: (List<PickerDataModel> selectList) async{
          await lineOnChanged(selectList);
        },
      ),
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }



  //region 设置

  final List<MoBeltLineModel> lineList = [];


  Future<void> _getLineList({bool isUnVisible = false}) async {
    var lineRes = await MoBeltLineRepository().getPageList(PageConfig(
        page: 1, rows: 999, queryData: {}
    ));
    if (!lineRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取车间列表时出错：${lineRes.message}');
      return;
    }
    lineList.clear();
    lineList.addAll(lineRes.rows);
    List<String> lineIdSelectedList = lineIds.split(',');
    lineList.forEach((element) {
      if (lineIdSelectedList.contains(element.id)){
        element.isChoice = !isUnVisible;
      }
      else {
        element.isChoice = isUnVisible;
      }
    });
  }
  Future<void> Function({bool isUnVisible}) get getLineList => _getLineList;
  
  ///是否显示产线选择器 选择变化
  void _isShowLinePickerOnChanged(){
    isShowLinePicker = !isShowLinePicker;
    update();
  }

  ///产线筛选 选中的产线 选择变化
  void _lineOnChangedForSetting(MoBeltLineModel item){
    item.isChoice = !item.isChoice;
    update();
  }

  ///产线筛选 选中的产线 选择变化（全选、全不选、反选）
  void _lineAllOnChangedForSetting({required bool? allChoice}) {
    lineList.forEach((element) {
      element.isChoice = allChoice ?? !element.isChoice;
    });
    update();
  }


  Widget isShowLinePickerWidget(BuildContext context){
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      value: isShowLinePicker,
      onChanged: (bool? bool) {
        _isShowLinePickerOnChanged();
      },
      title: Text(
        '显示生产产线筛选器',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget lineChoiceTileWidget(BuildContext context){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              '生产产线筛选器初始选中对象',
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 6,),
          OutlinedButton(
            onPressed: () {
              _lineAllOnChangedForSetting(allChoice: true);
            },
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                  kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                      : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
              ),
            ),
            child: Text(
              '全\u00A0\u00A0选',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              ),
            ),
          ),
          const SizedBox(width: 6,),
          OutlinedButton(
            onPressed: () {
              _lineAllOnChangedForSetting(allChoice: false);
            },
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                  kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                      : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
              ),
            ),
            child: Text(
              '全不选',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              ),
            ),
          ),
          const SizedBox(width: 6,),
          OutlinedButton(
            onPressed: () {
              _lineAllOnChangedForSetting(allChoice: null);
            },
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                  kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                      : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
              ),
            ),
            child: Text(
              '反\u00A0\u00A0选',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              ),
            ),
          ),
        ],
      ),
      children: List.generate(lineList.length, (index){
        MoBeltLineModel item = lineList[index];
        return SwitchListTile(
          title: Text(
            '${item.lineCode} ${item.lineName}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          value: item.isChoice,
          onChanged: (bool? boolValue){
            _lineOnChangedForSetting(item);
          },
        );
      }).toList(),
    );
  }

  Widget lineChoiceListWidget(BuildContext context){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 6,),
            OutlinedButton(
              onPressed: () {
                _lineAllOnChangedForSetting(allChoice: true);
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    kIsWeb || GetPlatform.isWindows
                        ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                        : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
                ),
              ),
              child: Text(
                '全\u00A0\u00A0选',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                ),
              ),
            ),
            const SizedBox(width: 6,),
            OutlinedButton(
              onPressed: () {
                _lineAllOnChangedForSetting(allChoice: false);
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    kIsWeb || GetPlatform.isWindows
                        ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                        : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
                ),
              ),
              child: Text(
                '全不选',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                ),
              ),
            ),
            const SizedBox(width: 6,),
            OutlinedButton(
              onPressed: () {
                _lineAllOnChangedForSetting(allChoice: null);
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    kIsWeb || GetPlatform.isWindows
                        ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                        : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
                ),
              ),
              child: Text(
                '反\u00A0\u00A0选',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: lineList.length,
            itemBuilder: (BuildContext context, int index){
              MoBeltLineModel item = lineList[index];
              return CheckboxListTile(
                title: Text(
                  '${item.lineCode} ${item.lineName}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                value: item.isChoice,
                onChanged: (bool? value) async {
                  _lineOnChangedForSetting(item);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  //endregion

}