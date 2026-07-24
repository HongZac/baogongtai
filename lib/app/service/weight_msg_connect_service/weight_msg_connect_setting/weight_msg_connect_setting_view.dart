import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_setting/weight_msg_connect_setting_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


@Deprecated('计划不再使用')
class WeightMsgConnectSettingView extends BaseDialogPage<WeightMsgConnectSettingController>{

  Widget contentWidget(BuildContext context, WeightMsgConnectSettingController _) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleTextBoxWidget(
            title: '主机号',
            customizeContent: TextField(
              focusNode: _.hostFocusNode,
              controller: _.hostCtl,
              maxLines: 1,
              style: Theme.of(Get.context!).textTheme.bodyLarge,
              onChanged: (String? string) async{
                controller.update();
              },
              decoration: InputDecoration(
                hintText: _.weightMsgConnectModel.host ?? '',
                hintStyle: Theme.of(Get.context!).inputDecorationTheme.hintStyle!.copyWith(
                    fontSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                suffixIcon: _.hostCtl.text.isNotEmpty ?
                MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () {
                    _.hostCtl.clear();
                    controller.update();
                  },
                ) :
                null,
              ),
            ),
            titleWidth: 70, width: 580,
            titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
            crossAxisAlignment: CrossAxisAlignment.center,
            margin: const EdgeInsets.only(bottom: 6),
          ),
          TitleTextBoxWidget(
            title: '端口号',
            customizeContent: TextField(
              focusNode: _.portFocusNode,
              controller: _.portCtl,
              maxLines: 1,
              style: Theme.of(Get.context!).textTheme.bodyLarge,
              onChanged: (String? string) async{
                controller.update();
              },
              decoration: InputDecoration(
                hintText: (_.weightMsgConnectModel.port).toString(),
                hintStyle: Theme.of(Get.context!).inputDecorationTheme.hintStyle!.copyWith(
                    fontSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                suffixIcon: _.portCtl.text.isNotEmpty ?
                MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () {
                    _.portCtl.clear();
                    controller.update();
                  },
                ) :
                null,
              ),
            ),
            titleWidth: 70, width: 580,
            titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
            crossAxisAlignment: CrossAxisAlignment.center,
            margin: const EdgeInsets.only(bottom: 6),
          ),
          TitleTextBoxWidget(
            title: '精度值',
            customizeContent: TextField(
              focusNode: _.accuracyFocusNode,
              controller: _.accuracyCtl,
              maxLines: 1,
              style: Theme.of(Get.context!).textTheme.bodyLarge,
              onChanged: (String? string) async{
                controller.update();
              },
              decoration: InputDecoration(
                hintText: (_.weightMsgConnectModel.accuracy).toString(),
                hintStyle: Theme.of(Get.context!).inputDecorationTheme.hintStyle!.copyWith(
                    fontSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                suffixIcon: _.accuracyCtl.text.isNotEmpty ?
                MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () {
                    _.accuracyCtl.clear();
                    controller.update();
                  },
                ) :
                null,
              ),
            ),
            titleWidth: 70, width: 580,
            titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
            crossAxisAlignment: CrossAxisAlignment.center,
            margin: const EdgeInsets.only(bottom: 6),
          ),
          TitleTextBoxWidget(
            title: '接收到的称重消息的顺序是反向的',
            customizeContent: Row(
              children: [
                Checkbox(
                  value: _.isWeightMsgReverseOrder,
                  onChanged: (bool? boolValue) {
                    controller.isWeightMsgReverseOrderOnChanged();
                  },
                )
              ],
            ),
            titleWidth: 270, width: 580,
            titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
            crossAxisAlignment: CrossAxisAlignment.center,
            margin: const EdgeInsets.only(bottom: 6, top: 6),
          ),
        ],
      ),
    );
  }


}