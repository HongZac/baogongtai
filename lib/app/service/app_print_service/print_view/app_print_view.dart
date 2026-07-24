import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/service/app_print_service/print_view/app_print_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';


///APP 远程打印服务 主页面
class AppPrintView extends GetView<AppPrintController>{

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppPrintController>(builder: (_){
      return Padding(
        padding: const EdgeInsets.all(0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints){
            double expandedBodyHeight = (constraints.maxHeight / 2) - 56;
            double allBodyHeight = expandedBodyHeight * 2;
            double expansionPanel0BodyHeight = _.appPrintService.printServiceList.length * 72;
            if (expansionPanel0BodyHeight > (_.isExpandedList[1] ? expandedBodyHeight : allBodyHeight)){
              expansionPanel0BodyHeight = _.isExpandedList[1] ? expandedBodyHeight : allBodyHeight;
            }
            double expansionPanel1BodyHeight = allBodyHeight - (_.isExpandedList[0] ? expansionPanel0BodyHeight : 0);
            return SingleChildScrollView(
              child: ExpansionPanelList(
                dividerColor: Colors.transparent,
                expandedHeaderPadding: const EdgeInsets.only(),
                expansionCallback: (int index, bool boolValue){
                  _.isExpandedList[index] = boolValue;
                  controller.update();
                },
                children: [
                  ExpansionPanel(
                    isExpanded: _.isExpandedList[0],
                    canTapOnHeader: true,
                    backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                    headerBuilder: (BuildContext context, bool isExpanded){
                      return Row(
                        children: [
                          const SizedBox(width: 8,),
                          Expanded(
                            child: Text(
                              '打印机信息列表',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(width: 8,),

                          FilledButton(
                            onPressed: () async {
                              await controller.addNewAppPrintService();
                            },
                            child: Text(
                              '新增',
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    body: Container(
                      height: expansionPanel0BodyHeight,
                      child: ListView(
                        children: _.appPrintService.printServiceList.map((e) {
                          return ListTile(
                            title: Text(
                              '${e.workBench ?? ' '}【${e.printerName ?? ''}】',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await controller.editNewAppPrintService(e);
                                  },
                                  style: ButtonStyle(
                                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14, horizontal: 14)),
                                  ),
                                  child: Text(
                                    '修改',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24,),

                                TextButton(
                                  onPressed: () async {
                                    await controller.removeNewAppPrintService(e);
                                  },
                                  style: ButtonStyle(
                                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14, horizontal: 14)),
                                  ),
                                  child: Text(
                                    '删除',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24,),

                                TextButton(
                                  onPressed: () async {
                                    await controller.registerOrCancel(e);
                                  },
                                  style: ButtonStyle(
                                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14, horizontal: 14)),
                                  ),
                                  child: Text(
                                    e.isRegister ? '取消服务' : '启动服务',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  ExpansionPanel(
                    isExpanded: _.isExpandedList[1],
                    canTapOnHeader: true,
                    backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                    headerBuilder: (BuildContext context, bool isExpanded){
                      return Row(
                        children: [
                          const SizedBox(width: 8,),
                          Expanded(
                            child: Text(
                              '打印任务列表',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      );
                    },
                    body: Container(
                      height: expansionPanel1BodyHeight,
                      child: ListView(
                        children: _.appPrintService.printDataList.map((e) {
                          return GetBuilder<ModelWithGetxController<PrintTaskModel>>(tag: e.model.tag, builder: (item){
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(
                                    '${e.model.title ?? ''}',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: e.model.printServiceEntity == null ?
                                          const SizedBox.shrink() :
                                          Text(
                                            '${e.model.printServiceEntity?.workBench ?? ' '}【${e.model.printServiceEntity?.printerName ?? ''}】',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: Theme.of(context).colorScheme.outline
                                            ), maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4,),
                                        Expanded(
                                          child: Text(
                                            '接收时间：${DateUtil.getDateStrByDateTime(e.model.acceptDate,
                                                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? ''}',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: Theme.of(context).colorScheme.outline
                                            ), maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: '已打印 ',
                                          style: Theme.of(context).textTheme.bodyLarge,
                                          children: [
                                            TextSpan(
                                              text: e.model.nprint.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600
                                              )
                                            ),
                                            const TextSpan(text: ' 次'),
                                          ]
                                        ),
                                      ),
                                      const SizedBox(width: 32,),

                                      Container(
                                        width: 130,
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: e.model.isPrinting
                                              ? null
                                              : () async {
                                            controller.appPrintService.onPrint(e);
                                          },
                                          style: ButtonStyle(
                                            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14, horizontal: 14)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              if (!e.model.isPrinting)
                                                ...[
                                                  Icon(
                                                    Icons.print_outlined,
                                                    size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                                  ),
                                                  const SizedBox(width: 2,),
                                                  Text(
                                                    '打印',
                                                    style: TextStyle(
                                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                                    ),
                                                  ),
                                                ]
                                              else
                                                ...[
                                                  SpinKitCircle(
                                                    color: Theme.of(context).colorScheme.outline,
                                                    size: 18,
                                                  ),
                                                  Text(
                                                    '正在打印...',
                                                    style: TextStyle(
                                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                                    ),
                                                  ),
                                                ]
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Divider(),
                              ],
                            );
                          });
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }, initState: (GetBuilderState<AppPrintController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<AppPrintController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }

}