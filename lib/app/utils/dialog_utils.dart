
import 'package:context_menus/context_menus.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/ui/widget/draggable_dialog.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/utils/mine_context_menu_region_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DialogUtils {

  ///弹窗是否打开
  static bool get isDialogOpen => _dialogOpenNum > 0;
  ///打开的弹窗个数
  static int _dialogOpenNum = 0;

  ///打开的是内容弹窗，前一个页面禁止串口监听
  static bool get isCustomDialogOpen => _customDialogOpenNum > 0;
  ///打开的内容弹窗的个数
  static int _customDialogOpenNum = 0;

  static ButtonStyle dialogActionBtnStyle = kIsWeb || GetPlatform.isWindows ?
  ButtonStyle(
    padding: WidgetStateProperty.all(
      EdgeInsets.symmetric(horizontal: 24, vertical: 18)
    )
  ) :
  ButtonStyle(
    padding: WidgetStateProperty.all(
      EdgeInsets.symmetric(horizontal: 48, vertical: 12)
    ),
  );

  ///确认对话弹窗
  static Future<bool?> showConfirmationDialog(BuildContext context, {
    String? title,
    String? msg,
    Widget? contentWidget,
    AsyncCallback? onConfirm,
    AsyncCallback? onCancel,
    bool barrierDismissible = false,
  }){
    assert((msg != null && contentWidget == null) || (msg == null && contentWidget != null));
    bool isOpen = true; ///弹窗是否打开
    _dialogOpenNum ++;
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context){
        double extimateHeight = (msg?.length ?? 0) * 0.32;
        return ContextMenuOverlay( /// context_menus 自定义弹出框 + 样式
          cardBuilder: (BuildContext cardContext, children){
            return MineContextMenuRegionUtil.cardBuilderWidget(cardContext, children);
          },
          buttonStyle: MineContextMenuRegionUtil.contextMenuButtonStyle(context),
          child: AlertDialog(
            actionsPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            titlePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            contentPadding: EdgeInsets.zero,
            title: kIsWeb || GetPlatform.isWindows ?
            Row(
              children: [
                const SizedBox(width: 8,),
                Expanded(
                  child: Text(
                    title ?? 'app.ok'.tr,
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                ),
                MineIconButton(
                  onPressed: (){
                    Navigator.of(context).pop(false);
                    isOpen = false;
                  },
                )
              ],
            ) :
            Container(
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Center(
                    child: Text(
                      title ?? 'app.ok'.tr,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ),
                  Positioned(
                    child: MineIconButton(
                      onPressed: (){
                        Navigator.of(context).pop(false);
                        isOpen = false;
                      },
                    ),
                  ),
                ],
              ),
            ),
            content: contentWidget ?? Container(
              color: Theme.of(context).colorScheme.surface,
              constraints: BoxConstraints(
                minWidth: 400, maxWidth: Get.width * 0.8, minHeight: 25,
                maxHeight: extimateHeight < 130
                    ? 130
                    : extimateHeight > Get.height * 0.8
                    ? Get.height * 0.8
                    : extimateHeight,
              ),
              child: Column(
                children: [
                  if (kIsWeb || GetPlatform.isWindows)
                    Divider(
                      indent: 0, endIndent: 0,
                      color: Theme.of(context).dividerTheme.color!.withAlpha(102),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            size: 28,
                            color: AppColors.warnIconColor,
                          ),
                          const SizedBox(width: 16,),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                msg!,
                                maxLines: 100,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ],
                      )
                    )
                  ),
                  if (kIsWeb || GetPlatform.isWindows)
                    Divider(
                      indent: 0, endIndent: 0,
                      color: Theme.of(context).dividerTheme.color!.withAlpha(102),
                    ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                style: dialogActionBtnStyle,
                child: Text(
                  '确认',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                ),
                onPressed: () async {
                  if (onConfirm != null){
                    await onConfirm.call().then((value) {
                      if (isOpen){
                        Navigator.of(context).pop(true);
                        isOpen = false;
                      }
                    });
                  }
                  else {
                    if (isOpen){
                      Navigator.of(context).pop(true);
                      isOpen = false;
                    }
                  }
                },
              ),
              OutlinedButton(
                style: dialogActionBtnStyle,
                child: Text(
                  '取消',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                ),
                onPressed: () async {
                  if (onCancel != null){
                    await onCancel.call().then((value) {
                      if (isOpen){
                        Navigator.of(context).pop(false);
                        isOpen = false;
                      }
                    });
                  }
                  else {
                    if (isOpen){
                      Navigator.of(context).pop(false);
                      isOpen = false;
                    }
                  }
                },
              ),
            ],
          ),
        );
      }
    ).then((value) {
      _dialogOpenNum --;
      return value;
    });
  }

  ///提示弹窗
  static Future<bool?> showTipsDialog(BuildContext context, {
    String? msg,
    Widget? contentWidget,
    AsyncCallback? onConfirm,
    ToastType toastType = ToastType.warn,
    bool barrierDismissible = false,
  }){
    assert((msg != null && contentWidget == null) || (msg == null && contentWidget != null));
    bool isOpen = true; ///弹窗是否打开
    _dialogOpenNum ++;
    IconData iconData;
    Color iconColor;
    switch (toastType){
      case ToastType.info:
        iconData = Icons.info_outline;
        iconColor = AppColors.progressActiveBkgColor;
        break;
      case ToastType.error:
        iconData = Icons.info_outline;
        iconColor = AppColors.progressErrBkgColor;
        break;
      case ToastType.success:
        iconData = Icons.check_circle_outline;
        iconColor = AppColors.runColor;
        break;
      case ToastType.warn:
        iconData = Icons.warning_amber_rounded;
        iconColor = AppColors.warnIconColor;
        break;
    }
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context){
        double extimateHeight = (msg?.length ?? 0) * 0.32;
        return ContextMenuOverlay( /// context_menus 自定义弹出框 + 样式
          cardBuilder: (BuildContext cardContext, children){
            return MineContextMenuRegionUtil.cardBuilderWidget(cardContext, children);
          },
          buttonStyle: MineContextMenuRegionUtil.contextMenuButtonStyle(context),
          child: AlertDialog(
            actionsPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            contentPadding: EdgeInsets.zero,
            title: kIsWeb || GetPlatform.isWindows ?
            Row(
              children: [
                const SizedBox(width: 8,),
                Expanded(
                  child: Text(
                    '提示'.tr,
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                ),
                MineIconButton(
                  onPressed: (){
                    Navigator.of(context).pop(false);
                    isOpen = false;
                  },
                )
              ],
            ) :
            Container(
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Center(
                    child: Text(
                      '提示'.tr,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ),
                  Positioned(
                    child: MineIconButton(
                      onPressed: (){
                        Navigator.of(context).pop(false);
                        isOpen = false;
                      },
                    ),
                  ),
                ],
              ),
            ),
            content: contentWidget ?? Container(
              color: Theme.of(context).colorScheme.surface,
              constraints: BoxConstraints(
                minWidth: 400, maxWidth: Get.width * 0.8, minHeight: 25,
                maxHeight: extimateHeight < 130 ? 130 : extimateHeight > Get.height * 0.8 ? Get.height * 0.8 : extimateHeight,
              ),
              child: Column(
                children: [
                  if (kIsWeb || GetPlatform.isWindows)
                    Divider(
                      indent: 0, endIndent: 0,
                      color: Theme.of(context).dividerTheme.color!.withAlpha(102),
                    ),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              iconData,
                              size: 28,
                              color: iconColor,
                            ),
                            const SizedBox(width: 16,),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  msg!,
                                  maxLines: 100,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                  if (kIsWeb || GetPlatform.isWindows)
                    Divider(
                      indent: 0, endIndent: 0,
                      color: Theme.of(context).dividerTheme.color!.withAlpha(102),
                    ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                style: dialogActionBtnStyle,
                child: Text(
                  '关闭',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                ),
                onPressed: () async {
                  if (onConfirm != null){
                    await onConfirm.call().then((value) {
                      if (isOpen){
                        Navigator.of(context).pop(true);
                        isOpen = false;
                      }
                    });
                  }
                  else {
                    if (isOpen){
                      Navigator.of(context).pop(true);
                      isOpen = false;
                    }
                  }
                },
              ),
            ],
          )
        );
      }
    ).then((value) {
      _dialogOpenNum --;
      return value;
    });
  }


  ///内容弹窗（成功返回 true, 失败或取消返回 false）
  static Future<DialogReturnDataType?> showCustomDialog<T, DialogReturnDataType>(BuildContext context, {
    T? controller, String? tag,
    required Widget content, EdgeInsets? contentPadding, required String title,
    double? initialWidth, double? initialHeight, bool isMaximize = false,
    bool barrierDismissible = false, bool isNeedConfirmBtn = true,
    String onConfirmName = '提交', AsyncValueGetter<DialogReturnDataModel>? onConfirm,
    String onCancelName = '取消', AsyncValueGetter<DialogReturnDataModel>? onCancel,
    String? button1Name, AsyncValueGetter<DialogReturnDataModel>? button1onPressed,
    List<Widget> titleBarWidgetList = const [],
  }) {
    bool isOpen = true; ///弹窗是否打开
    _dialogOpenNum ++;
    _customDialogOpenNum ++;
    bool isLoading = false; ///是否正在提交数据
    if (controller != null){
      Get.put<T>(controller, tag: tag);
    }
    return showDialog<DialogReturnDataType?>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext){
        Widget child = ContextMenuOverlay( /// context_menus 自定义弹出框 + 样式
          cardBuilder: (BuildContext cardContext, children){
            return MineContextMenuRegionUtil.cardBuilderWidget(cardContext, children);
          },
          buttonStyle: MineContextMenuRegionUtil.contextMenuButtonStyle(context),
          child: DraggableDialog(
            caption: title,
            isMaximize: isMaximize,
            initialWidth: initialWidth,
            initialHeight: initialHeight,
            contentPadding: contentPadding,
            actionsPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            content: content,
            titleBarWidgetList: titleBarWidgetList,
            actions: [
              ///【确认】按钮
              if (isNeedConfirmBtn)
                FilledButton(
                  style: dialogActionBtnStyle,
                  child: Text(
                    onConfirmName,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    ),
                  ),
                  onPressed: () async {
                    if (isLoading) {
                      ToastNotification(Get.overlayContext!).warn('正在执行！');
                      return;
                    }
                    isLoading = true;
                    if (content is BaseFormPage){
                      await content.controller.dialogActionPressed(DialogButtonActionEnum.confirm).then((value){
                        if (value.isCanCloseDialog && isOpen){
                          Navigator.of(dialogContext).pop(value.data);
                        }
                        isLoading = false;
                      });
                    }
                    else if (content is BaseDialogPage){
                      await content.controller.dialogActionPressed(DialogButtonActionEnum.confirm).then((value){
                        if (value.isCanCloseDialog && isOpen){
                          Navigator.of(dialogContext).pop(value.data);
                        }
                        isLoading = false;
                      });
                    }
                    else if (onConfirm != null){
                      await onConfirm.call().then((value){
                        if (value.isCanCloseDialog && isOpen){
                          Navigator.of(dialogContext).pop(value.data);
                        }
                        isLoading = false;
                      });
                    }
                    else {
                      Navigator.of(dialogContext).pop();
                      isLoading = false;
                    }
                  },
                ),
              if (isNeedConfirmBtn || button1Name != null)
                OutlinedButton(
                  style: dialogActionBtnStyle,
                  child: Text(
                    onCancelName,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    ),
                  ),
                  onPressed: () async {
                    if (isLoading) {
                      ToastNotification(Get.overlayContext!).warn('正在执行！');
                      return;
                    }
                    isLoading = true;
                    if (content is BaseFormPage){
                      await content.controller.dialogActionPressed(DialogButtonActionEnum.cancel).then((value){
                        if (value.isCanCloseDialog && isOpen){
                          Navigator.of(dialogContext).pop(value.data);
                        }
                        isLoading = false;
                      });
                    }
                    else if (content is BaseDialogPage){
                      await content.controller.dialogActionPressed(DialogButtonActionEnum.cancel).then((value){
                        if (value.isCanCloseDialog && isOpen){
                          Navigator.of(dialogContext).pop(value.data);
                        }
                        isLoading = false;
                      });
                    }
                    else if (onCancel != null){
                      await onCancel.call().then((value) {
                        if (value.isCanCloseDialog && isOpen){
                          Navigator.of(dialogContext).pop(value.data);
                        }
                        isLoading = false;
                      });
                    }
                    else {
                      Navigator.of(dialogContext).pop();
                      isLoading = false;
                    }
                  },
                ),
              if (button1Name != null)
                OutlinedButton(
                  style: dialogActionBtnStyle,
                  child: Text(
                    button1Name,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    ),
                  ),
                  onPressed: () async {
                    if (isLoading) {
                      ToastNotification(Get.overlayContext!).warn('正在执行！');
                      return;
                    }
                    isLoading = true;
                    if (content is BaseFormPage){
                      await content.controller.dialogActionPressed(DialogButtonActionEnum.button1).then((value){
                        if (value.isCanCloseDialog && isOpen){
                          Navigator.of(dialogContext).pop(value.data);
                        }
                        isLoading = false;
                      });
                    }
                    else if (content is BaseDialogPage){
                      await content.controller.dialogActionPressed(DialogButtonActionEnum.button1).then((value){
                        if (value.isCanCloseDialog && isOpen){
                          Navigator.of(dialogContext).pop(value.data);
                        }
                        isLoading = false;
                      });
                    }
                    else if (button1onPressed != null){
                      await button1onPressed.call().then((value) {
                        if (value.isCanCloseDialog && isOpen){
                          Navigator.of(dialogContext).pop(value.data);
                        }
                        isLoading = false;
                      });
                    }
                    else {
                      Navigator.of(dialogContext).pop();
                      isLoading = false;
                    }
                  }
                )
            ],
          )
        );

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (GetPlatform.isAndroid){
              ///点击空白关闭软键盘
              FocusManager.instance.primaryFocus?.unfocus();
              ///全屏，关闭状态栏
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
            }
          },
          child: child,
        );
      }
    ).then((value) async{
      ///弹窗关闭后执行（可能会出现提交数据返回前，已经关闭弹窗的情况）
      if (controller != null){
        Get.delete<T>(force: true);
      }
      isOpen = false;
      _dialogOpenNum --;
      _customDialogOpenNum --;
      return value;
    });
  }

}