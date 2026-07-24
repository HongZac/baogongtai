import 'package:basement/picker.dart';
import 'package:desktop/app/ui/pages/home/andon/andon_add/extra_form/andon_add_extra_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/widget/column_icon_title_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class AndonAddExtraFormPage extends BaseFormPage<AndonAddExtraFormController> {

  @override
  Widget contentWidget(BuildContext context, AndonAddExtraFormController _) {
    return ListView(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.primaryContainer,
                border: Border.all(
                    color: Colors.grey.withAlpha(76),
                    width: 2
                ),
              ),
              child: Text(
                _.andonClassSelectedTitle.isNotEmpty
                    ? _.andonClassSelectedTitle
                    : '请选择呼叫类型',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12,),

        if (((_.serviceKind ?? 0) & 1) == 1)
          ...[
            ColumnIconTitleWidget(
              title: '模具选择',
              iconData: Icons.developer_board, //FluentIcons.developer_board_16_regular,
            ),
            PickerInputWidget(
              height: 60, width: 2000,
              adapter: _.mouldAdapter,
              onTap: (List<PickerDataModel> selectList) {
                if (selectList.isNotEmpty){
                  controller.mouldOnChanged(selectList[0]);
                }
                else {
                  controller.mouldOnChanged(PickerDataModel());
                }
              },
            ),
            const SizedBox(height: 12,),
          ],

        if (((_.serviceKind ?? 0) & 2) == 2 && _.isShowDevicePicker)
          ...[
            ColumnIconTitleWidget(
              title: '设备选择',
              iconData: FluentIcons.device_eq_16_filled,
              //Icons.precision_manufacturing_outlined,
              //const IconData(0xe601, fontFamily: 'MineIconFont'),
              //FluentIcons.device_eq_16_filled,
            ),
            PickerInputWidget(
              height: 60, width: 2000,
              adapter: _.deviceAdapter,
              onTap: (List<PickerDataModel> selectList) {
                if (selectList.isNotEmpty){
                  controller.deviceOnChanged(selectList[0]);
                }
                else {
                  controller.deviceOnChanged(PickerDataModel());
                }
              },
            ),
            const SizedBox(height: 12,),
          ],

        if (((_.serviceKind ?? 0) & 4) == 4)
          ...[
            ColumnIconTitleWidget(
              title: '产品选择',
              iconData: Icons.inventory_2_outlined,
              //FluentIcons.production_20_regular,
            ),
            PickerInputWidget(
              height: 60, width: 2000,
              adapter: _.inventoryAdapter,
              onTap: (List<PickerDataModel> selectList) {
                if (selectList.isNotEmpty){
                  controller.inventoryOnChanged(selectList[0]);
                }
                else {
                  controller.inventoryOnChanged(PickerDataModel());
                }
              },
            ),
            const SizedBox(height: 12,),
          ],

        if (_.showAffected == 1)
          ...[
            ColumnIconTitleWidget(
              title: '数量',
              iconData: Icons.numbers,
            ),
            TextField(
              controller: _.qtyTC,
              focusNode: _.qtyFN,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: '请输入',
                hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                ),
                suffixIcon: _.qtyTC.text.isEmpty ? null : MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () {
                    _.qtyTC.text = '';
                    controller.update();
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
              ),
            ),
            const SizedBox(height: 12,),
          ],

        ColumnIconTitleWidget(
          title: '呼叫描述',
          iconData: Icons.description_outlined,
        ),
        TextField(
          controller: _.descTC,
          focusNode: _.descFN,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: '请输入',
            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
            ),
            suffixIcon: _.descTC.text.isEmpty ? null : MineIconButton(
              icon: Icons.cancel,
              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
              tooltip: '清空',
              onPressed: () {
                _.descTC.text = '';
                controller.update();
              },
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
          ),
        ),
      ],
    );
  }
}