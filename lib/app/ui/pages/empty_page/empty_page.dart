import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'empty_controller.dart';


///未完成功能的空页面(提示窗体)
class EmptyPage extends GetView<EmptyController> {

  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmptyController>(builder: (_){
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_.isShowBackButton)
            const BackOutlinedButton(),

          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                  '${_.progId}${_.progId.isEmpty ? '' : '，'}功能未实现！'
              ),
            ),
          )
        ],
      );
    }, initState: (GetBuilderState<EmptyController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<EmptyController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }

}