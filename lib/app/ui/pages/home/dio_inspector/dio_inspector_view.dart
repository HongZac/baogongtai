import 'package:basement/basement.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/dio_inspector/dio_inspector_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:multi_split_view/multi_split_view.dart';


///dio 网络检查器 消息队列显示
class DioInspectorView extends BaseDialogPage<DioInspectorController> {
  const DioInspectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DioInspectorController>(builder: (_){
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

  Widget contentWidget(BuildContext context, DioInspectorController _){
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsetsGeometry.only(bottom: 12),
              child: Row(
                children: [
                  Text(
                    '共${_.dioLogDataList.length}项请求',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 12,),

                  _.searchInputWidget(
                    context,
                    needOpenBtn: false,
                    width: 230,
                  ),
                  const SizedBox(width: 12,),

                  TextButton(
                    onPressed: (){
                      controller.responseOnClearEmpty();
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
                  )
                ],
              )
          ),
          Expanded(
            child: MultiSplitView(
              controller: _.multiSplitViewController,
              builder: (BuildContext context, Area area){
                switch (area.index){
                  case 0:
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      margin: const EdgeInsets.only(right: 2),
                      child: _.dioLogDataList.isEmpty ?
                      Center(
                        child: Text(
                          '暂无日志',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ) :
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints){
                          return ListView.builder(
                              controller: _.scrollController,
                              itemCount: _.dioLogDataList.length,
                              itemBuilder: (BuildContext context, int index){
                                return responseItem(context, constraints, _, index);
                              }
                          );
                        },
                      ),
                    );
                  case 1:
                    return detailWidget(context, _);
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget responseItem(BuildContext context, BoxConstraints constraints, DioInspectorController _, int index){
    DioLogDataModel item = _.dioLogDataList[index];
    String durationStr = item.requestDuration == null
        ? ''
        : item.requestDuration!.inMilliseconds < 1000
        ? '${item.requestDuration!.inMilliseconds}ms'
        : item.requestDuration!.inSeconds < 60
        ? '${(item.requestDuration!.inMilliseconds / 1000).toStringAsFixed(2)}s'
        : '${(item.requestDuration!.inMilliseconds / 1000 / 60).toStringAsFixed(2)}min';

    return Material(
      key: ValueKey(item.uuid),
      color: Colors.transparent,
      child: SizedBox(
        height: Theme.of(context).textTheme.bodyLarge!.fontSize! * 4,
        child: MouseRegion(
          onEnter: (PointerEnterEvent pointerEnterEvent){
            controller.mouseEnterKeyOnChanged(isEnter: true, key: item.uuid);
          },
          onExit: (PointerExitEvent pointerExitEvent){
            controller.mouseEnterKeyOnChanged(isEnter: false, key: item.uuid);
          },
          child: Stack(
            alignment: AlignmentDirectional.centerEnd,
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: (){
                    controller.selectedResponseOnChanged(item);
                  },
                  child: Container(
                    color: _.selectedResponse.hashCode == item.hashCode
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    padding: const EdgeInsetsGeometry.symmetric(
                      horizontal: 12, vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: Theme.of(context).textTheme.bodyLarge!.fontSize! * 4.5,
                              child: Text(
                                item.requestOptions?.method.toUpperCase() ?? '',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: getMethodFontColor(context, item.requestOptions?.method ?? ''),
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8,),

                            if (item.isRequesting)
                              ...[
                                SpinKitCircle(
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                  size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.3,
                                )
                              ]
                            else
                              ...[
                                SizedBox(
                                  width: Theme.of(context).textTheme.bodyLarge!.fontSize! * 2,
                                  child: Text(
                                    item.response?.statusCode?.toString() ?? '',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: getStatusCodeFontColor(context, item.response?.statusCode),
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 20,),

                                Text(
                                  durationStr,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),

                                const Expanded(child: SizedBox.shrink()),

                                if (constraints.maxWidth > 433)
                                  Text(
                                    DateUtil.getDateStrByDateTime(item.requestStartTime, format: DateFormat.DEFAULT) ?? '',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                          ],
                        ),
                        Text(
                          (item.requestOptions?.uri.toString() ?? '').replaceFirst(AddressService.host, ''),
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (item.uuid == _.mouseEnterKey)
                Positioned(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    height: Theme.of(context).textTheme.bodyLarge!.fontSize! * 4,
                    child: Container(
                      color: item.hashCode == _.selectedResponse.hashCode
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).hoverColor,
                      child: MineIconButton(
                        icon: FluentIcons.delete_16_regular,
                        tooltip: '删除',
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8
                        ),
                        onPressed: (){
                          controller.responseOnDeleted(item);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget detailWidget(BuildContext context, DioInspectorController _){
    if (_.selectedResponse == null){
      return const SizedBox.shrink();
    }
    DioLogDataModel model = _.selectedResponse!;
    String durationStr = model.requestDuration == null
        ? ''
        : model.requestDuration!.inMilliseconds < 1000
        ? '${model.requestDuration!.inMilliseconds}ms'
        : model.requestDuration!.inSeconds < 60
        ? '${(model.requestDuration!.inMilliseconds / 1000).toStringAsFixed(2)}s'
        : '${(model.requestDuration!.inMilliseconds / 1000 / 60).toStringAsFixed(2)}min';

    int responseTotalSize = (model.responseHeadSize ?? 0) + (model.responseBodySize ?? 0);
    String responseTotalSizeStr = responseTotalSize <= 0
        ? '0B'
        : responseTotalSize < 1024
        ? '${responseTotalSize.toStringAsFixed(2)}B'
        : responseTotalSize < 1024 * 1024
        ? '${(responseTotalSize / 1024).toStringAsFixed(2)}KB'
        : responseTotalSize < 1024 * 1024 * 1024
        ? '${(responseTotalSize / 1024 / 1024).toStringAsFixed(2)}MB'
        : '${(responseTotalSize / 1024 / 1024 / 1024).toStringAsFixed(2)}GB';

    String requestBody = model.requestBodyStrFormat ?? '';
    String responseBody = model.responseBodyStrFormat ?? '';

    String uri = (model.requestOptions?.uri.toString() ?? '').replaceFirst(AddressService.host, '');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints){
        if (constraints.maxWidth < 100){
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsetsGeometry.only(left: 2),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsGeometry.only(
                  top: 4, right: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      model.requestOptions?.method.toUpperCase() ?? '',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: getMethodFontColor(context, model.requestOptions?.method ?? ''),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8,),
                    Expanded(
                      child: Tooltip(
                        message: uri,
                        child: Text(
                          uri,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4,),

                    copyBtnWidget(
                        context,
                        uri
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsetsGeometry.only(
                  top: 2, right: 8, bottom: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${model.response?.statusCode?.toString() ?? ''}'
                            '   ${model.response?.statusMessage ?? ''}'
                            '   $durationStr'
                            '   $responseTotalSizeStr',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: getStatusCodeFontColor(context, model.response?.statusCode),
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 4),

                    MineIconButton(
                      icon: _.isAllExpanded
                          ? Icons.arrow_circle_up_outlined
                          : Icons.arrow_circle_down_outlined,
                      tooltip: _.isAllExpanded ? '全部收起' : '全部展开',
                      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                      onPressed: (){
                        controller.setAllExpanded(!_.isAllExpanded);
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: ExpansionPanelList(
                    dividerColor: Colors.transparent,
                    expandedHeaderPadding: const EdgeInsets.only(),
                    expansionCallback: (int index, bool boolValue){
                      controller.expansionCallback(index, boolValue);
                    },
                    children: List.generate(_.isExpandedList.length, (index){
                      return ExpansionPanel(
                        isExpanded: _.isExpandedList[index],
                        canTapOnHeader: true,
                        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          String title = '';
                          String copyStr = '';
                          switch (index){
                            //region
                            case 0:
                              title = '请求头';
                              copyStr = model.requestOptions?.headers.toString() ?? '';
                              break;
                            case 1:
                              title = '请求体';
                              copyStr = requestBody;
                              break;
                            case 2:
                              title = '响应头';
                              copyStr = model.response?.headers.toString() ?? '';
                              break;
                            case 3:
                              title = '响应体';
                              copyStr = responseBody;
                              break;
                            //endregion
                          }
                          return Row(
                            children: [
                              const SizedBox(width: 6,),
                              Expanded(
                                child: Text(
                                  title,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6,),

                              copyBtnWidget(context, copyStr),
                            ],
                          );
                        },
                        body: index == 0
                            ? headWidget(context, model.requestOptions?.headers ?? {})
                            : index == 1
                            ? bodyWidget(context, requestBody)
                            : index == 2
                            ? headWidget(context, model.response?.headers.map ?? {})
                            : index == 3
                            ? bodyWidget(context, responseBody)
                            : const SizedBox.shrink(),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget headWidget(BuildContext context, Map<String, dynamic> headers){
    if (headers.isEmpty){
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsetsGeometry.all(4),
      child: Column(
        children: headers.entries.map((e) {
          return Padding(
            padding: const EdgeInsetsGeometry.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  alignment: Alignment.topLeft,
                  child: SelectableText(
                    e.key,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: SelectableText(
                    e.value?.toString() ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget bodyWidget(BuildContext context, String bodyStr){
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsetsGeometry.all(4),
      child: SelectableText(
        bodyStr,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      /*child: Container(
        constraints: BoxConstraints(
          maxHeight: 500,
        ),
        child: JsonPreview(
          data: bodyStr,
        ),
      ),*/
    );
  }

  Widget copyBtnWidget(BuildContext context, String copyStr){
    return MineIconButton(
      icon: Icons.copy,
      tooltip: '复制',
      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: copyStr));
      },
    );
  }

  Color getMethodFontColor(BuildContext context, String method) {
    switch (method.toLowerCase()){
      case 'get':
        return AppColors.dioGetColor;
      case 'post':
        return AppColors.dioPostColor;
      case 'put':
        return AppColors.dioPutColor;
      case 'patch':
        return AppColors.dioPatchColor;
      case 'delete':
        return AppColors.dioDeleteColor;
      case 'head':
        return AppColors.dioHeadColor;
      case 'options':
        return AppColors.dioOptionsColor;
      default:
        return Theme.of(context).textTheme.bodyLarge!.color!;
    }
  }

  Color getStatusCodeFontColor(BuildContext context, int? statusCode){
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      return AppColors.runColor;
    }
    else if (statusCode != null && statusCode >= 300 && statusCode < 400) {
      return AppColors.standByColor;
    }
    //else if (statusCode != null && statusCode >= 400 && statusCode < 500) {
    //  return AppColors.stopColor;
    //}
    else if (statusCode != null && statusCode >= 500) {
      return AppColors.stopColor;
      //return Colors.purple;
    }
    return Theme.of(context).textTheme.bodyLarge!.color!;
  }

}