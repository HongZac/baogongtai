import 'package:auto_size_text/auto_size_text.dart';
import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop/app/model/chart_data_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/adjust_output/adjust_output_controller.dart';
import 'package:desktop/app/ui/pages/adjust_output/adjust_output_view.dart';
import 'package:desktop/app/ui/widget/blink_widget.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/sign_color_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'device_controller.dart';


///设备列表中单个设备显示内容
class DeviceItem extends StatelessWidget{

  ///多个设备的关键词设备Id（DeviceId）区分
  late final String tag;
  final Map<String, UserDefEntity> userDefMap = Get.find<DataService>().userDefMap;

  final DeviceController ctl = Get.find<DeviceController>();

  final headers = {"Access-Control-Allow-Origin": "*"};


  ///必须指定一个对象key,否则在gridView中过滤时，不会动态刷新内容
  DeviceItem({required this.tag}) : super(key: ValueKey(tag));

  @override
  Widget build(BuildContext context)  {
    return GetBuilder<ModelWithGetxController<MoDeviceTaskModel>>(tag: tag, builder: (item){
      double percent = (item.model.assignQty == null || item.model.assignQty == 0)
          ? 0
          : (item.model.finishQty ?? 0) / item.model.assignQty!;
      Color? percentFontColor = percent <= 0.5
          ? null
          : percent <= 0.8 ? AppColors.progressWarnBkgColor : AppColors.progressErrBkgColor;
      String surplusTime = NumFormatUtil.timeFormatConverter(item.model.surplusTime);
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints){
          if (ctl.itemWidth != constraints.maxWidth){
            ctl.itemAspectRatio = constraints.maxWidth / ctl.itemHeight;
            ctl.itemWidth = constraints.maxWidth;
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              ctl.update();
            });
          }
          return Material(
            elevation: 4,
            //surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: InkWell(
              onLongPress: () async{
                await itemOnLongPress(context, item);
              },
              onDoubleTap: () async{
                await itemOnDoubleTap(item.model);
              },
              child: BlinkWidget(
                isBlink: ctl.isBlink && percent > 1 && item.model.deviceSign == DeviceSign.scz.sign,
                rate: ctl.rate,
                decoration: BoxDecoration(
                  gradient: ctl.isBlink && percent > 1 && item.model.deviceSign == DeviceSign.scz.sign ?
                  null :
                  LinearGradient(///渐变位置
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 1.0],
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).brightness == Brightness.light
                          ? SignColorUtil().getDeviceSignBkgdColor(item.model.deviceSign ?? 0)
                          : SignColorUtil().getDeviceSignColor(item.model.deviceSign ?? 0).withAlpha(25)
                    ]
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: contentWidget(context, item, percent: percent, percentFontColor: percentFontColor, surplusTime: surplusTime),
              ),
            ),
          );
        }
      );
    });
  }

  Widget contentWidget(BuildContext context, ModelWithGetxController<MoDeviceTaskModel> item, {required double percent, required Color? percentFontColor, required String surplusTime}){
    Widget child = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///图片
              InkWell(
                  onTap: () async{
                    await imageOnTap(item.model);
                  },
                  child: Container(
                    width: 70, height: 70,
                    margin: const EdgeInsets.only(left: 4, top: 4),
                    decoration: BoxDecoration(
                      color: SignColorUtil().getDeviceSignColor(item.model.deviceSign ?? 0),
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    child: (item.model.deviceImage == null || item.model.deviceImage!.isEmpty) && item.model.imageUint8List == null ?
                    Icon(
                      const IconData(0xe601, fontFamily: 'MineIconFont'),
                      color: Theme.of(context).colorScheme.surface
                    ) :
                    item.model.imageUint8List != null ?
                    Image.memory(
                      item.model.imageUint8List!,
                      fit: BoxFit.cover,
                    ) :
                    !item.model.isDeviceImageError ?
                    CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: AddressService.getUrl((item.model.deviceImage ?? '')),
                      httpHeaders: headers,
                      imageBuilder: (context, imageProvider) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      errorWidget: (BuildContext context, String url, Object error,){
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
                          item.model.isDeviceImageError = true;
                          item.update();
                        });
                        return Container(
                          width: 40, height: 40,
                          alignment: Alignment.center,
                          child: Text(
                            'ERROR',
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                        );
                      },
                      placeholder: (context, url) => AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(AppColors.progressActiveBkgColor),
                            backgroundColor: AppColors.progressBkgColor,
                          ),
                        ),
                      )
                    ) :
                    Container(
                      width: 40, height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        'ERROR',
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    ),
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
                          Text(
                            DataUtils.getNotConnectedZh(content: item.model.deviceStatus ?? '', type: 1),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: SignColorUtil().getDeviceSignColor(item.model.deviceSign ?? 0),
                                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      surplusTime.isEmpty && percent > 1
                          ? '已超产'
                          : surplusTime.isEmpty || percent > 1
                          ? ''
                          : '剩余：$surplusTime',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.progressErrBkgColor,
                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3
                      ), maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8,),
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
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item.model.invName != null && item.model.invName!.isNotEmpty
                                    ? item.model.invName! + free(item.model) + invDefine(item.model)
                                    : ' ',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3
                                ), maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                                          text: NumFormatUtil.qtyFormatConverter((item.model.assignQty ?? 0).toString()),
                                        ),
                                        TextSpan(
                                          text: ' / ',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: NumFormatUtil.qtyFormatConverter((item.model.disabledQty ?? 0).toString()),
                                        ),
                                        TextSpan(
                                          text: ' / ',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: NumFormatUtil.qtyFormatConverter((item.model.finishQty ?? 0).toString()),
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
                                              text: NumFormatUtil.qtyFormatConverter((item.model.submitQty ?? 0).toString()),
                                            ),
                                          ],
                                      ]
                                  ),
                                  maxLines: 1,
                                  textScaler: TextScaler.linear(FontFamilyConfig.textScale),
                                )
                            ),
                            Divider(indent: 0, endIndent: 0,),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: '周期：',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3
                                      ),
                                      children: [
                                        TextSpan(
                                          text: item.model.cycleTime == null
                                              ? '00.00'
                                              : item.model.cycleTime.toString().split('.')[0].length < 2
                                              ? '0${item.model.cycleTime!.toStringAsFixed(2)}'
                                              : item.model.cycleTime!.toStringAsFixed(2),
                                        ),
                                        TextSpan(
                                          text: ' / ',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        TextSpan(
                                            text: item.model.actualCycle == null
                                                ? '00.00'
                                                : item.model.actualCycle.toString().split('.')[0].length < 2
                                                ? '0${item.model.actualCycle!.toStringAsFixed(2)}'
                                                : item.model.actualCycle!.toStringAsFixed(2),
                                            style: TextStyle(
                                              color: item.model.cycleTime != null && item.model.cycleTime != 0 && item.model.actualCycle != null && item.model.actualCycle != 0
                                                  && (item.model.cycleTime! - item.model.actualCycle!.abs() / item.model.cycleTime!) > 0.1
                                                  ? AppColors.errorColor
                                                  : null,
                                            )
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    textScaler: TextScaler.linear(FontFamilyConfig.textScale),
                                  ),
                                  SizedBox(width: 12,),
                                  RichText(
                                    text: TextSpan(
                                      text: '模穴：',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3
                                      ),
                                      children: [
                                        TextSpan(
                                          text: item.model.designOutput == null
                                              ? '00'
                                              : item.model.designOutput!.toStringAsFixed(0).length < 2
                                              ? '0${item.model.designOutput!.toStringAsFixed(0)}'
                                              : item.model.designOutput!.toStringAsFixed(0),
                                        ),
                                        TextSpan(
                                          text: ' / ',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: item.model.output == null
                                              ? '00'
                                              : item.model.output!.toStringAsFixed(0).length < 2
                                              ? '0${item.model.output!.toStringAsFixed(0)}'
                                              : item.model.output!.toStringAsFixed(0),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    textScaler: TextScaler.linear(FontFamilyConfig.textScale),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                  ),
                ),
              ),

              ///进度条
              SizedBox(
                  width: 90, height: 90,
                  child: circularChartWidget(percent, item.model)
              ),
            ],
          ),
        )
      ],
    );
    return Stack(
      children: [
        Positioned.fill(
          child: child,
        ),
        if (item.model.deviceSign == 4 && (item.model.status ?? '').isNotEmpty)
          Positioned(
            right: 4,
            top: 36,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(2),
              child: Text(
                '${item.model.status!}',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }

  Widget circularChartWidget(double percent, MoDeviceTaskModel item){
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
  String free(MoDeviceTaskModel item){
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

  String invDefine(MoDeviceTaskModel item){
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

  String getDeviceInfo(MoDeviceTaskModel item, int deviceShowInfoType){
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


  Future<void> itemOnLongPress(BuildContext context, ModelWithGetxController<MoDeviceTaskModel> item) async{
    await DialogUtils.showCustomDialog(
      context,
      initialWidth: 600,
      initialHeight: 400,
      isNeedConfirmBtn: false,
      title: '请选择操作：',
      content: SingleChildScrollView(
        child: Wrap(
          runSpacing: 6, spacing: 6,
          children: [
            choiceWidget(
                context,
                icon: Icons.post_add_outlined,
                iconColor: AppColors.mainColorList[0],
                title: '调整模穴', ///实际模穴
                onTap: () async{
                  //region
                  if (item.model.taskId == null || item.model.taskId!.isEmpty){
                    ToastNotification(Get.overlayContext!).warn("当前无正在进行的任务！");
                    return;
                  }
                  bool isNeedAdjustReason = (ctl.accInformationMap['adjust.reason']?.text?.toString() ?? '') == '1';
                  var res = await DialogUtils.showCustomDialog<AdjustOutputController, Map<String, dynamic>>(
                    Get.context!,
                    title: '调整模穴',
                    onConfirmName: '确认',
                    barrierDismissible: false,
                    isMaximize: true,
                    initialWidth: 800, initialHeight: 500,
                    contentPadding: const EdgeInsets.all(12),
                    content: AdjustOutputView(),
                    controller: AdjustOutputController(
                      initOutput: (item.model.output ?? 0).toDouble(),
                      isNeedAdjustReason: isNeedAdjustReason,
                    ),
                  );
                  if (res != null){
                    ProgressDialogUtil.showProgressDialog(msg: '正在调整模穴', completedMsg: '调整模穴成功！');
                    var res1 = await MoProcessRepository().adjustOutput(
                      item.model.deviceId!,
                      item.model.taskId!,
                      (res['output']).toInt(),
                      description: res['desc'] ?? '',
                    );
                    if (!res1.isSuccess){
                      ToastNotification(Get.overlayContext!).warn('提交调整模穴数据时出错：${res1.message}！');
                      ProgressDialogUtil.close();
                      return;
                    }
                    item.model.output = (res['output']).toInt();
                    item.update();
                    ProgressDialogUtil.update();
                  }
                  //endregion
                }
            ),
            choiceWidget(
                context,
                icon: Icons.post_add_outlined,
                iconColor: AppColors.mainColorList[0],
                title: '生产报工',
                onTap: () async{
                  await Get.rootDelegate.toNamed(
                      AppRoutes.PMES_REAL_TIME_MONITOR_SUBMIT_MAIN_PAGE,
                      parameters: {
                        'deviceId': item.model.deviceId ?? '',
                      }
                  );
                }
            ),
            choiceWidget(
                context,
                icon: Icons.assessment_outlined,
                iconColor: AppColors.mainColorList[1],
                title: '报工列表',
                onTap: () async{
                  await Get.rootDelegate.toNamed(
                      AppRoutes.PMES_REAL_TIME_MONITOR_SUBMIT_LIST_MAIN_PAGE,
                      parameters: {
                        'key': item.model.deviceId ?? '',
                        'keyName': 'deviceTask',
                      }
                  );
                }
            ),
            choiceWidget(
                context,
                icon: Icons.post_add_outlined,
                iconColor: AppColors.mainColorList[2],
                title: '次品录入',
                onTap: () async{
                  await Get.rootDelegate.toNamed(
                      AppRoutes.PMES_REAL_TIME_MONITOR_CHECK_RECORD_MAIN_PAGE,
                      parameters: {
                        'deviceId': item.model.deviceId ?? '',
                      }
                  );
                }
            ),
            choiceWidget(
                context,
                icon: Icons.assignment_late_outlined,
                iconColor: AppColors.mainColorList[3],
                title: '次品列表',
                onTap: () async{
                  await Get.rootDelegate.toNamed(
                      AppRoutes.PMES_REAL_TIME_MONITOR_CHECK_RECORD_LIST_PAGE,
                      parameters: {
                        'key': item.model.deviceId ?? '',
                        'keyName': 'deviceTask',
                      }
                  );
                }
            ),
            choiceWidget(
                context,
                icon: Icons.warning_amber_outlined,
                iconColor: AppColors.mainColorList[4],
                title: '工作流程-异常报告',
                onTap: () async{
                  await Get.rootDelegate.toNamed(
                    AppRoutes.DEVICE_EXCEPTION_MAIN_PAGE,
                    parameters: {
                      'deviceId': item.model.deviceId ?? '',
                    }
                  );
                }
            ),
            /*choiceWidget(
                context,
                icon: FluentIcons.call_outbound_48_filled,
                iconColor: AppColors.mainColorList[5],
                title: '工作流程-全场呼叫',
                onTap: () async{
                  await Get.rootDelegate.toNamed(
                      AppRoutes.DEVICE_ANDON_MAIN_PAGE,
                      parameters: {
                        'deviceId': item.deviceId ?? '',
                      }
                  );
                }
            ),*/
          ],
        ),
      ),
    );
  }
  Widget choiceWidget(BuildContext context, {required IconData icon, required Color iconColor,
    required String title, required AsyncCallback? onTap}){
    return InkWell(
        onTap: () async{
          Navigator.of(Get.context!).pop(false);
          await onTap?.call();
        },
        child: SizedBox(
          width: 130, height: 130,
          child: CardWidget(
            content: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 4,),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4,),
              ],
            ),
          ),
        )
    );
  }

  Future<void> itemOnDoubleTap(MoDeviceTaskModel item) async{
    Get.rootDelegate.toNamed(
        AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_MAIN_PAGE,
        parameters: {
          'deviceId': item.deviceId ?? '',
          'key': item.deviceId ?? '',
          'keyName': 'deviceTask',
          'noPermission': (ctl.dataService.isEnableOperatePrivilege
              && ctl.objectItem.buttons?['desktopUISettingBtn'] == null) ? '1' : '0',
          'permissionInfo': BaseService.profile.isSystem == true ? '【${ctl.objectItem.progid}】【desktopUISettingBtn】' : '',
        }
    );
  }

  Future<void> imageOnTap(MoDeviceTaskModel item) async{
    Map<String, String> map = await ctl.getSopIdAndCategory(ctl.sopProgId, item);
    if (map['id']!.isEmpty){
      return;
    }
    Get.rootDelegate.toNamed(
        AppRoutes.PMES_REAL_TIME_MONITOR_ATTACH_PAGE,
        parameters: {
          'pageTitle': '技术指导书-${item.invName ?? ''}',
          'id': map['id']!,
          'progId': ctl.sopProgId.toString(),
          'category': map['category']!,
        }
    );
  }

}