

import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///单据状态选择过滤接口
mixin SignFilterInterface on GetxController {

  ///是否显示单据状态选择过滤标签
  bool isShowSignFilter = AppConfig.isShowSignFilter;
  ///单据状态标签是否可以多选
  bool isSignChipMulti = AppConfig.isSignChipMulti;
  ///单据状态标签选中对象的 sign（可多选，取二进制的和）
  int selectedSignBinary = AppConfig.binaryForSignSelected;

  ///单据状态标签列表
  /// get signList => dataType ? orderSignList : taskSignList;
  List<MoSignModel> get signList => List.unmodifiable([]);


  ///状态标签选择变化
  Future<void> signOnChanged(int sign) async {
    if (isSignChipMulti){
      if (selectedSignBinary & sign == sign){
        selectedSignBinary = selectedSignBinary - sign;
      }
      else {
        selectedSignBinary = selectedSignBinary + sign;
      }
    }
    else {
      selectedSignBinary = sign;
    }
  }


  ///Wrap 风格的状态标签选择器
  Widget signWrapWidget(BuildContext context, {EdgeInsetsGeometry? padding}){
    return Wrap(
      runSpacing: 6, spacing: 6,
      children: List.generate(signList.length, (index) {
        MoSignModel item = signList[index];
        return FilterChip(
          selected: selectedSignBinary & item.sign == item.sign,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          onSelected: (bool bool) async{
            await signOnChanged(item.sign);
          },
          padding: padding ?? (kIsWeb || GetPlatform.isWindows
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 14)
              : const EdgeInsets.symmetric(horizontal: 4, vertical: 12)),
          label: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }),
    );
  }

  Widget signMenuWidget(BuildContext context){
    List<MoSignModel> list = signList.where((element) => selectedSignBinary & element.sign == element.sign).toList();
    return SubmenuButton(
      menuChildren: signList.map((e) {
        return MenuItemButton(
          onPressed: () async {
            await signOnChanged(e.sign);
          },
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
                const EdgeInsets.only(top: 22, bottom: 22, left: 12, right: 44)
            ),
          ),
          child: MenuAcceleratorLabel(e.title),
        );
      }).toList(),
      style: ButtonStyle(
          padding: WidgetStateProperty.all(
              kIsWeb || GetPlatform.isWindows
                  ? const EdgeInsets.symmetric(vertical: 20)
                  : const EdgeInsets.symmetric(vertical: 12)
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
              '${list.isEmpty ? '（请选择）' : list.map((e) => e.title).join(',')}',
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
    );
  }



  //region 设置

  ///是否显示单据状态选择过滤标签 选择变化
  void _isShowSignFilterOnChanged() {
    isShowSignFilter = !isShowSignFilter;
    update();
  }

  ///“单据状态标签是否可以多选” 选择变化
  void _isSignChipMultiOnChanged(){
    isSignChipMulti = !isSignChipMulti;
    update();
  }

  ///单据状态标签的初始选中值 选择变化
  void _binaryForSign(int sign) {
    if (isSignChipMulti){
      if (selectedSignBinary & sign == sign){
        selectedSignBinary = selectedSignBinary - sign;
      }
      else {
        selectedSignBinary = selectedSignBinary + sign;
      }
    }
    else {
      selectedSignBinary = sign;
    }
    update();
  }


  Widget isShowSignFilterWidget(BuildContext context){
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      value: isShowSignFilter,
      onChanged: (bool? bool) {
        _isShowSignFilterOnChanged();
      },
      title: Text(
        '显示状态标签',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget isSignChipMultiWidget(BuildContext context){
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      value: isSignChipMulti,
      onChanged: (bool? bool) {
        _isSignChipMultiOnChanged();
      },
      title: Text(
        '状态标签-多选模式',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
  
  Widget signChoiceWidget(BuildContext context){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      title: Text(
        '状态标签初始选中对象',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      children: List.generate(signList.length, (index){
        MoSignModel item = signList[index];
        return SwitchListTile(
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          value: selectedSignBinary & item.sign == item.sign,
          onChanged: (bool? boolValue){
            _binaryForSign(item.sign);
          },
        );
      }).toList(),
    );
  }

  //endregion

}