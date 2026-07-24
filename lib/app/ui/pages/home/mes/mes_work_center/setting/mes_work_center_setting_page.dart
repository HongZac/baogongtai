import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/setting/mes_work_center_setting_controller.dart';
import 'package:flutter/material.dart';


///生产 加工中心（可选择派工单报工 OR 任务单报工） - 参数设置
class MesWorkCenterSettingPage extends BaseSettingPage<MesWorkCenterSettingController> {

  @override
  List<Widget> tabPageView(BuildContext context, MesWorkCenterSettingController _) {
    return [
      depSettingWidget(context, _),
      workCenterSettingWidget(context, _),
      categorySettingWidget(context, _),
      signSettingWidget(context, _),
      dateSettingWidget(context, _),
      searchSettingWidget(context, _),
      orderInfoFormSettingWidget(context, _),
      taskFormSettingWidget(context, _),
      orderCommandBarSettingWidget(context, _),
      taskCommandBarSettingWidget(context, _),
      uiSettingWidget(context, _),
    ];
  }

  ///车间筛选
  Widget depSettingWidget(BuildContext context, MesWorkCenterSettingController _){
    return Column(
      children: [
        Expanded(
            child: controller.depChoiceListWidget(context)
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

  ///加工中心筛选
  Widget workCenterSettingWidget(BuildContext context, MesWorkCenterSettingController _){
    return Column(
      children: [
        Expanded(
            child: controller.workCenterChoiceListWidget(context)
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.workCenterSettingSave();
          },
        ),
      ],
    );
  }

  Widget categorySettingWidget(BuildContext context, MesWorkCenterSettingController _){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  value: _.isShowCategory,
                  onChanged: (bool? bool) {
                    controller.isShowCategoryOnChanged();
                  },
                  title: Text(
                    '显示单据类型选择标签',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  title: Text(
                    '单据标签初始选中对象',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  children: List.generate(_.mesWorkCenterController.categoryList.length, (index){
                    MoSignModel item = _.mesWorkCenterController.categoryList[index];
                    return RadioListTile(
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      groupValue: item.sign,
                      value: _.selectedCategorySign,
                      onChanged: (int? index){
                        controller.selectedCategorySignOnChanged(item.sign);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.categorySettingSave();
          },
        ),
      ],
    );
  }

  Widget signSettingWidget(BuildContext context, MesWorkCenterSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.isShowSignFilterWidget(context),
                  controller.isSignChipMultiWidget(context),
                  /// OrderSignFilterInterface 的优先级最高，这里用 orderSignChoiceWidget
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

  Widget dateSettingWidget(BuildContext context, MesWorkCenterSettingController _){
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

  Widget searchSettingWidget(BuildContext context, MesWorkCenterSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.isShowSearchInputBoxWidget(context),
                  controller.orderSearchTypeIndexChoiceWidget(context, title: '搜索方式-任务单'),
                  controller.taskSearchTypeIndexChoiceWidget(context, title: '搜索方式-派工单'),
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

  Widget orderInfoFormSettingWidget(BuildContext context, MesWorkCenterSettingController _){
    return Column(
      children: [
        Expanded(
            child: controller.infoFormGroupSettingWidget(context, _.orderListInfoFormListMap),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.orderInfoFormSettingSave();
          },
        ),
      ],
    );
  }

  Widget taskFormSettingWidget(BuildContext context, MesWorkCenterSettingController _){
    return Column(
      children: [
        Expanded(
            child: controller.infoFormGroupSettingWidget(context, _.taskListInfoFormListMap),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.taskInfoFormSettingSave();
          },
        ),
      ],
    );
  }

  Widget orderCommandBarSettingWidget(BuildContext context, MesWorkCenterSettingController _){
    ///背景色、按钮类型、是否显示
    return Column(
      children: [
        Expanded(
            child: controller.commandBarSettingWidget(context, _.orderCommandBarList),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.orderCommandBarSettingSave();
          },
        ),
      ],
    );
  }

  Widget taskCommandBarSettingWidget(BuildContext context, MesWorkCenterSettingController _){
    ///背景色、按钮类型、是否显示
    return Column(
      children: [
        Expanded(
            child: controller.commandBarSettingWidget(context, _.taskCommandBarList),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.taskCommandBarSettingSave();
          },
        ),
      ],
    );
  }

  Widget uiSettingWidget(BuildContext context, MesWorkCenterSettingController _){
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