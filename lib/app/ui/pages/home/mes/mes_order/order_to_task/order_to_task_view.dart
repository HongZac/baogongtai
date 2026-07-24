import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/order_to_task/order_to_task_controller.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


///生产任务单派工页面
class OrderToTaskView extends BaseFormPage<OrderToTaskController> {

  Widget contentWidget(BuildContext context, OrderToTaskController _) {
    return Padding(
      padding: const EdgeInsets.symmetric(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(),
            child: CardWidget(
              content: detailWidget(context, _),
            ),
          ),
          const SizedBox(height: 8,),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 430,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: dataReportAreaWidgetList(context, _),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4,),
              NumPad(
                width: 300, height: 300,
                nPCList: _.numPadCTList,
                defaultNumPadKey: NumPadUtil.qty,
              ),
            ],
          ),

          Expanded(
            child: processViewWidget(context, _),
          ),
        ],
      ),
    );
  }

  Widget detailWidget(BuildContext context, OrderToTaskController _) {
    return Container(
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
                    '当前任务 ${_.orderModel.productName ?? ''}',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),
              const SizedBox(width: 12,),
            ],
          ),
          const SizedBox(height: 6,),
          Container(
            constraints: BoxConstraints(
              maxHeight: 140,
            ),
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                interactive: false,
                thumbVisibility: WidgetStateProperty.all(false),
                trackVisibility: WidgetStateProperty.all(false),
                thumbColor: WidgetStateProperty.all(Colors.transparent),
                trackColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  runSpacing: 4, spacing: 6,
                  children: _.getFieldList(
                    context,
                    infoFormList: _.orderInfoFormList,
                    item: _.orderModel,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> dataReportAreaWidgetList(BuildContext context, OrderToTaskController _){
    return [
      reportItem(
          context,
          title: '派工日期',
          customizeContent: PrefixTextField(
            object: 1, readOnly: true,
            initText: DateUtil.formatDateTime(
                (_.taskModel.taskDate ?? '').toString(),
                DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE
            ),
            valueOnChanged: (String string) async{
              controller.taskDateOnChanged(DateTime.tryParse(string));
            },
          )
      ),
      reportItem(
          context,
          title: '生产车间',
          customizeContent: PickerInputWidget(
            adapter: _.depAdapter,
            onTap: (List<PickerDataModel> selectList) {
              if (selectList.isNotEmpty){
                controller.depOnChanged(selectList[0]);
              }
              else {
                controller.depOnChanged(PickerDataModel());
              }
            },
          )
      ),
      reportItem(
        context,
        title: '生产设备',
        customizeContent: PickerInputWidget(
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
      ),
      reportItem(
        context,
        title: '生产人员',
        customizeContent: PickerInputWidget(
          adapter: _.personAdapter,
          pickerChoiceType: PickerChoiceType.chip,
          onTap: (List<PickerDataModel> selectList) async {
            if (selectList.isNotEmpty){
              controller.psnOnChanged(selectList[0]);
            }
            else {
              controller.psnOnChanged(PickerDataModel());
            }
          },
        ),
      ),
      reportItem(
        context,
        title: '派工数量', //unAssignQty
        customizeContent: NumPadTextField(
          numPadController: NumPadUtil().getNumPadController(NumPadUtil.qty, _.numPadCTList)!,
          measurement: (_.taskModel.moOpId ?? '').isNotEmpty
              ? '未分配：${NumFormatUtil.qtyFormatConverter(_.unAssignQty.toString())}'
              : '',
        ),
      ),
    ];
  }

  Widget processViewWidget(BuildContext context, OrderToTaskController _){
    return CardWidget(
      margin: const EdgeInsets.all(0),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '派工工序选择',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Expanded(
            child: _.processAdapter == null ?
            Container(
              alignment: Alignment.topCenter,
              child: SpinKitCircle(
                color: Colors.grey,
                size: 28,
              ),
            ) :
            SingleChildScrollView(
              padding: const EdgeInsets.all(6),
              child: Container(
                alignment: Alignment.topLeft,
                child: Wrap(
                  runSpacing: 6, spacing: 6,
                  children: List.generate(_.processAdapter!.dataList.length, (index){
                    MoWorkBillEntryModel item = _.processAdapter!.dataList[index];
                    return Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: () async {
                              await controller.processOnChanged(item);
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              width: 220, height: 88,
                              padding: const EdgeInsets.all(4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: item.isSelected
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : null,
                                border: item.isSelected ? null : Border.all(
                                    color: Theme.of(context).colorScheme.outline,
                                    width: 1
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        '${(item.opCode ?? '').isNotEmpty ? item.opCode : ' '}',
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                            fontWeight: FontWeight.w600
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        '${(item.opName ?? '').isNotEmpty ? item.opName : ' '}',
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                            fontWeight: FontWeight.w600
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        '未分配：${NumFormatUtil.qtyFormatConverter((item.unAssignQty ?? 0).toString())}',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                        maxLines: 1, overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ],
                              ),
                            )
                        )
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget reportItem(BuildContext context, {
    required String title,
    required Widget customizeContent,
    bool needMargin = true,
    double width = 580,
    double titleWidth = 100,
    String titleTip = '',
  }){
    return TitleTextBoxWidget(
      title: title,
      customizeContent: customizeContent,
      titleWidth: titleWidth,
      width: width,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
      margin: needMargin ? const EdgeInsets.only(bottom: 6) : null,
      titleTip: titleTip,
    );
  }
}