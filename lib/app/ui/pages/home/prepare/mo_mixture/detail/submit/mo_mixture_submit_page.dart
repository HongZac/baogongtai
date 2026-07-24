import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/submit/mo_mixture_submit_controller.dart';
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


///拌料单 651073 OR 粉料单 651078 报工页面
class MoMixtureSubmitPage extends BaseFormPage<MoMixtureSubmitController>{

  @override
  Widget contentWidget(BuildContext context, MoMixtureSubmitController _) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CardWidget(
            content: mixtureDetailWidget(context, _),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: submitWidget(context, _),
          ),
        )
      ],
    );
  }

  Widget mixtureDetailWidget(BuildContext context, MoMixtureSubmitController _){
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
                    '当前报工任务 ${_.mixtureModel.invName ?? ''}',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),
              const SizedBox(width: 12,),
            ],
          ),
          const SizedBox(height: 6,),
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
                controller: _.mixtureDetailController,
                child: Wrap(
                  runSpacing: 4, spacing: 4,
                  children: mixtureList(context, _),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  List<Widget> mixtureList(BuildContext context, MoMixtureSubmitController _){
    List<Widget> list = [];
    list.add(
        orderItemWidget(
          title: '色粉', content: _.mixtureModel.toner ?? '',
        )
    );
    list.add(
        orderItemWidget(
          title: '材料批次', content: _.mixtureModel.invBatch ?? '',
        )
    );
    list.add(
        orderItemWidget(
          title: '配方', content: _.mixtureModel.formula ?? '',
        )
    );
    list.add(
        orderItemWidget(
          title: '默认包重',
          content: NumFormatUtil.qtyFormatConverter((_.mixtureModel.boxQty ?? 0).toString(), decimal: 2),
          isBold: true,
        )
    );
    list.add(
        orderItemWidget(
          title: '总数量',
          content: NumFormatUtil.qtyFormatConverter((_.mixtureModel.qty ?? 0).toString(), decimal: 2),
          isBold: true,
        )
    );
    list.add(
        orderItemWidget(
            title: '已报工数量',
            content: NumFormatUtil.qtyFormatConverter((_.mixtureModel.submitQty ?? 0).toString(), decimal: 2),
        )
    );
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

  Widget submitWidget(BuildContext context, MoMixtureSubmitController _){
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
                          title: '生产人员',
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
                        title: '包重',
                        customizeContent: NumPadTextField(
                          numPadController: NumPadUtil().getNumPadController(NumPadUtil.singleBoxQty, _.numPadCTList)!,
                          onChanged: (String str){
                            controller.calcQty(NumPadUtil.singleBoxQty);
                          },
                        ),
                      ),
                      dataReportItem1(
                        title: '件数',
                        customizeContent: NumPadTextField(
                          numPadController: NumPadUtil().getNumPadController(NumPadUtil.num, _.numPadCTList)!,
                          onChanged: (String str){
                            controller.calcQty(NumPadUtil.num);
                          },
                        ),
                      ),
                      dataReportItem1(
                        title: '总重',
                        customizeContent: NumPadTextField(
                          numPadController: NumPadUtil().getNumPadController(NumPadUtil.qty, _.numPadCTList)!,
                          onChanged: (String str){
                            controller.calcQty(NumPadUtil.qty);
                          },
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(width: 4,),

                Column(
                  children: [
                    NumPad(
                      nPCList: _.numPadCTList,
                      onPressed: (String val, String keyName, String text){
                        controller.calcQty(keyName);
                      },
                    ),
                    const SizedBox(height: 12,),
                    FilledButton(
                      onPressed: () async{
                        await controller.saveSubmit(false);
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 28, horizontal: 137)
                        ),
                      ),
                      child: Text(
                        '报工提交',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12,),
                    FilledButton(
                      onPressed: () async{
                        await controller.saveSubmit(true);
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