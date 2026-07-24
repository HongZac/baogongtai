
import 'package:basement/model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/mes_device_order_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/mes_device_order_item.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///生产 设备对应生产任务单
class MesDeviceOrderPage extends BaseFormPage<MesDeviceOrderController>{

  @override
  Widget contentWidget(BuildContext context, MesDeviceOrderController _){
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
      return buildContent(context, _, constraints);
    });
  }

  Widget buildContent(BuildContext context, MesDeviceOrderController _, BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.all(4),
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12, left: 4, top: 4, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    runSpacing: 4, spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ///搜索框
                      Container(
                        width: 300,
                        child: TextField(
                          controller: _.searchTC,
                          focusNode: _.searchFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          onChanged: (String? string) async{
                            await controller.searchTCOnSearch();
                          },
                          decoration: InputDecoration(
                            hintText: '请输入设备编号',
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(
                              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                            ),
                            contentPadding: kIsWeb || GetPlatform.isWindows
                                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                                : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                            prefixIcon: Icon(
                              Icons.search,
                              size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              color: Theme.of(context).inputDecorationTheme.iconColor,
                            ),
                            suffixIcon: _.searchTC.text.isNotEmpty ?
                            MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () async{
                                await controller.searchTCClear();
                              },
                            ) :
                            null,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                MineIconButton(
                  onPressed: () {
                    Get.rootDelegate.toNamed(AppRoutes.MES_DEVICE_ORDER_SETTING_PAGE);
                  },
                  margin: kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.only(top: 9)
                      : const EdgeInsets.only(),
                  tooltip: '设置',
                  icon: Icons.settings,
                  iconSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43,
                )
              ],
            ),
          ),
          Divider(
            indent: 0, endIndent: 0,
            color: Theme.of(context).dividerTheme.color!.withAlpha(102),
          ),
          Expanded(child: deviceOrderList(context, _))
        ],
      ),
    );
  }

  Widget deviceOrderList(BuildContext context, MesDeviceOrderController _){
    return Container(
      padding: const EdgeInsets.all(4),
      child: GridView.builder(
          shrinkWrap: false,
          semanticChildCount: 0,
          addAutomaticKeepAlives: true,
          controller: _.deviceWBController,
          padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 42),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 370,
            childAspectRatio: _.itemAspectRatio,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _.deviceWBFilterList.length,
          itemBuilder: (BuildContext context, int index){
            ModelWithGetxController<MoDeviceWorkBillList> item = _.deviceWBFilterList[index];
            return MesDeviceOrderItem(tag: 'MesDeviceOrder-${item.model.deviceId}');
          }
      ),
    );
  }


}