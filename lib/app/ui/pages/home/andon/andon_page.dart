
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'andon_controller.dart';


///安灯系统 --全场呼叫系统
class AndonPage extends BaseFormWithPageDataPage<AndonController, MoAndonServiceModel> {

  @override
  Widget headWidget(BuildContext context, AndonController _) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              runSpacing: 8, spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_.isShowSignFilter)
                  _.signWrapWidget(context),
                if (_.isShowDepPicker)
                  _.depFilterInputWidget(context),
                if (_.isShowAndonClassPicker)
                  TitleTextBoxWidget(
                    title: '类型筛选',
                    isShowColon: false,
                    widthOfSizedBox: 6,
                    titleWidth: 70, width: 270,
                    titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    customizeContent: PickerInputWidget(
                      adapter: _.andonClassAdapter,
                      height: 50,
                      onTap: (List<PickerDataModel> selectList) async{
                        await controller.andonClassOnChanged(selectList);
                      },
                    ),
                  ),
                if (_.isShowDatePicker)
                  _.dateFilterInputWidget(context),

                FilledButton(
                  onPressed: () async{
                    await controller.getNewAndon();
                  },
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          kIsWeb || GetPlatform.isWindows
                              ? const EdgeInsets.symmetric(vertical: 20, horizontal: 16)
                              : const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
                      )
                  ),
                  child: Text(
                    '发起呼叫',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4,),
          settingWidget(context, _, top: kIsWeb || GetPlatform.isWindows ? 9 : 0),
          const SizedBox(width: 6,)
        ],
      ),
    );
  }

  @override
  Widget dataItem(BuildContext context, AndonController _, MoAndonServiceModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 160,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ///附件查看
                  MineIconButton(
                    onPressed: () async{
                      await controller.itemAttach(item);
                    },
                    isNeedBadges: item.attach != null && item.attach! > 0,
                    badgesWidget: Text(
                      item.attach!.toString(),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onError
                      ),
                    ),
                    tooltip: '查看附件',
                    icon: Icons.attach_file_outlined,
                    iconSize: 46, //60,
                    iconColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  ),
                  const SizedBox(width: 4,),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '【${item.serviceName ?? ''}】${item.submitDescription ?? ''}',
                          style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4,),
                        Wrap(
                          runSpacing: 4, spacing: 4,
                          children: [
                            if (item.invCode != null && item.invCode!.isNotEmpty)
                              chipWidget(context, item.invCode!),
                            if (item.invName != null && item.invName!.isNotEmpty)
                              chipWidget(context, item.invName!),

                            if (item.mouldCode != null && item.mouldCode!.isNotEmpty)
                              chipWidget(context, item.mouldCode!),
                            if (item.mouldName != null && item.mouldName!.isNotEmpty)
                              chipWidget(context, item.mouldName!),

                            if (item.deviceCode != null && item.deviceCode!.isNotEmpty)
                              chipWidget(context, item.deviceCode!),
                            if (item.deviceName != null && item.deviceName!.isNotEmpty)
                              chipWidget(context, item.deviceName!),

                            if (item.affected != null && item.affected! > 0)
                              chipWidget(context, '数量：${item.affected}'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (item.serviceSign == null || item.serviceSign! < MoAndonServiceSign.ycl.sign)
                    const SizedBox(width: 4,),
                  if (item.serviceSign == null || item.serviceSign! < MoAndonServiceSign.ycl.sign)
                    FilledButton(
                      onPressed: () async{
                        await controller.nextStep(item);
                      },
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.secondary
                          )
                      ),
                      child: Text(
                        getNextBtnName(item.serviceSign),
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                        ),
                      ),
                    ),

                  if (item.serviceSign == null || item.serviceSign! < MoAndonServiceSign.ycl.sign)
                    const SizedBox(width: 4,),
                  if (item.serviceSign == null || item.serviceSign! < MoAndonServiceSign.ycl.sign)
                    FilledButton(
                      onPressed: () async{
                        await controller.cancelAndon(item);
                      },
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primaryContainer
                          )
                      ),
                      child: Text(
                        '取消呼叫',
                        style: TextStyle(
                            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                            color: Theme.of(context).colorScheme.onPrimaryContainer
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: timeLineWidget(context, item),
              )
            ],
          )
        ),
      ),
    );
  }

  String getNextBtnName(int? serviceSign){
    if (serviceSign == MoAndonServiceSign.dcl.sign){
      return '开始处理';
    }
    if (serviceSign == MoAndonServiceSign.clz.sign){
      return '处理完成';
    }
    if (serviceSign == MoAndonServiceSign.dqr.sign){
      return '确认验收';
    }
    return '下一步';
  }

  Widget chipWidget(BuildContext context, String content){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Text(
        content,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer
        ),
      ),
    );
  }

  Widget timeLineWidget(BuildContext context, MoAndonServiceModel item){
    return Row(
      children: [
        timelineTileWidget(
          context, isFirst: true,
          timeSign: MoAndonServiceSign.dcl.sign,
          sign: item.serviceSign ?? MoAndonServiceSign.dcl.sign,
          title: '发起', psn: item.submitter ?? '', dateTime: item.submitDate
        ),
        timelineTileWidget(///处理中、开始处理
          context,
          timeSign: MoAndonServiceSign.clz.sign,
          sign: item.serviceSign ?? MoAndonServiceSign.dcl.sign,
          title: '接收并处理', psn: item.processUser ?? '', dateTime: item.processDate
        ),
        timelineTileWidget(
          context,
          timeSign: MoAndonServiceSign.dqr.sign,
          sign: item.serviceSign ?? MoAndonServiceSign.dcl.sign,
          title: '完成', psn: item.finishUser ?? '', dateTime: item.finishDate
        ),
        timelineTileWidget(
          context, isLast: true,
          timeSign: MoAndonServiceSign.ycl.sign,
          sign: item.serviceSign ?? MoAndonServiceSign.dcl.sign,
          title: '验收', psn: item.acceptUser ?? '', dateTime: item.acceptDate
        ),
      ],
    );
  }

  Widget timelineTileWidget(BuildContext context, {
    required int timeSign, required int sign,
    required String title, required String psn, DateTime? dateTime,
    bool isFirst = false, bool isLast = false,
  }){
    return Expanded(
      child: TimelineTile(
        axis: TimelineAxis.horizontal,
        alignment: TimelineAlign.manual,
        lineXY: 0.33,
        isFirst: isFirst, isLast: isLast,
        indicatorStyle: IndicatorStyle(
          width: 10, height: 10,
          indicatorXY: 0.5,
          padding: const EdgeInsets.only(top: 6),
          color: timeSign == sign
              ? AppColors.warnColor
              : timeSign < sign ? AppColors.successColor : AppColors.greyColor,
        ),
        beforeLineStyle: LineStyle(
          thickness: 3,
          color: timeSign <= sign ? AppColors.successColor : AppColors.greyColor,
        ),
        afterLineStyle: LineStyle(
          thickness: 3,
          color: timeSign < sign ? AppColors.successColor : AppColors.greyColor,
        ),
        startChild: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: timeSign == sign ? FontWeight.w600 : null,
            color: timeSign > sign ? AppColors.greyColor : null
          ),
          textAlign: TextAlign.center,
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        endChild: Text(
          '$psn\n${DateUtil.getDateStrByDateTime(dateTime) ?? ''}',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: timeSign == sign ? FontWeight.w600 : null,
            color: timeSign > sign ? AppColors.greyColor : null
          ),
          textAlign: TextAlign.center,
          maxLines: 2, overflow: TextOverflow.ellipsis,
        )
      )
    );
  }

}