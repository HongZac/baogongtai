import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_page.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/setting/inv_barcode_setting_controller.dart';
import 'package:flutter/material.dart';


///物料条码新增查看 设置页面
class InvBarcodeSettingPage extends BaseSettingPage<InvBarcodeSettingController> {

  @override
  List<Widget> tabPageView(BuildContext context, InvBarcodeSettingController _) {
    return [
      searchSettingWidget(context, _),
      infoFormSettingWidget(context, _),
      uiSettingWidget(context, _),
    ];
  }

  Widget searchSettingWidget(BuildContext context, InvBarcodeSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.isShowSearchInputBoxWidget(context),
                  controller.inventorySearchTypeIndexChoiceWidget(context),
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

  Widget infoFormSettingWidget(BuildContext context, InvBarcodeSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.infoFormGroupSettingWidget(context, _.invBarcodeListInfoFormListMap),
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

  Widget uiSettingWidget(BuildContext context, InvBarcodeSettingController _){
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