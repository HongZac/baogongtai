import 'package:basement/logger.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/log_inspector/log_inspector_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';


///程序日志视图显示
class LogInspectorView extends BaseDialogPage<LogInspectorController> {
  const LogInspectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LogInspectorController>(builder: (_){
      return ScrollbarTheme(
        data: ScrollbarThemeData(
          interactive: false,
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
          thumbColor: WidgetStateProperty.all(Colors.transparent),
          trackColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: contentWidget(context, _),
      );
    });
  }

  Widget contentWidget(BuildContext context, LogInspectorController _){
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  '共${_.loggerDataList.length}项请求',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 12,),

                _.searchInputWidget(
                  context,
                  needOpenBtn: false,
                  width: 230,
                ),
                const SizedBox(width: 12,),

                ///类型筛选
                TitleTextBoxWidget(
                  title: '类型筛选',
                  isShowColon: false,
                  widthOfSizedBox: 6,
                  titleWidth: 70, width: 270,
                  customizeContent: PickerInputWidget(
                    adapter: _.levelAdapter,
                    height: 50,
                    onTap: (List<PickerDataModel> selectList) {
                      controller.onLevelFilter(selectList.isEmpty ? 'all' : selectList[0].id);
                    },
                  ),
                  titleStyle: Theme.of(context).textTheme.bodyLarge,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                const SizedBox(width: 12,),

                TextButton(
                  onPressed: (){
                    controller.loggerOnClearEmpty();
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                        kIsWeb || GetPlatform.isWindows
                            ? const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                            : const EdgeInsets.symmetric(vertical: 12, horizontal: 8)
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FluentIcons.delete_16_regular,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                      ),
                      Text(
                        '清空',
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12,),

                TextButton(
                  onPressed: (){
                    controller.logFileOnClear(7);
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                        kIsWeb || GetPlatform.isWindows
                            ? const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                            : const EdgeInsets.symmetric(vertical: 12, horizontal: 8)
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FluentIcons.delete_16_regular,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                      ),
                      Text(
                        '清理7天前的日志文件',
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: _.loggerDataList.isEmpty ?
            Center(
              child: Text(
                '暂无日志',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ) :
            ListView.builder(
                controller: _.scrollController,
                itemCount: _.loggerDataList.length,
                padding: const EdgeInsets.only(right: 10),
                itemBuilder: (BuildContext context, int index){
                  return loggerItem(context, _, index);
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget loggerItem(BuildContext context, LogInspectorController _, int index) {
    LoggerDataModel item = _.loggerDataList[index];

    return Padding(
      key: ValueKey(item.uuid),
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          //padding: const EdgeInsetsGeometry.only(
          //    right: 12, left: 12, bottom: 12, top: 6
          //),
          //decoration: BoxDecoration(
          //    border: Border(
          //      bottom: BorderSide(
          //        color: Theme.of(context).dividerColor,
          //      ),
          //    )
          //),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: Theme.of(context).textTheme.bodyLarge!.fontSize! * 5,
                    child: Text(
                      item.outputEvent.level.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: getLevelFontColor(context, item.outputEvent.level),
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4,),
                  Text(
                    DateUtil.getDateStrByDateTime(item.outputEvent.origin.time, format: DateFormat.DEFAULT) ?? '',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 4,),
                  const Expanded(child: SizedBox.shrink()),
                  MineIconButton(
                    icon: FluentIcons.delete_16_regular,
                    tooltip: '删除',
                    iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    onPressed: (){
                      controller.loggerOnDeleted(item);
                    },
                  ),
                ],
              ),

              ///日志内容
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MineIconButton(
                    icon: item.isMsgExpanded
                        ? Icons.arrow_drop_down
                        : Icons.arrow_right,
                    iconColor: Theme.of(context).colorScheme.primary,
                    iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    padding: const EdgeInsets.all(0),
                    tooltip: item.isMsgExpanded
                        ? '收起'
                        : '展开',
                    onPressed: (){
                      controller.isMsgExpandedOnChanged(item);
                    },
                  ),
                  Expanded(
                    child: SelectableText(
                      '日志内容：${item.outputEvent.origin.message.toString().replaceAll(RegExp(r'^\n+'), '')}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      ),
                      maxLines: item.isMsgExpanded ? null : 1,
                    ),
                  )
                ],
              ),

              ///错误信息
              if (item.outputEvent.origin.error != null)
                ...[
                  const SizedBox(height: 4,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MineIconButton(
                        icon: item.isErrorExpanded
                            ? Icons.arrow_drop_down
                            : Icons.arrow_right,
                        iconColor: Theme.of(context).colorScheme.primary,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        padding: const EdgeInsets.all(0),
                        tooltip: item.isErrorExpanded
                            ? '收起'
                            : '展开',
                        onPressed: (){
                          controller.isErrorExpandedOnChanged(item);
                        },
                      ),
                      Expanded(
                        child: SelectableText(
                          '错误信息：${item.outputEvent.origin.error.toString()}',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          ),
                          maxLines: item.isErrorExpanded ? null : 1,
                        ),
                      )
                    ],
                  ),
                ],

              ///日志行
              if (item.outputEvent.lines.isNotEmpty)
                ...[
                  const SizedBox(height: 4,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MineIconButton(
                        icon: item.isLineExpanded
                            ? Icons.arrow_drop_down
                            : Icons.arrow_right,
                        iconColor: Theme.of(context).colorScheme.primary,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        padding: const EdgeInsets.all(0),
                        tooltip: item.isLineExpanded
                            ? '收起'
                            : '展开',
                        onPressed: (){
                          controller.isLineExpandedOnChanged(item);
                        },
                      ),
                      Expanded(
                        child: Text(
                          '日志行：${item.isLineExpanded ? '' : '……'}',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                  if (item.isLineExpanded)
                    SelectableText(
                      item.outputEvent.lines.join('\n').replaceAll(RegExp(r'\x1B\[[0-9;]*m'), ''),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      ),
                    ),
                ],

              ///堆栈跟踪
              if (item.outputEvent.origin.stackTrace != null)
                ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MineIconButton(
                        icon: item.isStackTraceExpanded
                            ? Icons.arrow_drop_down
                            : Icons.arrow_right,
                        iconColor: Theme.of(context).colorScheme.primary,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        padding: const EdgeInsets.all(0),
                        tooltip: item.isStackTraceExpanded
                            ? '收起'
                            : '展开',
                        onPressed: (){
                          controller.isStackTraceExpandedOnChanged(item);
                        },
                      ),
                      Expanded(
                        child: SelectableText(
                          '堆栈跟踪：${item.outputEvent.origin.stackTrace.toString()}',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          ),
                          maxLines: item.isStackTraceExpanded ? null : 1,
                        ),
                      )
                    ],
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Color getLevelFontColor(BuildContext context, Level level) {
    switch (level){
      case Level.all:
      case Level.off:
        return AppColors.dioGetColor;
      case Level.trace:
      case Level.info:
        return AppColors.dioPutColor;
      case Level.debug:
        return AppColors.dioDeleteColor;
      case Level.warning:
      case Level.error:
      case Level.fatal:
        return AppColors.dioOptionsColor;
      default:
        return Theme.of(context).textTheme.bodyLarge!.color!;
    }
  }


}