import 'package:basement/model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dialog/device/er_device_dialog_controller.dart';
import 'dialog/device/er_device_dialog_page.dart';
import 'dialog/mould/er_mould_dialog_controller.dart';
import 'dialog/mould/er_mould_dialog_page.dart';
import 'dialog/product/er_product_dialog_controller.dart';
import 'dialog/product/er_product_dialog_page.dart';
import 'exception_report_controller.dart';

///工作流程-异常报告——主界面
class ExceptionReportPage extends BaseFormPage<ExceptionReportController> {

  @override
  Widget contentWidget(BuildContext context, ExceptionReportController _) {
    return Column(
      children: [
        const SizedBox(
          height: 4,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 8),
              child: const BackOutlinedButton(),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  '异常报告',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 250,),
          ],
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            child: GridView.builder(
                shrinkWrap: false,
                semanticChildCount: 0,
                addAutomaticKeepAlives: true,
                controller: _.schemeInfoListScrollController,
                padding: const EdgeInsets.only(
                    left: 2, top: 2, bottom: 2, right: 42),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  childAspectRatio: 1,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _.schemeInfoList.length,
                itemBuilder: (BuildContext context, int index) {
                  WfSchemeInfoModel item = _.schemeInfoList[index];
                  return itemWidget(context, _, item, index);
                }),
          ),
        )
      ],
    );
  }

  Widget itemWidget(BuildContext context, ExceptionReportController _, WfSchemeInfoModel item, int index) {
    return Material(
      elevation: 1,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: InkWell(
        onTap: () async {
          //region
          switch (item.progid) {
            case 700204: //模具问题(模具维修)
              var dialogRes = await DialogUtils.showCustomDialog<ERMouldDialogController, bool>(
                  Get.context!, title: '异常报告—模具问题',
                  barrierDismissible: false,
                  isMaximize: true,
                  contentPadding: const EdgeInsets.all(12),
                  content: ERMouldDialogPage(),
                  controller: ERMouldDialogController(deviceId: _.deviceId, wfSchemeInfo: item)
              );
              break;
            case 811010: //产品问题（次品）
              WfSchemeInfoModel model = WfSchemeInfoModel.fromJson(item.toJson());
              model.progid = 811015; ///异常报告提交的次品记录的 progid 改为 811015
              var dialogRes = await DialogUtils.showCustomDialog<ERProductDialogController, bool>(
                  Get.context!, title: '异常报告—产品问题',
                  barrierDismissible: false,
                  isMaximize: true,
                  contentPadding: const EdgeInsets.all(12),
                  content: ERProductDialogPage(),
                  controller: ERProductDialogController(deviceId: _.deviceId, wfSchemeInfo: item)
              );
              break;
            case 220016: //设备问题（设备维修）
              var dialogRes = await DialogUtils.showCustomDialog<ERDeviceDialogController, bool>(
                  Get.context!, title: '异常报告—设备问题',
                  barrierDismissible: false,
                  isMaximize: true,
                  contentPadding: const EdgeInsets.all(12),
                  content: ERDeviceDialogPage(),
                  controller: ERDeviceDialogController(deviceId: _.deviceId, wfSchemeInfo: item)
              );
              break;
            default:
              break;
          }
          //endregion
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: getIcon(context, progid: item.progid ?? 0, index: index),
            ),
            Text('${item.name ?? ''}', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12,)
          ],
        ),
      ),
    );
  }

  Widget getIcon(BuildContext context, {required int progid, required int index,}) {
    IconData iconData;
    switch (progid) {
      case 700204: //模具问题(模具维修)
        iconData = FluentIcons.developer_board_24_regular;
        break;
      case 811010: //产品问题（次品）
        iconData = Icons.production_quantity_limits;
        break;
      case 220016: //设备问题（设备维修）
        iconData = const IconData(0xe601, fontFamily: 'MineIconFont');
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(right: 40),
          child: Icon(
            iconData,
            color: AppColors.mainColorList[index],
            size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 5,
          ),
        );
      default:
        iconData = Icons.error;
        break;
    }
    return Center(
      child: Icon(
        iconData,
        color: AppColors.mainColorList[index],
        size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 5,
      ),
    );
  }
}
