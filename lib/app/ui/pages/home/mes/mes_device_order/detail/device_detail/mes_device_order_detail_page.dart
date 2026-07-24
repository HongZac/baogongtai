import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/chart_data_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/detail/device_detail/mes_device_order_detail_controller.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/sign_color_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


///生产 设备对应生产任务单 设备详情页
class MesDeviceOrderDetailPage extends BaseFormPage<MesDeviceOrderDetailController>{

  Widget contentWidget(BuildContext context, MesDeviceOrderDetailController _){
    return Container(
      margin: const EdgeInsets.all(4),
      child: Column(
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CardWidget(
                    content: deviceOrderWidget(context, _),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: CardWidget(
                    content: lastDayOEEWidget(context, _),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CardWidget(
              content: orderWidget(context, _),
            ),
          ),
        ],
      ),
    );
  }

  Widget deviceOrderWidget(BuildContext context, MesDeviceOrderDetailController _) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(6),
      child: Column(
        key: _.deviceOrderWidgetKey,
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
                child: RichText(
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      //text: '${_.deviceWBModelWithGetxController.model.deviceCode ?? ''} ${_.deviceWBModelWithGetxController.model.invName ?? ''}',
                      //text: '${_.deviceWBModelWithGetxController.model.deviceCode ?? ''}',
                      text: '${_.deviceWBModelWithGetxController.model.deviceCode ?? ''} ${_.deviceWBModelWithGetxController.model.currentOp?.opName ?? ''}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600
                      ),
                      children: [
                        TextSpan(
                          text: ' ${DataUtils.getNotConnectedZh(content: _.deviceWBModelWithGetxController.model.deviceStatus ?? ' ', type: 1)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: SignColorUtil().getDeviceSignColor(_.deviceWBModelWithGetxController.model.deviceSign ?? 0),
                          ),
                        ),
                      ]
                  ),
                  textScaler: TextScaler.linear(FontFamilyConfig.textScale),
                ),
              ),
              const SizedBox(width: 6,),
              if (_.deviceWBModelWithGetxController.model.wbMxId.isNotEmpty)
                FilledButton(
                  onPressed: () async{
                    await controller.suspendTask();
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                        kIsWeb || GetPlatform.isWindows
                            ? const EdgeInsets.symmetric(vertical: 16, horizontal: 18)
                            : const EdgeInsets.symmetric(vertical: 10, horizontal: 18)
                    ),
                  ),
                  child: Text(
                    '挂起',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                    ),
                  ),
                ),
              if (_.deviceWBModelWithGetxController.model.wbMxId.isNotEmpty)
              const SizedBox(width: 6,),

              PickerButtonWidget(
                pickerButtonType: PickerButtonType.filled,
                child: Text(
                  '切换生产工艺',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ),
                ),
                buttonStyle: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.symmetric(vertical: 16, horizontal: 18)
                          : const EdgeInsets.symmetric(vertical: 10, horizontal: 18)
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.secondary
                  ),
                ),
                adapter: _.mesDeviceOrderController.operAdapter,
                pickerChoiceType: PickerChoiceType.chip,
                onTap: (List<PickerDataModel> selectList) async {
                  await _.mesDeviceOrderController.selectedCurrentOp(
                      _.deviceId,
                      selectList.isNotEmpty ? selectList[0] : PickerDataModel()
                  );

                  ProgressDialogUtil.showProgressDialog();
                  var res = await controller.getWBEntryList();
                  if (!res){
                    ProgressDialogUtil.close();
                  }
                  else {
                    ProgressDialogUtil.update(value: 1, msg: '任务单（工序计划明细）列表数据重新获取成功！');
                  }
                  controller.update();
                },
                isNeedLoadStr: false,
              ),

              const SizedBox(width: 6,),
              FilledButton(
                onPressed: () async {
                  await _.mesDeviceOrderController.onOffPerson(_.deviceId);
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.symmetric(vertical: 16, horizontal: 18)
                          : const EdgeInsets.symmetric(vertical: 10, horizontal: 18)
                  ),
                  backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.secondary
                  ),
                ),
                child: Text(
                  '员工上下岗',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                  ),
                ),
              ),
            ],
          ),
          Container(
            constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: 335,
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
                child: SizedBox(
                  width: 2000,
                  child: Wrap(
                    runSpacing: 4, spacing: 6,
                    children: _.getFieldList(
                        context,
                        infoFormList: _.wBEntryInfoFormList,
                        widgetInfoItemOnTap: (ICloneable item) async {  },
                        item: _.orderModel,
                        customBuilder: (String keyName, ICloneable item) {
                          String? content;
                          InfoFormModel? infoFormModel = _.wBEntryInfoFormList.firstWhereOrNull((element) => element.keyName == keyName);
                          if (infoFormModel != null){
                            /// [groupType]：== 0 时，数据源来自 [MoOpOrderModel]
                            /// [groupType]：== 1 时，数据源来自 [MoDeviceWorkBillList]
                            Map<String, dynamic> deviceWBMap = _.deviceWBModelWithGetxController.model.toJson();
                            switch (infoFormModel.groupType){
                              case 1:
                                switch (keyName){
                                  case 'OpQty':
                                    content = NumFormatUtil.qtyFormatConverter(_.deviceWBModelWithGetxController.model.qty.toString());
                                    break;
                                  case 'OpSubmitQty':
                                    content = NumFormatUtil.qtyFormatConverter(_.deviceWBModelWithGetxController.model.submitQty.toString());
                                    break;
                                  case 'OpDisabledQty':
                                    content = NumFormatUtil.qtyFormatConverter(_.deviceWBModelWithGetxController.model.disabledQty.toString());
                                    break;
                                  case 'OpAcceptQty':
                                    content = NumFormatUtil.qtyFormatConverter(_.deviceWBModelWithGetxController.model.acceptQty.toString());
                                    break;
                                  case 'OpQualifiedQty':
                                    content = NumFormatUtil.qtyFormatConverter(_.deviceWBModelWithGetxController.model.qualifiedQty.toString());
                                    break;
                                  case 'UnOpSubmitQty':
                                    content = NumFormatUtil.qtyFormatConverter(
                                        (_.deviceWBModelWithGetxController.model.qty ?? 0) <= (_.deviceWBModelWithGetxController.model.submitQty ?? 0)
                                            ? '0'
                                            : ((_.deviceWBModelWithGetxController.model.qty ?? 0) - (_.deviceWBModelWithGetxController.model.submitQty ?? 0)).toStringAsFixed(0)
                                    );
                                    break;
                                  default:
                                    content = _.getInfoFormContent(deviceWBMap[keyName]);
                                    break;
                                }
                                break;
                            }
                          }

                          switch (keyName) {
                            case 'RemainingQty':
                            //region 剩余报工数
                              return {
                                'content': NumFormatUtil.qtyFormatConverter(
                                    (_.orderModel.qty ?? 0) <= (_.orderModel.qualifiedQty ?? 0)
                                        ? '0'
                                        : ((_.orderModel.qty ?? 0) - (_.orderModel.qualifiedQty ?? 0)).toStringAsFixed(0)
                                ),
                              };
                          //endregion
                            case 'UnStockQty':
                            //region 未入库数量
                              return {
                                'content': NumFormatUtil.qtyFormatConverter(
                                    (_.orderModel.qty ?? 0) <= (_.orderModel.stockQty ?? 0)
                                        ? '0'
                                        : ((_.orderModel.qty ?? 0) - (_.orderModel.stockQty ?? 0)).toStringAsFixed(0)
                                ),
                              };
                          //endregion
                            default:
                              if (content != null){
                                return {
                                  'content': content,
                                };
                              }
                          }
                          return null;
                        }
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget lastDayOEEWidget(BuildContext context, MesDeviceOrderDetailController _) {
    controller.getDeviceOrderWidgetHeight();
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(6),
      height: _.deviceOrderWidgetHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 24,
                color: Theme.of(context).colorScheme.primary,
                margin: const EdgeInsets.only(right: 6),
              ),
              Expanded(
                  child: Text(
                      '昨日设备利用率：${_.lastDayOEE.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600
                      ), maxLines: 1, overflow: TextOverflow.ellipsis
                  )
              ),
            ],
          ),
          const SizedBox(height: 6,),
          Expanded(
            child: chartWidget(context, _),
          )
        ],
      ),
    );
  }
  Widget chartWidget(BuildContext context, MesDeviceOrderDetailController _){
    //region
    Color borderColor = const Color(0xFF7359D8);
    List<double> stops = [0, 0.3, 0.5, 0.8, 0.9, 1];
    List<Color> colorList = const [
      Color.fromRGBO(115, 89, 216, 0.6),
      Color.fromRGBO(115, 89, 216, 0.5),
      Color.fromRGBO(115, 89, 216, 0.3),
      Color.fromRGBO(115, 89, 216, 0.2),
      Color.fromRGBO(115, 89, 216, 0.2),
      Color.fromRGBO(115, 89, 216, 0.1),
    ];
    LinearGradient gradientColors = LinearGradient(
        colors: colorList,
        stops: stops,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
    );
    //endregion

    return SfCartesianChart(
        plotAreaBorderColor: const Color.fromRGBO(0, 0, 0, 0),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: '利用率',
        ),
        title: ChartTitle(
          text: '24小时开机利用率',
          alignment: ChartAlignment.near,
          textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600
          ),
        ),
        primaryXAxis: CategoryAxis( ///横轴
          minimum: 0,
          //interval: 1,
          labelAlignment: LabelAlignment.center,
          labelIntersectAction: AxisLabelIntersectAction.rotate90,
          majorGridLines: const MajorGridLines( ///主网格线
            width: 0,
          ),
          majorTickLines: const MajorTickLines( ///主刻度线
            size: 3,
            width: 0,
          ),
          axisLine: const AxisLine( ///主轴
            width: 1,
          ),
          labelStyle: Theme.of(context).textTheme.labelSmall, ///轴标签
        ),
        primaryYAxis: NumericAxis( ///纵轴
          labelFormat: '{value}' '%',
          interval: 30,
          maximum: 121,
          minimum: 0,
          tickPosition: TickPosition.inside, ///刻度定位在图表区域外部
          majorGridLines: const MajorGridLines( ///主网格线
            width: 1,
          ),
          majorTickLines: const MajorTickLines( ///主刻度线
            width: 0, //1.5,
          ),
          axisLine: const AxisLine( ///主轴
            width: 0,
          ),
          labelStyle: Theme.of(context).textTheme.labelSmall, ///轴标签
        ),
        series: [
          AreaSeries<ChartDataModel, String>(
              gradient: gradientColors,
              borderWidth: 1.5,
              borderColor: borderColor,
              enableTooltip: true,
              animationDuration: 0,
              markerSettings: MarkerSettings( //标记
                isVisible: true,
                height: 6,
                width: 6,
                color: Colors.white,
                shape: DataMarkerType.circle,
                borderWidth: 1.5,
                borderColor: borderColor,
              ),
              dataLabelSettings: DataLabelSettings( //标签
                  isVisible: false,
                  builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex){
                    return Text(
                        data.sales >= 99.99 ? '' : ('${data.sales}%'),
                        style: Theme.of(context).textTheme.bodySmall
                    );
                  }
              ),
              dataSource: _.hourOEEList,
              xValueMapper: (ChartDataModel data, _) => data.x,
              yValueMapper: (ChartDataModel data, _) => data.y
          )
        ]
    );
  }


  Widget orderWidget(BuildContext context, MesDeviceOrderDetailController _) {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(6),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 4, height: 24,
                  color: Theme.of(context).colorScheme.primary,
                  margin: const EdgeInsets.only(right: 6),
                ),
                Text(
                    '该机台下其他任务单',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
                const SizedBox(width: 8,),

                _.signWrapWidget(
                  context,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                const SizedBox(width: 8,),

                if (_.isDataByScan)
                  SizedBox(
                    height: 44,
                    child: _.resetScanWidget(context),
                  ),
                if (_.isDataByScan)
                  const SizedBox(width: 8,),

                SizedBox(
                  height: 44,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: _.searchInputWidget(context),
                  ),
                ),
                const SizedBox(width: 8,),

                Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints){
                        double needWidth = 0;
                        for (int index = 0; index < _.wBEntryListCommandBarList.length; index ++){
                          var element = _.wBEntryListCommandBarList[index];
                          if (element.isShow){
                            needWidth = needWidth
                                + (element.title.length + (element.icon != null ? 2 : 0)) * 19
                                + (index < _.wBEntryListCommandBarList.length - 1 ? 12 : 0);
                          }
                        }
                        return Container(
                          alignment: Alignment.centerRight,
                          child: _.commandBarWidget(
                            context,
                            commandBarList: _.wBEntryListCommandBarList,
                            item: _.selectedWBModel,
                            isNeedCard: true,
                            width: constraints.maxWidth < needWidth
                                ? constraints.maxWidth
                                : needWidth + 16,
                          ),
                        );
                      },
                    )
                ),
              ],
            ),
            const SizedBox(height: 4,),
            Expanded(
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    interactive: false,
                    thumbVisibility: WidgetStateProperty.all(false),
                    trackVisibility: WidgetStateProperty.all(false),
                    thumbColor: WidgetStateProperty.all(Colors.transparent),
                    trackColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: ListView.builder(
                    itemCount: _.wBEntryList.length,
                    itemBuilder: (BuildContext context, int index){
                      MoWorkBillListModel item = _.wBEntryList[index];
                      return orderItem(context, _, item);
                    },
                  ),
                )
            ),
          ],
        )
    );
  }
  Widget orderItem(BuildContext context, MesDeviceOrderDetailController _, MoWorkBillListModel item){
    return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
                onTap: () {
                  controller.orderOnSelected(item);
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: item.objectId == _.selectedWBModel.objectId,
                            onChanged: (bool? bool) {
                              controller.orderOnSelected(item);
                            },
                          ),
                          const SizedBox(width: 8,),
                          Expanded(
                            child: Text(
                              '${item.invName}',
                              style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                          const SizedBox(width: 8,),

                          Text(
                            item.status ?? '',
                            style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                                color: SignColorUtil().getTaskSignColor(item.sign ?? 0),
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          const SizedBox(width: 16,),
                          TextButton(
                            onPressed: (){
                              controller.orderExpandedOnChanged(item);
                            },
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                  kIsWeb || GetPlatform.isWindows
                                      ? const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                                      : const EdgeInsets.symmetric(vertical: 8, horizontal: 8)
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.isExpanded ? '收起' : '展开',
                                  style: Theme.of(Get.context!).textTheme.bodyLarge,
                                ),
                                const SizedBox(width: 2,),
                                AnimatedRotation(
                                    turns: item.isExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 100),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: Theme.of(Get.context!).textTheme.bodyLarge!.color,
                                      size:  Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43,
                                    )
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 4),
                        constraints: BoxConstraints(
                          minHeight: 40,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.end,
                          runSpacing: 4, spacing: 6,
                          children: _.getFieldList(
                            context,
                            infoFormList: _.wBEntryListInfoFormListMap[0] ?? [],
                            item: item,
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: !item.isExpanded ?
                        const SizedBox.shrink() :
                        Wrap(
                          runSpacing: 4, spacing: 6,
                          children: _.getFieldList(
                            context,
                            infoFormList: _.wBEntryListInfoFormListMap[1] ?? [],
                            item: item,
                          ),
                        ),
                        crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 250),
                      ),
                    ],
                  ),
                )
            )
        )
    );
  }


}