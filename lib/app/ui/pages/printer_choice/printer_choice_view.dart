
import 'package:desktop/app/ui/pages/printer_choice/printer_choice_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

///打印机选择 弹窗窗体
class PrintChoiceView extends BaseDialogPage<PrintChoiceController>{
  const PrintChoiceView({super.key});

  Widget contentWidget(BuildContext context, PrintChoiceController _) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        interactive: false,
        thumbVisibility: WidgetStateProperty.all(false),
        trackVisibility: WidgetStateProperty.all(false),
        thumbColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: ListView(
        controller: _.scrollController,
        children: List.generate(_.printerList.length, (index) {
          Printer printer = _.printerList[index];
          return Material(
            child: RadioListTile(
              title: Text(
                printer.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              controlAffinity: ListTileControlAffinity.trailing,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              value: printer.url,
              groupValue: _.printerUrl,
              onChanged: (String? int){
                controller.printerOnChanged(printer);
              },
            ),
          );
        }).toList(),
      ),
    );
    return Column(
      children: [
        Material(
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            value: _.usePrinterSettings,
            onChanged: (bool? bool) {
              controller.usePrinterSettingsOnChanged();
            },
            title: Text(
              '使用打印机定义的配置',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        Expanded(
          child: ScrollbarTheme(
            data: ScrollbarThemeData(
              interactive: false,
              thumbVisibility: WidgetStateProperty.all(false),
              trackVisibility: WidgetStateProperty.all(false),
              thumbColor: WidgetStateProperty.all(Colors.transparent),
              trackColor: WidgetStateProperty.all(Colors.transparent),
            ),
            child: ListView(
              controller: _.scrollController,
              children: List.generate(_.printerList.length, (index) {
                Printer printer = _.printerList[index];
                return Material(
                  child: RadioListTile(
                    title: Text(
                      printer.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    value: printer.url,
                    groupValue: _.printerUrl,
                    onChanged: (String? int){
                      controller.printerOnChanged(printer);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }


}