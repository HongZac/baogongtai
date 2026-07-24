import 'package:auto_size_text/auto_size_text.dart';
import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/chart_data_model.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/mes_device_task_controller.dart';
import 'package:desktop/app/ui/widget/blink_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MesDeviceTaskItem extends StatelessWidget {

  ///多个设备的关键词设备Id（DeviceId）区分
  late final String tag;
  final Map<String, UserDefEntity> userDefMap = Get.find<DataService>().userDefMap;

  final MesDeviceTaskController ctl = Get.find<MesDeviceTaskController>();

  ///必须指定一个对象key,否则在gridView中过滤时，不会动态刷新内容
  MesDeviceTaskItem({required this.tag}) : super(key: ValueKey(tag));

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ModelWithGetxController<EAMDeviceModel>>(tag: tag, builder: (item){
      MoTaskModel? currentTask = item.model.currentTask;
      double percent = currentTask?.finishQty == null || currentTask?.finishQty == 0
          || currentTask?.assignQty == null || currentTask?.assignQty == 0
          ? 0
          : currentTask!.finishQty! / currentTask.assignQty!;
      Color? percentFontColor = percent <= 0.5
          ? null
          : percent <= 0.8 ? AppColors.progressWarnBkgColor : AppColors.progressErrBkgColor;
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (ctl.itemWidth != constraints.maxWidth){
            ctl.itemAspectRatio = constraints.maxWidth / ctl.itemHeight;
            ctl.itemWidth = constraints.maxWidth;
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              ctl.update();
            });
          }
          return Material(
            elevation: 4,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: InkWell(
              onDoubleTap: () async{
                await ctl.itemOnDoubleTap(item.model);
              },
              child: BlinkWidget(
                isBlink: ctl.isBlink && percent > 1,
                rate: ctl.rate,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceTint.withAlpha(13),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: contentWidget(context, item, percent: percent, percentFontColor: percentFontColor),
              ),
            ),
          );
        }
      );
    });
  }
  
  Widget contentWidget(BuildContext context, ModelWithGetxController<EAMDeviceModel> item, {required double percent, required Color? percentFontColor}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///图片
              Tooltip(
                message: '产品附件',
                child: InkWell(
                    onTap: () async{
                      if (item.model.currentTask == null || item.model.currentTask!.taskId.isEmpty){
                        return;
                      }
                      await ctl.itemInvAttach(item.model.currentTask!);
                    },

                    child: Container(
                      width: 60, height: 90,
                      margin: const EdgeInsets.only(left: 4, top: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceTint.withAlpha(25),
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Icon(
                        const IconData(0xe601, fontFamily: 'MineIconFont'),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                )
              ),
              const SizedBox(width: 8,),

              ///机台号、机台状态、剩余生产时间
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                getDeviceInfo(item.model, ctl.deviceShowInfoType).isNotEmpty ? getDeviceInfo(item.model, ctl.deviceShowInfoType) : ' ',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.7
                                ), maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          ///工序图纸
                          Tooltip(
                            message: '工序图纸',
                            child: InkWell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                child: Icon(
                                  Icons.attachment_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              onTap: () async {
                                if (item.model.currentTask == null || item.model.currentTask!.taskId.isEmpty){
                                  return;
                                }
                                await ctl.getOpAttach(item.model.currentTask!);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (item.model.isLoadingSeries)
                      FittedBox(
                          child: SpinKitCircle(
                            color: Colors.grey,
                            size: 28,
                          )
                      )
                    else
                      FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              text: '采集数：',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3
                              ),
                              children: [
                                TextSpan(
                                  text: NumFormatUtil.qtyFormatConverter((item.model.series ?? 0).toString()),
                                ),
                                //
                              ]
                            ),
                            maxLines: 1,
                            textScaler: TextScaler.linear(FontFamilyConfig.textScale),
                          )
                      ),

                    ///员工上下岗
                    Tooltip(
                      message: (item.model.onduty ?? '').isNotEmpty
                          ? '员工下岗'
                          : '员工上岗',
                      child: InkWell(
                        onTap: () async {
                          await ctl.onOffPerson(item);
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.model.onduty ?? ' '}',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3
                                ), maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              Icon(
                                Icons.person_search,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ///产品名称、完成进度、周期、模穴
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      interactive: false,
                      thumbVisibility: WidgetStateProperty.all(false),
                      trackVisibility: WidgetStateProperty.all(false),
                      thumbColor: WidgetStateProperty.all(Colors.transparent),
                      trackColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (item.model.isLoadingCurrentTask)
                          FittedBox(
                            child: SpinKitCircle(
                              color: Colors.grey,
                              size: 28,
                            )
                          ),
                        if (!item.model.isLoadingCurrentTask)
                          Expanded(
                            child: AutoSizeText(
                              item.model.currentTask?.invName != null && item.model.currentTask!.invName!.isNotEmpty
                                  ? item.model.currentTask!.invName! + free(item.model.currentTask!) + invDefine(item.model.currentTask!)
                                  : ' ',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3,
                                fontWeight: FontWeight.w600,
                              ), maxLines: 3, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (!item.model.isLoadingCurrentTask)
                          FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                    text: '进度：',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3
                                    ),
                                    children: [
                                      TextSpan(
                                        text: NumFormatUtil.qtyFormatConverter((item.model.currentTask?.assignQty ?? 0).toString()),
                                      ),
                                      if (kDebugMode)
                                        ...[
                                          TextSpan(
                                            text: ' / ',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: NumFormatUtil.qtyFormatConverter((item.model.currentTask?.disabledQty ?? 0).toString()),
                                          ),
                                        ],
                                      TextSpan(
                                        text: ' / ',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      TextSpan(
                                        text: NumFormatUtil.qtyFormatConverter((item.model.currentTask?.finishQty ?? 0).toString()),
                                        style: TextStyle(
                                          color: percentFontColor,
                                        ),
                                      ),
                                      if (kDebugMode)
                                        ...[
                                          TextSpan(
                                            text: ' / ',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: NumFormatUtil.qtyFormatConverter((item.model.currentTask?.submitQty ?? 0).toString()),
                                          ),
                                        ],
                                    ]
                                ),
                                maxLines: 1,
                                textScaler: TextScaler.linear(FontFamilyConfig.textScale),
                              )
                          ),
                      ],
                    ),
                  ),
                ),
              ),


              ///进度条
              if (!item.model.isLoadingCurrentTask)
                SizedBox(
                  width: 90, height: 90,
                  child: circularChartWidget(percent, item.model)
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget circularChartWidget(double percent, EAMDeviceModel item){
    double showOfPercent = percent > 9.99 ? 9.99 : percent;
    Color percentCircularColor = percent <= 0.5
        ? AppColors.progressActiveBkgColor
        : percent <= 0.8 ? AppColors.progressWarnBkgColor : AppColors.progressErrBkgColor;
    List<ChartDataModel> chartData = [
      ChartDataModel('1', percent, color: percentCircularColor),
    ];
    return SfCircularChart(
      annotations: [
        CircularChartAnnotation(
          width: '120%', height: '120%',
          widget: Container(
            alignment: Alignment.center,
            child: AutoSizeText(
              '${(showOfPercent * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  color: chartData[0].color,
                  fontWeight: FontWeight.w600,
                  fontSize: Theme.of(Get.context!).textTheme.bodyMedium!.fontSize
              ), maxLines: 1,
            ),
          ),
        )
      ],
      series: [
        RadialBarSeries<ChartDataModel, String>(
          animationDuration: 0,
          cornerStyle: CornerStyle.bothCurve,
          maximumValue: 1,
          radius: '100%',
          innerRadius: '75%',
          trackOpacity: 0.15,
          useSeriesColor: true,
          dataSource: chartData,
          xValueMapper: (ChartDataModel data, _) => data.x,
          yValueMapper: (ChartDataModel data, _) => data.y,
          pointColorMapper: (ChartDataModel data, _) => data.color,
        )
      ],
    );
  }

  ///显示自由项
  String free(MoTaskModel item){
    String string = '';
    if (item.isFree1 == 1){
      string += '-' + (item.free1 ?? '');
    }
    if (item.isFree2 == 1){
      string += '-' + (item.free2 ?? '');
    }
    if (item.isFree3 == 1){
      string += '-' + (item.free3 ?? '');
    }
    if (item.isFree4 == 1){
      string += '-' + (item.free4 ?? '');
    }
    if (item.isFree5 == 1){
      string += '-' + (item.free5 ?? '');
    }
    if (item.isFree6 == 1){
      string += '-' + (item.free6 ?? '');
    }
    if (item.isFree7 == 1){
      string += '-' + (item.free7 ?? '');
    }
    if (item.isFree8 == 1){
      string += '-' + (item.free8 ?? '');
    }
    if (item.isFree9 == 1){
      string += '-' + (item.free9 ?? '');
    }
    if (item.isFree10 == 1){
      string += '-' + (item.free10 ?? '');
    }
    return string;
  }

  String invDefine(MoTaskModel item){
    List<String> list = [];
    //region InvDefine
    if (ctl.dataService.userDefMap['InvDefine1']?.defCaption != null){
      list.add(item.invDefine1 ?? '');
    }
    if (ctl.dataService.userDefMap['InvDefine2']?.defCaption != null){
      list.add(item.invDefine2 ?? '');
    }
    if (ctl.dataService.userDefMap['InvDefine3']?.defCaption != null){
      list.add(item.invDefine3 ?? '');
    }
    if (ctl.dataService.userDefMap['InvDefine4']?.defCaption != null){
      list.add(item.invDefine4 ?? '');
    }
    if (ctl.dataService.userDefMap['InvDefine5']?.defCaption != null){
      list.add(item.invDefine5 ?? '');
    }
    if (ctl.dataService.userDefMap['InvDefine6']?.defCaption != null){
      list.add(item.invDefine6 ?? '');
    }
    if (ctl.dataService.userDefMap['InvDefine7']?.defCaption != null){
      list.add(item.invDefine7 ?? '');
    }
    if (ctl.dataService.userDefMap['InvDefine8']?.defCaption != null){
      list.add(item.invDefine8 ?? '');
    }
    if (ctl.dataService.userDefMap['InvDefine9']?.defCaption != null){
      list.add(item.invDefine9 ?? '');
    }
    if (ctl.dataService.userDefMap['InvDefine10']?.defCaption != null){
      list.add(item.invDefine10 ?? '');
    }
    //endregion
    String str = list.join('-');
    return str.isEmpty ? '': '-$str';
  }

  String getDeviceInfo(EAMDeviceModel item, int deviceShowInfoType){
    switch (deviceShowInfoType){
      case 0:
        return item.deviceCode ?? '';
      case 1:
        return item.deviceAddCode ?? '';
      case 2:
        return item.deviceName ?? '';
      default:
        return item.deviceCode ?? '';
    }
  }

}