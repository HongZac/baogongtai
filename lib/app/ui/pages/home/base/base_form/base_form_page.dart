import 'package:basement/model.dart';
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

///基本页
abstract class BaseFormPage<T extends BaseFormController> extends GetView {
  @override
  T get controller => Get.find<T>(tag: tag);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      builder: (_) {
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
          child: kIsWeb || GetPlatform.isWindows ?
          contentWidget(context, _) :
          ListView(
            key: _.contentWidgetKey,
            children: [
              if (_.contentWidgetSize != null)
                SizedBox(
                  height: _.contentWidgetSize?.height,
                  width: _.contentWidgetSize?.width,
                  child: contentWidget(context, _),
                ),
            ],
          ),
        );
      },
      tag: tag,
      initState: (GetBuilderState<T> state){
        MineGetDelegate().pageInitState(controller);
      },
      dispose: (GetBuilderState<T> state){
        try {
          MineGetDelegate().pageDispose(controller);
        } catch(e){}
      },
    );
  }

  Widget settingWidget(BuildContext context, T _, {double top = 0}){
    return MineIconButton(
      onPressed: () {
        controller.settingOnTap();
      },
      margin: EdgeInsets.only(top: top),
      tooltip: '设置',
      icon: Icons.settings,
      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
    );
  }

  Widget contentWidget(BuildContext context, T _) {
    return SizedBox.shrink();
  }

  @Deprecated('弃用')
  Widget infoItemm(BuildContext context, T _, {
    required String title,
    required String content,
    Color? contentColor,
    double width = 310,
    double titleWidth = 100,
    bool isBold = false,
    void Function()? onPress,
    ICloneable? item,
  }) {
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: width,
      titleWidth: titleWidth,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: contentColor,
        fontWeight: isBold ? FontWeight.w600 : null
      ),
      onPress: onPress,
    );
  }

  Widget dataReportItem(BuildContext context, T _, {
    required String title,
    required Widget customizeContent,
    bool needMargin = true,
    double width = 580,
    double titleWidth = 100,
  }) {
    return TitleTextBoxWidget(
      title: title,
      customizeContent: customizeContent,
      titleWidth: titleWidth,
      width: width,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
      margin: needMargin ? const EdgeInsets.only(bottom: 6) : null,
    );
  }

}
