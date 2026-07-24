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


///加工中心筛选接口
mixin WorkCenterFilterInterface on GetxController {

  ///是否显示加工中心选择器
  bool isShowWorkCenterPicker = AppConfig.isShowWorkCenterPicker;
  MoWorkCenterWithNoPageAdapter? workCenterAdapter;
  ///加工中心筛选 选择的加工中心（可多选，“,”分隔）
  String workCenterIds = '';


  Future<void> _getWorkCenterAdapter() async {
    List<PickerDataModel> list = workCenterIds.split(',').map((e) => PickerDataModel(id: e)).toList();
    workCenterAdapter = await AdapterHelper.getAsyncAdapter(
      'workCenter',
      multipleSelection: true,
      selectedItems: list,
      isNeedLoadData: false,
    ) as MoWorkCenterWithNoPageAdapter;
  }
  Future<void> Function() get getWorkCenterAdapter => _getWorkCenterAdapter;

  ///加工中心选择变化 需要重写
  Future<void> workCenterOnChanged(List<PickerDataModel> list) async {
    workCenterIds = list.map((e) => e.id).join(',');
  }


  ///Input 风格的加工中心选择器
  Widget workCenterFilterInputWidget(BuildContext context) {
    return TitleTextBoxWidget(
      title: '加工中心',
      isShowColon: false,
      widthOfSizedBox: 6,
      titleWidth: 70, width: 270,
      customizeContent: PickerInputWidget(
        adapter: workCenterAdapter,
        height: 50,
        onTap: (List<PickerDataModel> selectList) async{
          await workCenterOnChanged(selectList);
        },
      ),
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }



  //region 设置

  final List<MoWorkCenterModel> workCenterList = [];


  ///获取加工中心列表
  Future<void> _getWorkCenterList({bool isUnVisible = false}) async {
    var res = await MoWorkCenterRepository().getPageList(PageConfig(
      page: 1, rows: 1000, queryData: {},
    ));
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('读取加工中心列表时出错：${res.message}');
      return;
    }
    workCenterList.clear();
    workCenterList.addAll(res.rows);
    List<String> workCenterIdSelectedList = workCenterIds.split(',');
    for (var element in workCenterList) {
      if (workCenterIdSelectedList.contains(element.id)){
        element.isChoice = !isUnVisible;
      }
      else {
        element.isChoice = isUnVisible;
      }
    }
  }
  Future<void> Function({bool isUnVisible}) get getWorkCenterList => _getWorkCenterList;

  ///是否显示加工中心选择器 选择变化
  void _isShowWorkCenterPickerOnChanged(){
    isShowWorkCenterPicker = !isShowWorkCenterPicker;
    update();
  }

  ///加工中心筛选 选中的加工中心 选择变化
  void _workCenterOnChangedForSetting(MoWorkCenterModel item){
    item.isChoice = !item.isChoice;
    update();
  }

  ///加工中心筛选 选中的加工中心 选择变化（全选、全不选、反选）
  void _workCenterAllOnChangedForSetting({required bool? allChoice}) {
    workCenterList.forEach((element) {
      element.isChoice = allChoice ?? !element.isChoice;
    });
    update();
  }

  
  Widget isShowWorkCenterPickerWidget(BuildContext context){
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      value: isShowWorkCenterPicker,
      onChanged: (bool? bool) {
        _isShowWorkCenterPickerOnChanged();
      },
      title: Text(
        '显示加工中心筛选器',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget workCenterChoiceTileWidget(BuildContext context){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              '加工中心筛选器初始选中对象',
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 6,),
          OutlinedButton(
            onPressed: () {
              _workCenterAllOnChangedForSetting(allChoice: true);
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
              _workCenterAllOnChangedForSetting(allChoice: false);
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
              _workCenterAllOnChangedForSetting(allChoice: null);
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
      children: List.generate(workCenterList.length, (index){
        MoWorkCenterModel item = workCenterList[index];
        return SwitchListTile(
          title: Text(
            '${item.lineCode} ${item.lineName}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          value: item.isChoice,
          onChanged: (bool? boolValue){
            _workCenterOnChangedForSetting(item);
          },
        );
      }).toList(),
    );
  }

  Widget workCenterChoiceListWidget(BuildContext context){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 6,),
            OutlinedButton(
              onPressed: () {
                _workCenterAllOnChangedForSetting(allChoice: true);
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
                _workCenterAllOnChangedForSetting(allChoice: false);
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
                _workCenterAllOnChangedForSetting(allChoice: null);
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
            itemCount: workCenterList.length,
            itemBuilder: (BuildContext context, int index){
              MoWorkCenterModel item = workCenterList[index];
              return CheckboxListTile(
                title: Text(
                  '${item.lineCode} ${item.lineName}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                value: item.isChoice,
                onChanged: (bool? value) async {
                  _workCenterOnChangedForSetting(item);
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