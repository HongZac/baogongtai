import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/chart_data_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/utils/sign_color_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'device_detail_controller.dart';


///设备详情页
class DeviceDetailPage extends BaseFormPage<DeviceDetailController> {

  Widget contentWidget(BuildContext context, DeviceDetailController _){
    return Container(
      margin: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: kIsWeb || GetPlatform.isWindows
                ? const EdgeInsets.symmetric(vertical: 4)
                : null,
            child: _.commandBarWidget(
              context,
              commandBarList: _.detailCommandBarList,
              item: _.deviceTaskModelWithGetxController.model,
              commandBarMainAxisAlignment: MainAxisAlignment.start,
            ),
          ),
          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CardWidget(
                    content: deviceTaskWidget(context, _),
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
              content: taskWidget(context, _),
            ),
          ),
        ],
      ),
    );
  }

  Widget deviceTaskWidget(BuildContext context, DeviceDetailController _){
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(6),
      child: Column(
        key: _.deviceTaskWidgetKey,
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
                    //text: '${_.deviceTaskModelWithGetxController.model.deviceCode ?? ''} ${_.deviceTaskModelWithGetxController.model.invName ?? ''}',
                      text: '${_.deviceTaskModelWithGetxController.model.deviceCode ?? ''}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600
                      ),
                      children: [
                        TextSpan(
                          text: ' ${DataUtils.getNotConnectedZh(content: _.deviceTaskModelWithGetxController.model.deviceStatus ?? ' ', type: 1)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: SignColorUtil().getDeviceSignColor(_.deviceTaskModelWithGetxController.model.deviceSign ?? 0),
                          ),
                        ),
                        TextSpan(
                          text: ' 周期：${(_.deviceTaskModelWithGetxController.model.actualCycle ?? 0).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: SignColorUtil().getDeviceSignColor(_.deviceTaskModelWithGetxController.model.deviceSign ?? 0),
                          ),
                        ),
                        TextSpan(
                          text: ' 模穴：${(_.deviceTaskModelWithGetxController.model.output ?? 0).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: SignColorUtil().getDeviceSignColor(_.deviceTaskModelWithGetxController.model.deviceSign ?? 0),
                          ),
                        ),
                      ]
                  ),
                  textScaler: TextScaler.linear(FontFamilyConfig.textScale),
                ),
              ),
              const SizedBox(width: 6,),
            ],
          ),
          const SizedBox(height: 6,),
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
                child: Container(
                  width: 2000,
                  child: Wrap(
                    runSpacing: 4, spacing: 6,
                    children: _.getFieldList(
                      context,
                      infoFormList: _.taskInfoFormList,
                      widgetInfoItemOnTap: (ICloneable item) async {  },
                      item: _.taskModel,
                      customBuilder: (String keyName, ICloneable item) {
                        String? content;
                        InfoFormModel? infoFormModel = _.taskInfoFormList.firstWhereOrNull((element) => element.keyName == keyName);
                        if (infoFormModel != null){
                          /// [groupType]：== 0 时，数据源来自 [MoTaskModel]
                          /// [groupType]：== 1 时，数据源来自 [DeviceTaskModel]
                          Map<String, dynamic> deviceTaskMap = _.deviceTaskModelWithGetxController.model.toJson();
                          switch (infoFormModel.groupType){
                            case 1:
                              content = _.getInfoFormContent(deviceTaskMap[keyName]);
                              break;
                          }
                        }

                        switch (keyName) {
                          case 'CycleTime': ///标准周期
                            return {
                              'content': (_.deviceTaskModelWithGetxController.model.cycleTime ?? 0).toStringAsFixed(2),
                            };
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

  Widget lastDayOEEWidget(BuildContext context, DeviceDetailController _){
    controller.getDeviceTaskWidgetHeight();
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(6),
      height: _.deviceTaskWidgetHeight,
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
  Widget chartWidget(BuildContext context, DeviceDetailController _){
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

  Widget taskWidget(BuildContext context, DeviceDetailController _){
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
                '该机台下其他派工单',
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
                    for (int index = 0; index < _.taskListCommandBarList.length; index ++){
                      var element = _.taskListCommandBarList[index];
                      if (element.isShow){
                        needWidth = needWidth
                            + (element.title.length + (element.icon != null ? 2 : 0)) * 19
                            + (index < _.taskListCommandBarList.length - 1 ? 12 : 0);
                      }
                    }
                    return Container(
                      alignment: Alignment.centerRight,
                      child: _.commandBarWidget(
                        context,
                        commandBarList: _.taskListCommandBarList,
                        item: _.selectedTaskModel,
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
                itemCount: _.taskList.length,
                itemBuilder: (BuildContext context, int index){
                  MoTaskModel item = _.taskList[index];
                  return taskItem(context, _, item);
                },
              ),
            )
          ),
        ],
      )
    );
  }
  Widget taskItem(BuildContext context, DeviceDetailController _, MoTaskModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () {
            controller.taskOnSelected(item);
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
                      value: item.taskId == _.selectedTaskModel.taskId,
                      onChanged: (bool? bool) {
                        controller.taskOnSelected(item);
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
                        controller.taskExpandedOnChanged(item);
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
                      infoFormList: _.taskListInfoFormListMap[0] ?? [],
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
                      infoFormList: _.taskListInfoFormListMap[1] ?? [],
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