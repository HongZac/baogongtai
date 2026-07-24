import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/on_off_person/on_off_person_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';


///员工上下岗
class OnOffPersonView extends BaseFormPage<OnOffPersonController> {

  Widget contentWidget(BuildContext context, OnOffPersonController _) {
    final double titleWidth = 150;
    final double contentWidth = 350;
    return Column(
      children: [
        if (_.theLastPersonPostData == null || !_.isCurrentDate)

          Row(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: titleWidth,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '请刷员工卡或扫码：',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: contentWidth,
                    child: TextField(
                      controller: _.scanTC,
                      focusNode: _.scanFN,
                      maxLines: 1,
                      showCursor: true,
                      autofocus: true,
                      keyboardType: TextInputType.none,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        suffixIcon: MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () async{
                            _.scanTC.clear();
                            controller.update();
                          },
                        ),
                      ),
                      onSubmitted: (String value) async {
                        await controller.onSubmitted();
                      },
                    ),
                  ),
                ],
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '或',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '选择员工：',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  PickerButtonWidget(
                    pickerButtonType: PickerButtonType.text,
                    child:  Icon(
                      Icons.library_books_sharp,
                      color: Theme.of(context).colorScheme.primary,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    ),
                    buttonStyle: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                          horizontal: 2, vertical: 8
                      )),
                    ),
                    adapter: _.personAdapter,
                    pickerChoiceType: PickerChoiceType.chip,
                    onTap: (List<PickerDataModel> selectList) async {
                      controller.psnOnChanged(selectList);
                    },
                    isNeedLoadStr: false,
                  ),
                ],
              ),
            ],
          ),
        if (_.theLastPersonPostData == null || !_.isCurrentDate)
          Row(
            children: [
              SizedBox(width: titleWidth,),
              SizedBox(
                width: contentWidth,
                child: Text(
                    '请将输入法切换成英文模式后在进行扫码！',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.errorTextColor,
                    ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),
            ],
          ),

        if (_.theLastPersonPostData == null || !_.isCurrentDate)
          SizedBox(height: 16,),
        if (_.theLastPersonPostData == null || !_.isCurrentDate)
          Divider(indent: 0, endIndent: 0),
        if (_.theLastPersonPostData == null || !_.isCurrentDate)
          SizedBox(height: 16,),

        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_.theLastPersonPostData != null)
                  Text(
                    '有未下岗员工：'
                        '${_.theLastPersonPostData!.processUser ?? ''}'
                        '（上岗时间：${DateUtil.getDateStrByDateTime(_.theLastPersonPostData!.startDate)}）',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (_.isCurrentDate)
                  Text(
                    '今日已有员工上岗，请先下岗!',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (_.theLastPersonPostData != null)
                  const SizedBox(height: 16,),

                Row(
                  children: [
                    Material(
                      child: InkWell(
                        onTap: _.isCurrentDate ? null : (){
                          controller.onOffTypeOnChanged(0);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioTheme(
                                data: RadioThemeData(
                                  splashRadius: 0,
                                ),
                                child: Radio(
                                    value: 0,
                                    groupValue: _.onOffType,
                                    onChanged: _.isCurrentDate ? null : (value){
                                      controller.onOffTypeOnChanged(0);
                                    }
                                )
                            ),
                            Text(
                                '上岗',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _.isCurrentDate
                                      ? Theme.of(context).colorScheme.outline
                                      : null,
                                ), maxLines: 1, overflow: TextOverflow.ellipsis
                            ),
                            const SizedBox(width: 6,),
                          ],
                        ),
                      ),
                    ),
                    Material(
                      child: InkWell(
                        onTap: _.isCurrentDate ? null : (){
                          controller.onOffTypeOnChanged(1);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioTheme(
                                data: RadioThemeData(
                                  splashRadius: 0,
                                ),
                                child: Radio(
                                    value: 1,
                                    groupValue: _.onOffType,
                                    onChanged: _.isCurrentDate ? null : (value){
                                      controller.onOffTypeOnChanged(1);
                                    }
                                )
                            ),
                            Text(
                                '下岗',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _.isCurrentDate
                                      ? Theme.of(context).colorScheme.outline
                                      : null,
                                ), maxLines: 1, overflow: TextOverflow.ellipsis
                            ),
                            const SizedBox(width: 6,),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16,),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      runSpacing: 8, spacing: 8,
                      children: _.psnList.map((e){
                        return RawChip(
                          label: Text(
                            e.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          onDeleted: _.isCurrentDate ? null : (){
                            controller.psnListOnDeleted(e.id);
                          },
                          deleteIcon: Icon(
                            FluentIcons.delete_16_filled,
                            color: Theme.of(context).colorScheme.outline,
                            size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          ),
                          deleteButtonTooltipMessage: '删除',
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            )
        ),
      ],
    );
  }

}