import 'package:basement/service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/dio_inspector/dio_inspector_controller.dart';
import 'package:desktop/app/ui/pages/home/dio_inspector/dio_inspector_view.dart';
import 'package:desktop/app/ui/pages/home/log_inspector/log_inspector_controller.dart';
import 'package:desktop/app/ui/pages/home/log_inspector/log_inspector_view.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/command_bar.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/scan_gun/scan_gun_listener_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'home_controller.dart';


///主框架页
class HomeView extends GetView<HomeController> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (_){
      return GetRouterOutlet.builder(builder: (context, delegate, currentRoute) {
        /*if (Get.width <= 780 || Get.height <= 780){ /// 1024 768
          return const SizedBox.shrink();
        }*/
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (GetPlatform.isAndroid){
              ///点击空白关闭软键盘
              FocusManager.instance.primaryFocus?.unfocus();
              ///全屏，关闭状态栏
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
            }
          },
          child: contentWidget(context, _),
        );
      });
    });
  }

  Widget contentWidget(BuildContext context, HomeController _){
    return Row(
      children: [
        ///左侧导航栏
        if (_.destinations.length < 2)
          Container(
            width: controller.minExtendedWidth + 14,
            color: NavigationRailTheme.of(context).backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                const SizedBox(height: 8,),
                navigationRailHeaderContent(context, _),
                const Expanded(child: SizedBox.shrink()),
                navigationRailFooterContent(context, _),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints){
              List<ChoiceChipModel> showList = [];
              List<ChoiceChipModel> hideList = [];
              double height = constraints.maxHeight;
              double headHeight = 8 + _.headerHeight + 5 + 8;
              double footHeight = _.isNavigationRailExtended ? (_.headerHeight + 13) : (_.minExtendedWidth + 16);
              _.canShowCount = (height - (headHeight + footHeight)) ~/ _.navigationRailItemHeight;
              if (_.canShowCount < _.destinations.length){
                showList.addAll(_.destinations.sublist(0, _.canShowCount - 1));
                showList.add(ChoiceChipModel(
                  keyName: 'more',
                  title: '更多',
                  icon: Icons.apps,
                ));
                hideList.addAll(_.destinations.sublist(_.canShowCount - 1));
              }
              else {
                showList.addAll(_.destinations);
              }

              return NavigationRail(
                minWidth: controller.minWidth,
                minExtendedWidth: controller.minExtendedWidth,
                selectedIndex: _.selectedIndex != null && _.selectedIndex! >= showList.length
                    ? showList.length - 1
                    : _.selectedIndex,
                extended: _.isNavigationRailExtended,
                onDestinationSelected: (int index){
                  controller.onDestinationSelected(showList[index], context: context, hideList: hideList);
                },
                destinations: List.generate(showList.length, (index) {
                  ChoiceChipModel item = showList[index];
                  return NavigationRailDestination(
                    padding: EdgeInsets.only(right: 8, left: 6, bottom: index < showList.length - 1 ? 6 : 0),
                    icon: Icon(
                      item.icon,
                      size: Theme.of(context).textTheme.labelLarge!.fontSize! * 1.43,
                    ),
                    label: Container(
                        margin: const EdgeInsets.only(left: 6, right: 24),
                        child: Text(
                          item.title,
                          style: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.copyWith(
                              fontSize:Theme.of(context).textTheme.titleMedium!.fontSize
                          ),
                        )
                    ),
                  );
                }).toList(),
                leading: navigationRailHeaderContent(context, _),
                trailing: Expanded(
                  child: navigationRailFooterContent(context, _)
                ),
              );
            },
          ),
        ///主内容
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints){
              Widget header = Container(
                height: _.headerHeight + 12,
                color: Theme.of(context).navigationRailTheme.backgroundColor,
                child: Row(
                  children: [
                    ///公司名称
                    const SizedBox(width: 4,),
                    Expanded(
                      child: Text(
                        controller.dataService.companyName,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8,),


                    ///任务说明
                    if (_.assignmentFun != null && constraints.maxWidth > 600)
                      MineIconButton(
                        onPressed: () async {
                          await controller.assignmentFun?.call();
                        },
                        tooltip: '任务说明',
                        padding: EdgeInsets.zero,
                        icon: Icons.edit_calendar_outlined,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color,
                      ),
                    if (_.assignmentFun != null && constraints.maxWidth > 600)
                      const SizedBox(width: 8,),

                    ///扫码
                    if (_.onBarcodeFun != null && constraints.maxWidth > 600)
                      ScanGunListenerWidget(
                        height: _.headerHeight,
                        maxWidth: 300,
                        onBarcodeFun: (String str) async {
                          //PrintUtil.printDebug(str);
                          await _.onBarcodeFun?.call(str);
                        },
                      ),
                      /*ScanGunHelper(
                        onBarcodeFunScanned: (String string) async {
                          await _.onBarcodeFun?.call(string);
                        }
                      ).scanGunBtn(
                        context,
                        iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color
                      ),*/

                    ///登录人信息
                    if (constraints.maxWidth > 900)
                      TextButton(
                        onPressed: () async{
                          await DialogUtils.showCustomDialog(
                            context,
                            isNeedConfirmBtn: false,
                            title: '登录信息',
                            onCancelName: '关闭',
                            initialWidth: 500,
                            initialHeight: 250,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TitleTextBoxWidget(
                                  title: '账号名',
                                  content: BaseService.profile.realName ?? '',
                                  width: 310,
                                  titleWidth: 100,
                                  titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
                                  contentStyle: Theme.of(Get.context!).textTheme.bodyLarge,
                                ),
                                TitleTextBoxWidget(
                                  title: '员工编号',
                                  content: BaseService.profile.objCode ?? '',
                                  width: 310,
                                  titleWidth: 100,
                                  titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
                                  contentStyle: Theme.of(Get.context!).textTheme.bodyLarge,
                                ),
                                TitleTextBoxWidget(
                                  title: '部门',
                                  content: BaseService.profile.depName ?? '',
                                  width: 310,
                                  titleWidth: 100,
                                  titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
                                  contentStyle: Theme.of(Get.context!).textTheme.bodyLarge,
                                ),
                                TitleTextBoxWidget(
                                  title: '岗位',
                                  content: BaseService.profile.postName ?? '',
                                  width: 310,
                                  titleWidth: 100,
                                  titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
                                  contentStyle: Theme.of(Get.context!).textTheme.bodyLarge,
                                ),
                              ],
                            )
                          );
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                              vertical: kIsWeb || GetPlatform.isWindows ? 14 : 8,
                              horizontal: 8,
                          )),
                        ),
                        child: Text(
                          '${BaseService.profile.realName}',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (constraints.maxWidth > 900)
                      SizedBox(
                        width: kIsWeb || GetPlatform.isWindows ? 8 : 16,
                      ),

                    ///网络状态
                    MineIconButton(
                      onPressed: () async {
                        await controller.webSocketSetting();
                      },
                      tooltip: '网络状态',
                      padding: EdgeInsets.zero,
                      icon: _.networkConnectionService.isNeedCheckNetwork
                          ? _.connectivityResult == ConnectivityResult.none
                          ? Icons.signal_wifi_connected_no_internet_4_outlined
                          : _.isSuccessOfInternetAccess
                          ? Icons.wifi
                          : Icons.signal_wifi_statusbar_connected_no_internet_4
                          : Icons.wifi_off_outlined,
                      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                      iconColor: _.isWebSocketConnected == true
                          ? Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color
                          : AppColors.errorColor,
                    ),
                    const SizedBox(width: 8,),

                    ///程序日志
                    MineIconButton(
                      onPressed: () async {
                        await DialogUtils.showCustomDialog<LogInspectorController, bool>(
                          context,
                          isMaximize: true,
                          title: '程序日志',
                          isNeedConfirmBtn: false,
                          contentPadding: const EdgeInsets.all(0),
                          content: const LogInspectorView(),
                          controller: LogInspectorController(),
                        );
                      },
                      tooltip: '查看程序日志'.tr,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      iconSize: Theme.of(Get.context!).appBarTheme.iconTheme!.size!,
                      icon: Icons.receipt_long_outlined,
                      iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color
                    ),
                    const SizedBox(width: 8,),

                    ///网络请求日志
                    MineIconButton(
                      onPressed: () async {
                        await DialogUtils.showCustomDialog<DioInspectorController, bool>(
                          context,
                          isMaximize: true,
                          title: '网络请求日志',
                          isNeedConfirmBtn: false,
                          contentPadding: const EdgeInsets.all(0),
                          content: const DioInspectorView(),
                          controller: DioInspectorController(),
                        );
                      },
                      tooltip: '网络日志'.tr,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      iconSize: Theme.of(Get.context!).appBarTheme.iconTheme!.size! * 1.2,
                      icon: FluentIcons.globe_sync_20_regular,
                      iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color
                    ),
                    const SizedBox(width: 18,),

                    Container(
                      width: kIsWeb || GetPlatform.isWindows
                          ? constraints.maxWidth > 900 ? 220 : 35
                          : constraints.maxWidth > 900 ? 145 : 35,
                      child: CommandBar(
                        isCompact: true,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
                        overflowItemBuilder: (void Function()? onPressed){
                          return CommandBarButton(
                            label: '',
                            icon: Icons.more_vert,
                            fontColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color,
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                            iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color,
                            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                            onPressed: onPressed,
                          );
                        },
                        primaryItems: _.commandBarList,
                      )
                    ),
                    if (kIsWeb || GetPlatform.isWindows)
                      const SizedBox(width: 8,),
                  ],
                ),
              );
              return Column(
                children: [
                  if (kIsWeb || GetPlatform.isWindows)
                    DragToMoveArea(
                      child: header,
                    )
                  else
                    header,
                  Expanded(
                    child: kDebugMode && Get.width < 900 ?
                    const SizedBox.shrink() :
                    _.destinations.isEmpty || _.selectedIndex == null ?
                    Center(
                      child: Text(
                        '请选择左侧的导航内容！',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ) :
                    GetRouterOutlet(
                      initialRoute: _.destinations[_.selectedIndex!].content,
                    ),
                  )
                ],
              );
            },
          )
        )
      ],
    );
  }


  Widget navigationRailHeaderContent(BuildContext context, HomeController _){
    Widget child = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _.headerHeight + 5,
      width: _.isNavigationRailExtended ? _.minExtendedWidth : _.minWidth,
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: _.headerHeight, width: _.headerHeight,
                child: MineIconButton(
                  onPressed: (){
                    controller.navigationRailExtendedChanged();
                  },
                  padding: const EdgeInsets.all(6),
                  tooltip: _.isNavigationRailExtended ? '收起' : '展开',
                  icon: Icons.menu,
                  iconSize: Theme.of(context).textTheme.titleMedium!.fontSize! * 1.5,
                  iconColor: Theme.of(context).brightness == Brightness.light
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (_.isNavigationRailExtended)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    child: Text(
                      '车间工作台',
                      style: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.copyWith(
                          fontSize:Theme.of(context).textTheme.titleMedium!.fontSize
                      ), maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  )
                ),
            ],
          ),
          const SizedBox(height: 4,),
          Divider(
            thickness: 1,
            indent: 0, endIndent: 0,
            color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).scaffoldBackgroundColor : null,
          ),
        ],
      )
    );
    return child;
  }

  Widget navigationRailFooterContent(BuildContext context, HomeController _){
    List<Widget> widgetList = [
      //region
      MineIconButton(
        onPressed: () async {
          await controller.appPrintService();
        },
        tooltip: 'APP 远程打印服务',
        padding: EdgeInsets.zero,
        icon: FluentIcons.document_print_20_regular,
        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
        iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color
      ),
      MineIconButton(
        onPressed: () async {
          await controller.serialComService();
        },
        tooltip: '串口设置',
        padding: EdgeInsets.zero,
        icon: FluentIcons.serial_port_16_regular,
        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
        iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color
      ),
      MineIconButton(
        onPressed: () async {
          await controller.tcpSocketService();
        },
        tooltip: 'TCP 设置',
        padding: EdgeInsets.zero,
        icon: Icons.compare_arrows,
        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
        iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color
      ),
      MineIconButton(
        onPressed: () async{
          await controller.setting();
        },
        tooltip: '全局设置',
        padding: EdgeInsets.zero,
        icon: FluentIcons.settings_20_regular,
        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
        iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color,
      ),
      //endregion
    ];
    Widget child = Container(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 200),
        height: _.isNavigationRailExtended
            ? _.headerHeight + 13
            : _.minExtendedWidth + 16,
        width: _.isNavigationRailExtended
            ? _.minExtendedWidth
            : _.headerHeight + 13,
        alignment: Alignment.center,
        child: Column(
          children: [
            Divider(
              thickness: 1,
              indent: 0, endIndent: 0,
              color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).scaffoldBackgroundColor : null,
            ),
            const SizedBox(height: 4,),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Wrap(
                  spacing: kIsWeb || GetPlatform.isWindows ? 18 : 0,
                  runSpacing: kIsWeb || GetPlatform.isWindows ? 18 : 0,
                  alignment: WrapAlignment.spaceBetween,
                  runAlignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: widgetList,
                ),
              ),
            ),
          ],
        ),
      )
    );
    return child;
  }

}