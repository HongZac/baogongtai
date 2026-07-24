import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/setting/mes_order_setting_controller.dart';
import 'package:flutter/material.dart';


///生产任务单 主页面 设置页面
class MesOrderSettingPage extends BaseSettingPage<MesOrderSettingController>{

  @override
  List<Widget> tabPageView(BuildContext context, MesOrderSettingController _) {
    return [
      signSettingWidget(context, _),
      depSettingWidget(context, _),
      dateSettingWidget(context, _),
      searchSettingWidget(context, _),
      infoFormSettingWidget(context, _),
      commandBarSettingWidget(context, _),
      uiSettingWidget(context, _),
    ];
  }

  ///状态标签设置
  Widget signSettingWidget(BuildContext context, MesOrderSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.isShowSignFilterWidget(context),
                  controller.isSignChipMultiWidget(context),
                  controller.orderSignChoiceWidget(context),
                ],
              ),
            )
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.signSettingSave();
          },
        ),
      ],
    );
  }

  ///车间过滤设置
  Widget depSettingWidget(BuildContext context, MesOrderSettingController _){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                controller.isShowDepPickerWidget(context),
                controller.depChoiceTileWidget(context),
              ],
            ),
          )
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.depSettingSave();
          },
        ),
      ],
    );
  }

  ///日期过滤设置
  Widget dateSettingWidget(BuildContext context, MesOrderSettingController _){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                controller.isShowDatePickerWidget(context),
                controller.datePickerEnumIndexChoiceWidget(context),
              ],
            ),
          )
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.dateSettingSave();
          },
        ),
      ],
    );
  }

  Widget searchSettingWidget(BuildContext context, MesOrderSettingController _){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                controller.isShowSearchInputBoxWidget(context),
                controller.orderSearchTypeIndexChoiceWidget(context),
              ],
            ),
          )
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.searchSettingSave();
          },
        ),
      ],
    );
  }

  Widget infoFormSettingWidget(BuildContext context, MesOrderSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.infoFormGroupSettingWidget(context, _.orderListInfoFormListMap),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.infoFormSettingSave();
          },
        ),
      ],
    );
  }

  Widget commandBarSettingWidget(BuildContext context, MesOrderSettingController _){
    ///背景色、按钮类型、是否显示
    return Column(
      children: [
        Expanded(
          child: controller.commandBarSettingWidget(context, _.orderCommandBarList),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.commandBarSettingSave();
          },
        ),
      ],
    );
  }

  Widget uiSettingWidget(BuildContext context, MesOrderSettingController _){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                controller.pageConfigRowsChoiceWidget(
                    context,
                    pageConfigRows: _.pageConfigRows,
                    pageConfigRowsOnChanged: (int index){
                      controller.pageConfigRowsOnChanged(index);
                    }
                ),
              ],
            ),
          )
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.uiSettingSave();
          },
        ),
      ],
    );
  }

}