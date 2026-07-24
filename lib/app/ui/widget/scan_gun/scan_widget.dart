import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ScanGunHelper {

  final AsyncValueSetter<String>? onBarcodeFunScanned;
  OverlayEntry? overlayEntry;

  bool isLoadOverlay = false;


  ScanGunHelper({
    this.onBarcodeFunScanned,
  });


  Future<void> showScanOverlay(BuildContext context) async {
    if (isLoadOverlay){
      return;
    }
    isLoadOverlay = true;
    Get.put<ScanGunListenerController>(ScanGunListenerController(
      scanGunViewOnClose: () async {
        overlayEntry?.remove(); ///收起下拉框
        Get.delete<ScanGunListenerController>(force: true);
      },
      onBarcodeFunScanned: (String str) async {
        await onBarcodeFunScanned?.call(str);
      }
    ), tag: null);
    overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(overlayEntry!);
    isLoadOverlay = false;
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (BuildContext context){
        return ScanGunListenerView();
      }
    );
  }

  Widget scanGunBtn(BuildContext context, {double? iconSize, Color? iconColor}){
    return MineIconButton(
      onPressed: () async {
        await showScanOverlay(context);
      },
      tooltip: '扫码监听',
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      iconSize: iconSize ?? Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
      iconColor: iconColor ?? Theme.of(context).textTheme.bodyLarge!.color,
      icon: Icons.qr_code_scanner,
    );
  }

}


class ScanGunListenerView extends BaseDialogPage<ScanGunListenerController> {

  const ScanGunListenerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScanGunListenerController>(builder: (_){
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () async {
                controller.scanGunViewOnClose?.call();
              },
              child: Container(
                color: Colors.transparent,
              ),
            )
          ),
          Positioned(
            top: _.offset.dy,
            left: _.offset.dx,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 95, width: 600,
                child: Draggable(
                  feedback: Container(
                    alignment: Alignment.center,
                    height: 95, width: 600,
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox.shrink(),
                  ),
                  onDraggableCanceled: (Velocity velocity, Offset offset) {
                    //_.offset = Offset(_.offset.dx + offset.dx, _.offset.dy + offset.dy);
                    _.offset = offset;
                    controller.update();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: contentWidget(context, _),
                  )
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget contentWidget(BuildContext context, ScanGunListenerController _){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _.scanTC,
                focusNode: _.scanFN,
                maxLines: 1,
                showCursor: true,
                autofocus: true,
                keyboardType: TextInputType.none,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: '请扫描条码……',
                  contentPadding: kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16)
                      : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  suffixIcon: MineIconButton(
                    icon: Icons.cancel,
                    iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    tooltip: '清空',
                    onPressed: () async{
                      _.scanTC.clear();
                      controller.update();
                    },
                  ),
                ),
                onSubmitted: (String value) async {
                  await controller.onSubmitted();
                },
              ),
            ),
            const SizedBox(width: 12,),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primaryContainer
                ),
                padding: WidgetStateProperty.all(
                    kIsWeb || GetPlatform.isWindows
                        ? const EdgeInsets.symmetric(vertical: 20, horizontal: 22)
                        : const EdgeInsets.symmetric(vertical: 12, horizontal: 22)
                ),
              ),
              child: Text(
                '关闭',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
              ),
              onPressed: () async {
                controller.scanGunViewOnClose?.call();
              },
            ),
          ],
        ),
        const SizedBox(height: 4,),
        Text(
          '请将输入法切换成英文模式后在进行扫码！',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.errorTextColor,
          ),
        ),
      ],
    );
  }

}

class ScanGunListenerController extends BaseDialogController {

  final FocusNode scanFN = FocusNode();
  final TextEditingController scanTC = TextEditingController();

  late Offset offset = Offset(
    (MediaQuery.of(Get.context!).size.width - 600) / 2,
    44
  );
  final AsyncCallback? scanGunViewOnClose;
  final AsyncValueSetter<String>? onBarcodeFunScanned;

  ScanGunListenerController({
    this.scanGunViewOnClose,
    this.onBarcodeFunScanned,
  });

  @override
  Future<void> onReady() async {
    super.onReady();
    scanFN.addListener(scanFNOnListen);
    FocusScope.of(Get.context!).requestFocus(scanFN);
  }

  void scanFNOnListen() {
    if (scanFN.hasFocus) {
      PrintUtil.printDebug('扫码监听：得到焦点');
    }
    else{
      PrintUtil.printDebug('扫码监听：失去焦点，正在重新获取焦点');
      FocusScope.of(Get.context!).requestFocus(scanFN);
    }
  }

  ///扫码完成后提交（扫码内容的最后一个字符一定是回车符）
  Future<void> onSubmitted() async {
    final String str = scanTC.text;
    scanTC.clear();
    await onBarcodeFunScanned?.call(str);
  }

  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async {
    if (actionName == DialogButtonActionEnum.confirm){
      return DialogReturnDataModel(isCanCloseDialog: true, data: scanTC.text);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }


  @override
  void onClose() {
    super.onClose();
    scanFN.removeListener(scanFNOnListen);
    scanFN.dispose();
    scanTC.dispose();
  }

}
