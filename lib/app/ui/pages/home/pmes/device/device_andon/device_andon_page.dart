import 'package:basement/model.dart';
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_andon/device_andon_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_andon/dialog/default/da_default_dialog_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_andon/dialog/default/da_default_dialog_page.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



///工作流程-全场呼叫 主界面
class DeviceAndonPage extends GetView<DeviceAndonController>{
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeviceAndonController>(builder: (_){
      return Column(
        children: [
          const SizedBox(height: 4,),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 250,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: const BackOutlinedButton(),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    '全场呼叫',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 250,),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              child: GridView.builder(
                  shrinkWrap: false,
                  semanticChildCount: 0,
                  addAutomaticKeepAlives: true,
                  controller: _.schemeInfoListScrollController,
                  padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 42),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    childAspectRatio: 1,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: _.schemeInfoList.length,
                  itemBuilder: (BuildContext context, int index){
                    WfSchemeInfoModel item = _.schemeInfoList[index];
                    return itemWidget(context, _, item, index);
                  }
              ),
            ),
          )
        ],
      );
    }, initState: (GetBuilderState<DeviceAndonController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<DeviceAndonController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }

  Widget itemWidget(BuildContext context, DeviceAndonController _, WfSchemeInfoModel item, int index){
    return Material(
      elevation: 1,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: InkWell(
        onTap: () async{
          await DialogUtils.showCustomDialog<DADefaultDialogController, bool>(
            Get.context!, title: '全场呼叫—${item.name ?? ''}',
            barrierDismissible: false,
            isMaximize: true,
            contentPadding: const EdgeInsets.all(12),
            content: DADefaultDialogPage(),
            controller: DADefaultDialogController(deviceId: _.deviceId, wfSchemeInfo: item)
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Center(
                  child: Icon(
                    getIcon(item.progid ?? 0),
                    color: AppColors.mainColorList[index],
                    size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 5,
                  ),
                )
            ),
            Text(
                '${item.name ?? ''}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600
                )
            ),
            const SizedBox(height: 12,)
          ],
        ),
      ),
    );
  }

  IconData getIcon(int progid){
    IconData iconData;
    switch (progid){
      default:
        iconData = FluentIcons.call_outbound_48_filled;
        break;
    }
    return iconData;
  }

}