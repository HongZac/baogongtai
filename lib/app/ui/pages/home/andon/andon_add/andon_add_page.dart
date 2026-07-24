
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/andon/andon_add/andon_add_controller.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/widget/column_icon_title_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:flutter/material.dart';


///安灯系统 新增全场呼叫页面
class AndonAddPage extends BaseFormPage<AndonAddController>{


  @override
  Widget contentWidget(BuildContext context, AndonAddController _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            ColumnIconTitleWidget(
              title: '车间选择',
              iconData: Icons.factory_outlined, //warehouse_outlined,
            ),
            const SizedBox(width: 4,),
            PickerInputWidget(
              height: 60, width: 2000,
              adapter: _.departmentAdapter,
              onTap: (List<PickerDataModel> selectList) {
                if (selectList.isNotEmpty){
                  controller.depOnChanged(selectList[0]);
                }
                else {
                  controller.depOnChanged(PickerDataModel());
                }
              },
            ),

            Expanded(child: const SizedBox.shrink()),

            if (!_.isAndonClassListNoChild)
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
        ),
        const SizedBox(height: 18,),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: _.isAndonClassListNoChild
                ? Axis.horizontal
                : Axis.vertical,
            child: _.isAndonClassListNoChild ?
            _.andonClassChoiceList.isEmpty ?
            SizedBox() :
            Container(
              alignment: Alignment.center,
              child: Wrap(
                spacing: 18, runSpacing: 18,
                direction: Axis.vertical,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: List.generate(_.andonClassChoiceList[0].length, (index) {
                  MoAndonClassModel item = _.andonClassChoiceList[0][index];
                  return filterChip(context, _, item, index);
                }).toList(),
              ),
            ) :
            ExpansionPanelList(
              dividerColor: AppColors.transparentColor,
              expandedHeaderPadding: const EdgeInsets.only(),
              expansionCallback: (int index, bool boolValue){
                _.isExpandedList[index] = boolValue;
                controller.update();
              },
              children: List.generate(_.andonClassChoiceList.length, (index) {
                List<MoAndonClassModel> list = _.andonClassChoiceList[index];
                bool isExpanded = _.isExpandedList[index];
                return ExpansionPanel(
                    isExpanded: isExpanded,
                    canTapOnHeader: true,
                    backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '请选择第${NumFormatUtil.getChineseNumerals(index + 1)}级',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    },
                    body: Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(4)
                          )
                      ),
                      child: Wrap(
                        spacing: 18, runSpacing: 18,
                        children: List.generate(list.length, (index1) {
                          MoAndonClassModel item = list[index1];
                          return filterChip(context, _, item, index);
                        }).toList(),
                      ),
                    )
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 18,),
        Container(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8, runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                  onPressed: () async {
                    await controller.editExtraForm();
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                    ),
                  ),
                  child: Text(
                      '额外信息填写',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                      )
                  )
              ),

              if (((_.serviceKind ?? 0) & 1) == 1
                  || (_.andonServiceModel.mouldId ?? '').isNotEmpty)
                textChip(
                  context, _,
                  str: (_.andonServiceModel.mouldId ?? '').isEmpty
                      ? '请选择模具'
                      : _.andonServiceModel.mouldName!,
                ),

              if (((_.serviceKind ?? 0) & 2) == 2
                  || (_.andonServiceModel.deviceId ?? '').isNotEmpty)
                textChip(
                  context, _,
                  str: (_.andonServiceModel.deviceId ?? '').isEmpty
                      ? '请选择设备'
                      : _.andonServiceModel.deviceName!,
                ),

              if (((_.serviceKind ?? 0) & 4) == 4
                  || (_.andonServiceModel.invId ?? '').isNotEmpty)
                textChip(
                  context, _,
                  str: (_.andonServiceModel.invId ?? '').isEmpty
                      ? '请选择产品'
                      : _.andonServiceModel.invName!,
                ),

              if (_.showAffected == 1 || _.andonServiceModel.affected != null)
                textChip(
                  context, _,
                  str: _.andonServiceModel.affected == null
                      ? '请输入数量'
                      : '数量：${_.andonServiceModel.affected!.toString()}',
                ),

              if ((_.andonServiceModel.submitDescription ?? '').isNotEmpty)
                textChip(
                  context, _,
                  str: _.andonServiceModel.submitDescription!.toString(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget filterChip(BuildContext context, AndonAddController _, MoAndonClassModel item, int index){
    Widget textWidget = Text(
      item.className.isNotEmpty ? item.className : ' ',
      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
        color: item.isChoice
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
    return FilterChip(
      selected: item.isChoice,
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      side: BorderSide.none,
      onSelected: (bool boolValue) async{
        await controller.andonClassOnChanged(index, item);
      },
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      label: _.isAndonClassListNoChild ?
      Container(
        width: 300, height: 36,
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: textWidget,
        ),
      ) :
      textWidget,
    );
  }

  Widget textChip(BuildContext context, AndonAddController _,{
    required  String str,
    bool isErr = false,
  }){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isErr
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        border: Border.all(
            color: Colors.grey.withAlpha(76),
            width: 2
        ),
      ),
      child: Text(
        str,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: isErr
              ? Theme.of(context).colorScheme.onErrorContainer
              : Theme.of(context).colorScheme.onPrimaryContainer
        ),
      ),
    );
  }

}