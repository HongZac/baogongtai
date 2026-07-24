
import 'package:basement/model.dart';
import 'package:basement/service.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_sign_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'device_controller.dart';
import 'device_item.dart';


///设备监控
class DevicePage extends BaseFormPage<DeviceController> {

  @override
  Widget contentWidget(BuildContext context, DeviceController _){
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
      return buildContent(context, _, constraints);
    });
  }


  Widget buildContent(BuildContext context, DeviceController _, BoxConstraints constraints){
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
                      deviceSignWidget(context, _),
                      ///搜索框
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 50,
                        width: _.isSearchWidgetOpen
                            ? 230
                            : 50,
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
                            suffixIcon: _.searchTC.text.isNotEmpty ? MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () async{
                                await controller.searchTCClear();
                              },
                            ) :
                            null,
                            enabledBorder: _.isSearchWidgetOpen
                                ? null
                                : const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          ),
                        ),
                      ),

                      if (_.isDataRefresh)
                        SizedBox(
                          width: 47,
                          child: SpinKitCircle(
                            color: Colors.grey,
                            size: 22,
                          ),
                        )
                      else
                        MineIconButton(
                          onPressed: () async {
                            await controller.onRefreshData();
                          },
                          tooltip: '刷新',
                          icon: Icons.refresh,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        ),
                    ],
                  ),
                ),

                MineIconButton(
                  onPressed: () {
                    Get.rootDelegate.toNamed(
                      AppRoutes.PMES_REAL_TIME_MONITOR_SETTING_PAGE,
                      parameters: {
                        'noPermission': (_.dataService.isEnableOperatePrivilege
                            && _.objectItem.buttons?['desktopUISettingBtn'] == null) ? '1' : '0',
                        'permissionInfo': BaseService.profile.isSystem == true ? '【${_.objectItem.progid}】【desktopUISettingBtn】' : '',
                      },
                    );
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
          Expanded(child: deviceTaskList(context, _))
        ],
      ),
    );
  }


  Widget deviceSignWidget(BuildContext context, DeviceController _){
    return Wrap(
      runSpacing: 6, spacing: 6,
      children: List.generate(_.deviceSignList.length, (index) {
        ModelWithGetxController<ChoiceChipModel> item = _.deviceSignList[index];
        return DeviceSignWidget(tag: 'PMesDevice-${item.model.keyName}');
      }).toList(),
    );
  }

  Widget deviceTaskList(BuildContext context, DeviceController _){
    return Container(
      padding: const EdgeInsets.all(4),
      child: GridView.builder(
        shrinkWrap: false,
        semanticChildCount: 0,
        addAutomaticKeepAlives: true,
        controller: _.deviceTaskController,
        padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 42),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 370,
          childAspectRatio: _.itemAspectRatio,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: _.deviceTaskFilterList.length,
        itemBuilder: (BuildContext context, int index){
          ModelWithGetxController<MoDeviceTaskModel> item = _.deviceTaskFilterList[index];
          return DeviceItem(tag: 'PMesDevice-${item.model.deviceId ?? ''}');
        }
      ),
    );
  }

}