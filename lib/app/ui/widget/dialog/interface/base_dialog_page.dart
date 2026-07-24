import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


abstract class BaseDialogPage<T extends BaseDialogController> extends GetView<T> {
  const BaseDialogPage({super.key});

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
          child: contentWidget(context, _),
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

  Widget contentWidget(BuildContext context, T _) {
    return SizedBox.shrink();
  }

}