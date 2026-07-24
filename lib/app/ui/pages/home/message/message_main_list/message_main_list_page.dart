import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/command_bar.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'message_main_list_controller.dart';

///系统消息 —— 详细列表页面
class MessageMainListPage extends BaseFormWithPageDataPage<MessageMainListController, MsgReceiveModel>{

  @override
  Widget headWidget(BuildContext context, MessageMainListController _) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            ///返回键
            Container(
              width: 90,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 8),
              child: const BackOutlinedButton(),
            ),
            const SizedBox(width: 4,),

            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints){
                  return Container(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                          width: kIsWeb || GetPlatform.isWindows
                              ? constraints.maxWidth < 210 ? constraints.maxWidth : 210
                              : constraints.maxWidth < 220 ? constraints.maxWidth : 220,
                          child: CommandBar(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
                            overflowItemBuilder: (void Function()? onPressed){
                              return CommandBarButton(
                                label: '',
                                icon: Icons.more_vert,
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                onPressed: onPressed,
                              );
                            },
                            primaryItems: _.commandBarList,
                          )
                      )
                  );
                },
              ),
            ),
            const SizedBox(width: 6,),

            dataReportItem1(
                title: '日期筛选',
                customizeContent: PrefixTextField(
                  object: 3, height: 50, readOnly: true,
                  contentPadding: kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                      : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  initText: _.startDate == null || _.endDate == null
                      ? ''
                      : '${DateUtil.formatDateTime(_.startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
                      '到'
                      '${DateUtil.formatDateTime(_.endDate.toString(), DateFormat.YEAR_MONTH_DAY)}',
                  valueOnChanged: (String string) async{
                    await controller.dateChanged(string);
                  },
                )
            ),
            const SizedBox(width: 6,),
          ],
        )
    );
  }

  @override
  Widget dataItem(BuildContext context, MessageMainListController _, MsgReceiveModel item){
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
            elevation: 1,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
                onTap: () async{
                  await controller.messageOnSelected(item);
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: item.isChoice,
                            onChanged: (bool? bool) async{
                              await controller.messageOnSelected(item);
                            },
                          ),
                          const SizedBox(width: 8,),
                          Text(
                            '${item.msSenderName ?? ''}',
                            style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w600
                            ), maxLines: 1,
                          ),
                          const SizedBox(width: 4,),

                          Text(
                            item.msChecked == 1 ? '' : '未读',
                            style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                              color: item.msChecked == 1 ? null : AppColors.errorColor,
                              fontWeight: FontWeight.w600
                            ), maxLines: 1,
                          ),
                          const SizedBox(width: 4,),

                          Text(
                            DateUtil.getDateStrByDateTime(item.msSendDate,
                                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? '',
                            style: Theme.of(Get.context!).textTheme.bodyLarge,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      SizedBox(height: 12,),
                      SelectableText(
                        '${item.subject ?? ''}',
                        onTap: () async{
                          await controller.messageOnSelected(item);
                        },
                        style: Theme.of(context).textTheme.bodyLarge
                      ),
                    ],
                  ),
                )
            )
        )
    );
  }

  Widget dataReportItem1({required String title, required Widget customizeContent}){
    return TitleTextBoxWidget(
      title: title,
      customizeContent: customizeContent,
      titleWidth: 100, width: 385,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }


}