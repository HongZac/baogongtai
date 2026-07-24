
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


///车间选择接口
mixin DepFilterInterface on GetxController {

  ///是否显示车间选择器
  bool isShowDepPicker = AppConfig.isShowDepPicker;
  DepartmentAdapter? depAdapter;
  ///车间筛选 选中的车间（可多选，“,”分隔）
  String depIds = '';


  Future<void> _getDepAdapter() async{
    List<PickerDataModel> list = depIds.split(',').map((e) => PickerDataModel(id: e)).toList();
    depAdapter = await AdapterHelper.getAsyncAdapter(
      'dep',
      multipleSelection: true,
      selectedItems: list,
      isNeedLoadData: false,
    ) as DepartmentAdapter;
  }
  Future<void> Function() get getDepAdapter => _getDepAdapter;


  ///车间选择变化 需要重写
  Future<void> depOnChanged(List<PickerDataModel> list) async{
    depIds = list.map((e) => e.id).join(',');
  }


  ///Input 风格的车间选择器
  Widget depFilterInputWidget(BuildContext context) {
    return TitleTextBoxWidget(
      title: '车间筛选',
      isShowColon: false,
      widthOfSizedBox: 6,
      titleWidth: 70, width: 270,
      customizeContent: PickerInputWidget(
        adapter: depAdapter,
        height: 50,
        onTap: (List<PickerDataModel> selectList) async{
          await depOnChanged(selectList);
        },
      ),
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }



  //region 设置

  final List<DepartmentModel> depList = [];


  Future<void> _getDepList({bool isUnVisible = false}) async {
    var depRes = await DepartmentRepository().getList(4);
    if (!depRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取车间列表时出错：${depRes.message}');
      return;
    }
    depList.clear();
    depList.addAll(depRes.data);
    List<String> depIdSelectedList = depIds.split(',');
    depList.forEach((element) {
      if (depIdSelectedList.contains(element.departmentId)){
        element.isChoice = !isUnVisible;
      }
      else {
        element.isChoice = isUnVisible;
      }
    });
  }
  Future<void> Function({bool isUnVisible}) get getDepList => _getDepList;

  ///是否显示车间选择器 选择变化
  void _isShowDepPickerOnChanged(){
    isShowDepPicker = !isShowDepPicker;
    update();
  }

  ///车间筛选 选中的车间 选择变化
  void _depOnChangedForSetting(DepartmentModel item) {
    item.isChoice = !item.isChoice;
    update();
  }

  ///车间筛选 选中的车间 选择变化（全选、全不选、反选）
  void _depAllOnChangedForSetting({required bool? allChoice}) {
    depList.forEach((element) {
      element.isChoice = allChoice ?? !element.isChoice;
    });
    update();
  }


  Widget isShowDepPickerWidget(BuildContext context){
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      value: isShowDepPicker,
      onChanged: (bool? bool) {
        _isShowDepPickerOnChanged();
      },
      title: Text(
        '显示车间筛选器',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget depChoiceTileWidget(BuildContext context){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              '车间筛选器初始选中对象',
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 6,),
          OutlinedButton(
            onPressed: () {
              _depAllOnChangedForSetting(allChoice: true);
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
              _depAllOnChangedForSetting(allChoice: false);
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
              _depAllOnChangedForSetting(allChoice: null);
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
      children: List.generate(depList.length, (index){
        DepartmentModel item = depList[index];
        return SwitchListTile(
          title: Text(
            '${item.enCode} ${item.fullName}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          value: item.isChoice,
          onChanged: (bool? boolValue){
            _depOnChangedForSetting(item);
          },
        );
      }).toList(),
    );
  }
  
  Widget depChoiceListWidget(BuildContext context){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 6,),
            OutlinedButton(
              onPressed: () {
                _depAllOnChangedForSetting(allChoice: true);
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
                _depAllOnChangedForSetting(allChoice: false);
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
                _depAllOnChangedForSetting(allChoice: null);
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
            itemCount: depList.length,
            itemBuilder: (BuildContext context, int index){
              DepartmentModel item = depList[index];
              return CheckboxListTile(
                title: Text(
                  '${item.enCode} ${item.fullName}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                value: item.isChoice,
                onChanged: (bool? value) async {
                  _depOnChangedForSetting(item);
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