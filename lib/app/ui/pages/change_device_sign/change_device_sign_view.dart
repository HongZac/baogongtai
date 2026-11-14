import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/change_device_sign/change_device_sign_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/utils/sign_color_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/platform/platform.dart';


///修改设备状态
class ChangeDeviceSignView extends BaseDialogPage<ChangeDeviceSignController> {

  @override
  Widget contentWidget(BuildContext context, ChangeDeviceSignController _) {
    bool isTjz = _.selectedSign == DeviceSign.tjz.sign;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Wrap(
                runSpacing: 12, spacing: 12,
                children: List.generate(_.deviceSignList.length, (index){
                  DeviceSign item = _.deviceSignList[index];
                  bool isSelected = item.sign == _.selectedSign;
                  Color signColor = SignColorUtil().getDeviceSignColor(item.sign);
                  return FilterChip(
                    selected: isSelected,
                    selectedColor: signColor.withAlpha(255),
                    backgroundColor: signColor.withAlpha(40),
                    checkmarkColor: Colors.white,
                    onSelected: (bool bool) {
                      controller.deviceSignOnChanged(item);
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                    label: Text(
                      item.name.isNotEmpty ? item.name : ' ',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: isSelected ? Colors.white : signColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        if (isTjz)
          Positioned(
            bottom: 0,
            left: 0,
            child: TextButton(
              onPressed: () async {
                await controller.selectShutdownReason();
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    kIsWeb || GetPlatform.isWindows
                        ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8)
                        : const EdgeInsets.symmetric(vertical: 12, horizontal: 8)
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.3,
                  ),
                  Text(
                    _.shutdownReasonData == null
                        ? '停机原因选择'
                        : '停机原因：${_.shutdownReasonData!['ProcessTypeName'] ?? _.shutdownReasonData!['ProcessType'] ?? ''}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }

}
