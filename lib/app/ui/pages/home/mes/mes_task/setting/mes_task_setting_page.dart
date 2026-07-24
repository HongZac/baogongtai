import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/setting/mes_task_setting_controller.dart';
import 'package:flutter/material.dart';


///派工单报工-设置页面
class MesTaskSettingPage extends BaseSettingPage<MesTaskSettingController>{

  @override
  List<Widget> tabPageView(BuildContext context, MesTaskSettingController _) {
    return [
      signSettingWidget(context, _),
      depSettingWidget(context, _),
      lineSettingWidget(context, _),
      dateSettingWidget(context, _),
      searchSettingWidget(context, _),
      infoFormSettingWidget(context, _),
      commandBarSettingWidget(context, _),
      uiSettingWidget(context, _),
    ];
  }


  ///状态标签设置
  Widget signSettingWidget(BuildContext context, MesTaskSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.isShowSignFilterWidget(context),
                  controller.isSignChipMultiWidget(context),
                  controller.taskSignChoiceWidget(context),
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
  Widget depSettingWidget(BuildContext context, MesTaskSettingController _){
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

  ///生产产线过滤设置
  Widget lineSettingWidget(BuildContext context, MesTaskSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.isShowLinePickerWidget(context),
                  controller.lineChoiceTileWidget(context),
                ],
              ),
            )
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.lineSettingSave();
          },
        ),
      ],
    );
  }

  ///日期过滤设置
  Widget dateSettingWidget(BuildContext context, MesTaskSettingController _){
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

  Widget searchSettingWidget(BuildContext context, MesTaskSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.isShowSearchInputBoxWidget(context),
                  controller.taskSearchTypeIndexChoiceWidget(context),
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

  Widget infoFormSettingWidget(BuildContext context, MesTaskSettingController _){
    return Column(
      children: [
        Expanded(
            child: controller.infoFormGroupSettingWidget(context, _.taskListInfoFormListMap),
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

  Widget commandBarSettingWidget(BuildContext context, MesTaskSettingController _){
    ///背景色、按钮类型、是否显示
    return Column(
      children: [
        Expanded(
            child: controller.commandBarSettingWidget(context, _.taskCommandBarList),
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

  Widget uiSettingWidget(BuildContext context, MesTaskSettingController _){
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