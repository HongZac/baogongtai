import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/setting/quality_inspection_setting_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';

///质量巡检首页 设置页面
class QualityInspectionSettingPage extends BaseSettingPage<QualityInspectionSettingController>{

  @override
  List<Widget> tabPageView(BuildContext context, QualityInspectionSettingController _) {
    return [
      interfaceSettingWidget(context, _),
    ];
  }

  Widget interfaceSettingWidget(BuildContext context, QualityInspectionSettingController _){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(
                    '质量巡检-类型列表',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  children: List.generate(AppConfig.qualityInspectionCategoryList.length, (index){
                    ChoiceChipModel item = AppConfig.qualityInspectionCategoryList[index];
                    return CheckboxListTile(
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      value: _.showCategory & item.sign == item.sign,
                      onChanged: (bool? boolValue) {
                        controller.showCategoryOnChanged(boolValue!, item.sign);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.interfaceSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }
}