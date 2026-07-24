import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/shutdown_record/process_type_edit_form/shutdown_record_process_type_form_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///停机原因编辑窗体 670003
class ShutdownRecordProcessTypeFormPage extends BaseFormPage<ShutdownRecordProcessTypeFormController> {

  @override
  Widget contentWidget(BuildContext context, ShutdownRecordProcessTypeFormController _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              TextButton(
                onPressed: () async {
                  await controller.descOnChanged();
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.symmetric(vertical: 18, horizontal: 12)
                          : const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '备注：${_.desc ?? ''}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(width: 4,),
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16,),
              PickerButtonWidget(
                adapter: _.personAdapter,
                pickerChoiceType: PickerChoiceType.chip,
                pickerButtonType: PickerButtonType.text,
                onTap: (List<PickerDataModel> selectList) async{
                  if (selectList.isNotEmpty){
                    await controller.psnOnChanged(selectList[0]);
                  }
                  else {
                    await controller.psnOnChanged(PickerDataModel());
                  }
                },
                buttonStyle: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.symmetric(vertical: 18, horizontal: 12)
                          : const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '操作人：${_.operatorName ?? ''}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4,),
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16,),


              Expanded(child: SizedBox.shrink()),

              MineIconButton(
                onPressed: (){
                  if (_.isExpandedList.contains(false)){
                    for (int index = 0; index < _.isExpandedList.length; index ++){
                      _.isExpandedList[index] = true;
                    }
                  }
                  else {
                    for (int index = 0; index < _.isExpandedList.length; index ++){
                      _.isExpandedList[index] = false;;
                    }
                  }
                  controller.update();
                },
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.all(6),
                tooltip: _.isExpandedList.contains(false) ? '全部展开' : '全部收起',
                icon: Icons.expand,
                iconSize: Theme.of(context).textTheme.titleMedium!.fontSize! * 1.43,
              ),
            ],
          )
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
            child: SingleChildScrollView(
              child: SizedBox(
                width: 2000,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  runSpacing: 18, spacing: 18,
                  children: List.generate(_.processTypeClassList.length, (index){
                    return processTypeClassItem(
                      context, _,
                      classIndex: index,
                      classItem: _.processTypeClassList[index],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12,),
      ],
    );
  }

  Widget processTypeClassItem(BuildContext context, ShutdownRecordProcessTypeFormController _, {
    required int classIndex,
    required TreeViewModel classItem,
  }){
    return Container(
      width: _.expansionPanelWidth,
      child: ExpansionPanelList(
        dividerColor: AppColors.transparentColor,
        expandedHeaderPadding: const EdgeInsets.only(),
        expansionCallback: (int index, bool boolValue){
          _.isExpandedList[classIndex] = boolValue;
          controller.update();
        },
        children: [
          ExpansionPanel(
            isExpanded: _.isExpandedList[classIndex],
            canTapOnHeader: true,
            backgroundColor: Color.fromARGB(
              Theme.of(context).colorScheme.onInverseSurface.alpha,
              (Theme.of(context).colorScheme.onInverseSurface.red * 0.96).toInt(),
              (Theme.of(context).colorScheme.onInverseSurface.green * 0.96).toInt(),
              (Theme.of(context).colorScheme.onInverseSurface.blue * 0.96).toInt(),
            ),
            headerBuilder: (BuildContext context, bool isExpanded){
              return Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${classItem.text}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
            body: Container(
              height: _.expansionPanelHeight,
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: ScrollbarTheme(
                data: ScrollbarThemeData(),
                child: ListView(
                  children: List.generate((_.processTypeTreeListMap[classItem.value] ?? []).length, (index){
                    DataItemEntity item = (_.processTypeTreeListMap[classItem.value] ?? [])[index];
                    return Material(
                      color: Colors.transparent,
                      child: RadioListTile<String?>(
                        contentPadding: kIsWeb || GetPlatform.isWindows
                            ? const EdgeInsets.symmetric(vertical: 8, horizontal: 8)
                            : const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        tileColor: item.itemValue == _.processType
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        value: item.itemValue,
                        groupValue: _.processType,
                        onChanged: (String? value) async {
                          await controller.processTypeOnChanged(value);
                        },
                        title: Text(
                          item.itemName ?? '',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: item.itemValue == _.processType
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : null
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}