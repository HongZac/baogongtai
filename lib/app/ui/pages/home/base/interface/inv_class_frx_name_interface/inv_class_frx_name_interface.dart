import 'dart:convert';

import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/form/inv_class_frx_name_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/form/inv_class_frx_name_form_view.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///根据产品类别编码区分的打印模板名称列表接口
mixin InvClassFrxNameInterface on GetxController {

  ///根据存储的数据获取产品类别编码区分的打印模板名称列表（存储数据是 String 格式的）
  Map<String, String> _getInvClassFrxNameMapByStorage(String str){
    Map<String, String> dataMap = {};
    try {
      var jsonD = jsonDecode(str);
      if (jsonD is Map){
        jsonD.forEach((key, value) {
          dataMap.addAll({key: value.toString()});
        });
      }
    } catch (e){}
    return dataMap;
  }
  ///根据存储的数据获取产品类别编码区分的打印模板名称列表（存储数据是 String 格式的）
  Map<String, String> Function(String str) get getInvClassFrxNameMapByStorage => _getInvClassFrxNameMapByStorage;



  //region 设置

  ///新增根据产品类别编码区分的打印模板
  Future<void> _addNewInvClassFrxName(Map<String, String> invClassFrxNameMap) async {
    var res = await DialogUtils.showCustomDialog<InvClassFrxNameFormController, Map<String, String>>(
      Get.context!, title: '新增根据产品类别编码区分的打印模板',
      initialHeight: 500,
      initialWidth: 800,
      barrierDismissible: false,
      content: InvClassFrxNameFormView(),
      controller: InvClassFrxNameFormController(
        existInvClassList: invClassFrxNameMap.keys.toList(),
      ),
    );
    if (res != null){
      invClassFrxNameMap.addAll(res);
      update();
    }
  }

  ///编辑指定根据产品类别编码区分的打印模板
  Future<void> _editInvClassFrxName(Map<String, String> invClassFrxNameMap, String key) async {
    var res = await DialogUtils.showCustomDialog<InvClassFrxNameFormController, Map<String, String>>(
      Get.context!, title: '编辑根据产品类别编码区分的打印模板',
      initialHeight: 500,
      initialWidth: 800,
      barrierDismissible: false,
      content: InvClassFrxNameFormView(),
      controller: InvClassFrxNameFormController(
        existInvClassList: invClassFrxNameMap.keys.toList(),
        oldInvClassCode: key,
        oldFrxName: invClassFrxNameMap[key]!,
      ),
    );
    if (res != null){
      if (!res.containsKey(key)){
        invClassFrxNameMap.addAll(res);
      }
      else {
        invClassFrxNameMap.remove(key);
        invClassFrxNameMap.addAll(res);
      }
      update();
    }
  }

  ///删除指定根据产品类别编码区分的打印模板
  void _deleteInvClassFrxName(Map<String, String> invClassFrxNameMap, String key){
    invClassFrxNameMap.remove(key);
    update();
  }


  Widget invClassFrxNameMapSettingWidget(BuildContext context, Map<String, String> invClassFrxNameMap){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
              style: ButtonStyle(
                maximumSize: WidgetStateProperty.all(const Size(80, 35)),
                minimumSize: WidgetStateProperty.all(const Size(80, 35)),
              ),
              onPressed: () async {
                await _addNewInvClassFrxName(invClassFrxNameMap);
              },
              child: Text(
                '新增',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                ),
              ),
            ),
            const SizedBox(width: 4,),
          ],
        ),
        const SizedBox(height: 14,),
        Expanded(
          child: ListView(
            children: List.generate(invClassFrxNameMap.keys.length, (index) {
              String key = invClassFrxNameMap.keys.toList()[index];
              String frxName = invClassFrxNameMap[key]!;
              return ListTile(
                dense: true,
                title: Text(
                  key,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    frxName,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.outline
                    ), maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //itemBtn(
                    //    context,
                    //    title: '修改',
                    //    onPressed: () async {
                    //      await _editInvClassFrxName(
                    //        invClassFrxNameMap,
                    //        key,
                    //      );
                    //    }
                    //),
                    const SizedBox(width: 4,),
                    itemBtn(
                        context,
                        title: '删除',
                        onPressed: () {
                          _deleteInvClassFrxName(
                            invClassFrxNameMap,
                            key,
                          );
                        }
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


  Widget itemBtn(BuildContext context, {
    required String title,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }){
    return FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
              backgroundColor ?? Theme.of(context).colorScheme.surface
          ),
          maximumSize: WidgetStateProperty.all(const Size(80, 35)),
          minimumSize: WidgetStateProperty.all(const Size(80, 35)),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            color: foregroundColor ?? Theme.of(context).textTheme.bodyLarge!.color,
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
          ),
        )
    );
  }


  //endregion

}