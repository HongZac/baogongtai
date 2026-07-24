import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/tm/submit_barcode/frx_file_name_and_data_source_type_choice/frx_file_name_and_data_source_type_choice_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';


///打印模板文件选择
class FrxFileNameAndDataSourceTypeChoiceView extends BaseDialogPage<FrxFileNameAndDataSourceTypeChoiceController>{

  Widget contentWidget(BuildContext context, FrxFileNameAndDataSourceTypeChoiceController _) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        interactive: false,
        thumbVisibility: WidgetStateProperty.all(false),
        trackVisibility: WidgetStateProperty.all(false),
        thumbColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: SingleChildScrollView(
        controller: _.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '打印模板选择：',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            ...List.generate(_.frxFileNameList.length, (index) {
              ChoiceChipModel item = _.frxFileNameList[index];
              return Material(
                child: RadioListTile(
                  title: Text(
                    '${item.title}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  value: item.title,
                  groupValue: _.frxFileName,
                  onChanged: (String? str){
                    controller.frxFileNameOnChanged(item);
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 32,),

            if (_.printType == 'serverPrint')
              Text(
                '打印数据源类型选择：',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (_.printType == 'serverPrint')
              ...List.generate(AppConfig.dataSourceTypeTCList.length, (index) {
                ChoiceChipModel item = AppConfig.dataSourceTypeTCList[index];
                return Material(
                  child: RadioListTile(
                    title: Text(
                      '${item.title}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    value: item.keyName,
                    groupValue: _.dataSourceType,
                    onChanged: (String? str){
                      controller.dataSourceTypeOnChanged(item);
                    },
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

}