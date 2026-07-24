import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/over_production_process/over_production_process_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';

///超产处理弹窗窗体
class OverProductionProcessView extends BaseDialogPage<OverProductionProcessController>{

  @override
  Widget contentWidget(BuildContext context, OverProductionProcessController _) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        itemWidget(
            context, _,
            title: '可超产百分比',
            content: TextField(
              focusNode: _.percentFN,
              controller: _.percentTC,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (String? string) async{
                _.qtyTC.text = (_.qty * (double.tryParse(_.percentTC.text) ?? 0) / 100).toString();
                controller.update();
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                suffixIcon: _.percentTC.text.isNotEmpty ? MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () {
                    _.percentTC.clear();
                    controller.update();
                  },
                ) :
                null,
              ),
            ),
            isNeedMargin: true
        ),
        itemWidget(
            context, _,
            title: '可超产数量',
            content: TextField(
              focusNode: _.qtyFN,
              controller: _.qtyTC,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (String? string) async{
                _.percentTC.text = ((double.tryParse(_.qtyTC.text) ?? 0) / _.qty * 100).toStringAsFixed(4);
                controller.update();
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                suffixIcon: _.qtyTC.text.isNotEmpty ?
                MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () {
                    _.qtyTC.clear();
                    controller.update();
                  },
                ) :
                null,
              ),
            ),
            isNeedMargin: true
        ),
        itemWidget(
            context, _,
            title: '备注',
            content: TextField(
              focusNode: _.descFN,
              controller: _.descTC,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (String? string) async{
                controller.update();
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                suffixIcon: _.descTC.text.isNotEmpty ?
                MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () {
                    _.descTC.clear();
                    controller.update();
                  },
                ) :
                null,
              ),
            ),
            isNeedMargin: true
        ),
        Container(
          width: 500,
          alignment: Alignment.centerLeft,
          child: Text(
            '可超产百分比和可超产数量选其一填写即可。',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: AppColors.errorColor
            ),
          ),
        )
      ],
    );
  }


  Widget itemWidget(BuildContext context, OverProductionProcessController _, {required String title, required Widget content, bool isNeedMargin = false}){
    return TitleTextBoxWidget(
      title: title,
      customizeContent: content,
      titleWidth: 120, width: 500,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
      margin: isNeedMargin ? const EdgeInsets.only(bottom: 8) : null,
    );
  }
}