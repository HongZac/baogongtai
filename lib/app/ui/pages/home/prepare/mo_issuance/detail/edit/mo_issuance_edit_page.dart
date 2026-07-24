import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/edit/mo_issuance_edit_controller.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/input_widget.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///发料单 报工（详情修改）页
class MoIssuanceEditPage extends BaseFormPage<MoIssuanceEditController> {

  @override
  Widget contentWidget(BuildContext context, MoIssuanceEditController _) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CardWidget(
            content: issuanceDetailWidget(context, _),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: editWidget(context, _),
          ),
        )
      ],
    );
  }

  Widget issuanceDetailWidget(BuildContext context, MoIssuanceEditController _) {
    return Container(
      height: 230,
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4, height: 24,
                color: Theme.of(context).colorScheme.primary,
                margin: const EdgeInsets.only(right: 6),
              ),
              Expanded(
                child: Text(
                    '当前发料任务 ${_.issuanceModel.invName ?? ''}',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),
              const SizedBox(width: 12,),
            ],
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
                controller: _.issuanceDetailController,
                child: Wrap(
                  runSpacing: 4, spacing: 4,
                  children: issuanceList(context, _),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  List<Widget> issuanceList(BuildContext context, MoIssuanceEditController _){
    List<Widget> list = [];
    list.add(
        orderItemWidget(
          title: '色粉', content: _.issuanceModel.toner ?? '',
        )
    );
    list.add(
        orderItemWidget(
          title: '材料名称', content: _.issuanceModel.invName ?? '',
        )
    );
    list.add(
        orderItemWidget(
          title: '产品名称', content: _.issuanceModel.productName ?? '',
        )
    );
    list.add(
        orderItemWidget(
          title: '总数量',
          content: NumFormatUtil.qtyFormatConverter((_.issuanceModel.qty ?? 0).toString(), decimal: 2),
          isBold: true,
        )
    );
    list.add(
        orderItemWidget(
          title: '发料人', content: _.issuanceModel.issuer ?? '',
        )
    );
    //region define
    if (_.dataService.userDefMap['Define22']?.defCaption != null){
      list.add(
          orderItemWidget(
              title: _.dataService.userDefMap['Define22']!.defCaption!,
              content: _.issuanceModel.define22 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define23']?.defCaption != null){
      list.add(
          orderItemWidget(
              title: _.dataService.userDefMap['Define23']!.defCaption!,
              content: _.issuanceModel.define23 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define24']?.defCaption != null){
      list.add(
          orderItemWidget(
              title: _.dataService.userDefMap['Define24']!.defCaption!,
              content: _.issuanceModel.define24 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define25']?.defCaption != null){
      list.add(
          orderItemWidget(
              title: _.dataService.userDefMap['Define25']!.defCaption!,
              content: _.issuanceModel.define25 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define28']?.defCaption != null){
      list.add(
          orderItemWidget(
              title: _.dataService.userDefMap['Define28']!.defCaption!,
              content: _.issuanceModel.define28 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define29']?.defCaption != null){
      list.add(
          orderItemWidget(
              title: _.dataService.userDefMap['Define29']!.defCaption!,
              content: _.issuanceModel.define29 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define30']?.defCaption != null){
      list.add(
          orderItemWidget(
              title: _.dataService.userDefMap['Define30']!.defCaption!,
              content: _.issuanceModel.define30 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define31']?.defCaption != null){
      list.add(
          orderItemWidget(
              title: _.dataService.userDefMap['Define31']!.defCaption!,
              content: _.issuanceModel.define31 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define32']?.defCaption != null){
      list.add(
          orderItemWidget(
              title: _.dataService.userDefMap['Define32']!.defCaption!,
              content: _.issuanceModel.define32 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define33']?.defCaption != null){
      list.add(
          orderItemWidget(
              title: _.dataService.userDefMap['Define33']!.defCaption!,
              content: _.issuanceModel.define33 ?? ''
          )
      );
    }
    //endregion
    return list;
  }
  Widget orderItemWidget({required String title, required String content, Color? contentColor, bool isBold = false}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: 500,
      titleWidth: 150,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      contentStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
        color: contentColor,
        fontWeight: isBold ? FontWeight.w600 : null
      ),
    );
  }

  Widget editWidget(BuildContext context, MoIssuanceEditController _){
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///标题
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 4, height: 24,
                  color: Theme.of(context).colorScheme.primary,
                  margin: const EdgeInsets.only(right: 6),
                ),
                Text(
                  '数据填报',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600
                  ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
                const SizedBox(width: 16,),
              ],
            )
          ),

          ///报工填单区域
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      dataReportItem1(
                        title: '发料人员',
                        customizeContent: _.isPsnHasAdapter ?
                        PickerInputWidget(
                          adapter: _.personAdapter,
                          pickerChoiceType: PickerChoiceType.chip,
                          onTap: (List<PickerDataModel> selectList) async{
                            controller.psnOnChanged(selectList);
                          },
                        ) :
                        InputWidget(
                          dataList: [_.personModel],
                        )
                      ),
                      dataReportItem1(
                        title: '件数',
                        customizeContent: NumPadTextField(
                          numPadController: NumPadUtil().getNumPadController(NumPadUtil.num, _.numPadCTList)!,
                          onChanged: (String str){  },
                        ),
                      ),
                      dataReportItem1(
                        title: '总重',
                        customizeContent: NumPadTextField(
                          numPadController: NumPadUtil().getNumPadController(NumPadUtil.qty, _.numPadCTList)!,
                          onChanged: (String str){  },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4,),

                Column(
                  children: [
                    NumPad(
                      nPCList: _.numPadCTList,
                      onPressed: (String val, String keyName, String text){  },
                    ),
                    const SizedBox(height: 12,),
                    FilledButton(
                      onPressed: () async{
                        await controller.saveIssuance(false);
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 28, horizontal: 137)
                        ),
                      ),
                      child: Text(
                        '数据提交',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12,),
                    FilledButton(
                      onPressed: () async{
                        await controller.saveIssuance(true);
                      },
                      style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 28, horizontal: 129)
                          ),
                          backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.secondary
                          )
                      ),
                      child: Text(
                        '提交并打印',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget dataReportItem1({required String title, required Widget customizeContent, bool needMargin = true}){
    return TitleTextBoxWidget(
      title: title,
      customizeContent: customizeContent,
      titleWidth: 150, width: 580,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
      margin: needMargin ? const EdgeInsets.only(bottom: 12) : null,
    );
  }


}