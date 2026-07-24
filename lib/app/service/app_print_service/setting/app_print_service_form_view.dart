import 'package:desktop/app/service/app_print_service/setting/app_print_service_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';

import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

///APP 远程打印服务 参数修改页面
class AppPrintServiceFormView extends BaseDialogPage<AppPrintServiceFormController> {

  Widget contentWidget(BuildContext context, AppPrintServiceFormController _) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleTextBoxWidget(
          title: '工作台名称（唯一性）',
          customizeContent: TextField(
            focusNode: _.workBenchFN,
            controller: _.workBenchTC,
            maxLines: 1,
            style: Theme.of(Get.context!).textTheme.bodyLarge,
            onChanged: (String? string) async{
              controller.update();
            },
            decoration: InputDecoration(
              hintText: _.oldWorkBench,
              hintStyle: Theme.of(Get.context!).inputDecorationTheme.hintStyle!.copyWith(
                  fontSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
              suffixIcon: _.workBenchTC.text.isNotEmpty ? MineIconButton(
                icon: Icons.cancel,
                iconSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43,
                tooltip: '清空',
                onPressed: () {
                  _.workBenchTC.clear();
                  controller.update();
                },
              ) :
              null,
            ),
          ),
          titleWidth: 100, width: 580,
          titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          margin: const EdgeInsets.only(bottom: 18),
        ),

        if (!kIsWeb && GetPlatform.isWindows)
          ...[
            Row(
              children: [
                Text(
                  '打印机名称：',
                  style: Theme.of(Get.context!).textTheme.bodyLarge,
                )
              ],
            ),
            Expanded(
              child: ListView(
                children: List.generate(_.printerList.length, (index) {
                  Printer printer = _.printerList[index];
                  return Material(
                    child: InkWell(
                      onTap: (){
                        controller.printerChanged(printer);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              _.printerName == printer.url
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: _.printerName == printer.url
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).disabledColor,
                              size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                            ),
                            const SizedBox(width: 8,),
                            Expanded(
                              child: Text(
                                printer.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          ]
        else
          TitleTextBoxWidget(
            title: '打印机名称',
            customizeContent: TextField(
              focusNode: _.printerNameFN,
              controller: _.printerNameTC,
              maxLines: 1,
              style: Theme.of(Get.context!).textTheme.bodyLarge,
              onChanged: (String? string) async{
                controller.update();
              },
              decoration: InputDecoration(
                hintText: _.oldPrinterName,
                hintStyle: Theme.of(Get.context!).inputDecorationTheme.hintStyle!.copyWith(
                    fontSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                suffixIcon: _.printerNameTC.text.isNotEmpty ? MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () {
                    _.printerNameTC.clear();
                    controller.update();
                  },
                ) :
                null,
              ),
            ),
            titleWidth: 100, width: 580,
            titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            margin: const EdgeInsets.only(bottom: 18),
          ),
      ],
    );
  }

}