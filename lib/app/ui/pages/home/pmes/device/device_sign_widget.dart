import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///设备状态行 单个项的显示内容
class DeviceSignWidget extends StatelessWidget {

  final String tag;
  final DeviceController ctl = Get.find<DeviceController>();

  DeviceSignWidget({required this.tag}) : super(key: ValueKey(tag));

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ModelWithGetxController<ChoiceChipModel>>(tag: tag, builder: (item){
      return RawChip(
        selected: !ctl.unVisibleDeviceSignList.contains(item.model.sign),
        selectedColor: item.model.activeColor,
        disabledColor: Colors.white,
        showCheckmark: false,
        onSelected: (bool bool) async{
          await ctl.deviceSignOnChanged(item);
        },
        side: BorderSide(
          color: !ctl.unVisibleDeviceSignList.contains(item.model.sign)
              ? Colors.transparent
              : Theme.of(context).colorScheme.onSurface.withAlpha(76)
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4)
        ),
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: RichText(
            text: TextSpan(
              text: DataUtils.getNotConnectedZh(content: item.model.title, type: 1),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: !ctl.unVisibleDeviceSignList.contains(item.model.sign)
                    ? item.model.foreColor
                    : item.model.activeColor,
              ),
              children: [
                TextSpan(
                  text: item.model.content.isEmpty ? ' ' : item.model.content,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.5,
                  ),
                ),
                const TextSpan(text: ' 台'),
              ]
            ),
            textScaler: TextScaler.linear(FontFamilyConfig.textScale),
          )
        ),
      );
    });
  }

}