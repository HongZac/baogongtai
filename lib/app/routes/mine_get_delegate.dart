
import 'dart:io';

import 'package:basement/utils.dart';
import 'package:desktop/app/routes/app_pages.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/base/base_tab/base_tab_page.dart';
import 'package:desktop/app/ui/pages/home/base/interface/assignment_interface/assignment_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/home_controller.dart';
import 'package:desktop/app/ui/pages/home/home_view.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MineGetDelegate extends GetDelegate {

  MineGetDelegate({
    super.notFoundRoute,
    super.navigatorObservers,
    super.transitionDelegate,
    super.backButtonPopMode,
    super.preventDuplicateHandlingMode,
  });

  @override
  Future<bool> popRoute({
    Object? result,
    PopMode popMode = PopMode.Page,
  }) async {
    var res = await super.popRoute(result: result, popMode: popMode);
    if (res){
      writeLog('Observer popRoute');
      afterPop();
    }
    return res;
  }

  Future<T> toNamed<T>(String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) async {
    beforePush();
    ///通过 Get.toNamed 进入历史路由时，需要再执行一次 afterPop
    Future.delayed(const Duration(milliseconds: 150), (){
      afterPop();
    });
    var res = await super.toNamed(page, arguments: arguments, parameters: parameters);
    writeLog('Observer toNamed');
    return res;
  }


  //region

  ///页面返回后或是弹窗关闭后：
  ///
  ///扫码图标、任务说明图标重置成返回后的页面的数据；
  ///
  ///返回后的页面的串口监听打开；
  ///
  ///（如果还有弹窗，则等待一段时间后（等待弹窗关闭）再检测是否有弹窗，有则不执行）（这里有漏洞，不能同时打开两个串口监听的弹窗！！！）
  ///
  ///（如果是 tab，则取当前选定选项卡）
  ///
  ///在 Get.popRoute、Route.didPop 后使用
  void afterPop() {
    writeLog('Observer afterPop');
    void callback(){
      Widget? pageWidget;
      if (Get.rootDelegate.history.isNotEmpty){
        var page = Get.rootDelegate.history.last;
        if (page.currentPage?.binding != null) {
          pageWidget = page.currentPage?.page();
          if (pageWidget is HomeView){
            pageWidget = getHomeDestinationItemPage()?.page();
          }
        }
      }
      
      if (pageWidget != null){
        if (pageWidget is BaseTabPage){
          pageWidget = pageWidget.controller.tabPageView[pageWidget.controller.tabController.index];
        }

        if (pageWidget is BaseFormPage){
          try {
            var homeController = Get.find<HomeController>();

            if (pageWidget.controller is ScanInterface){
              homeController.onBarcodeFun = (String searchString) async {
                pageWidget as BaseFormPage;
                (pageWidget.controller as ScanInterface).onBarcode(searchString);
              };
            }
            else {
              homeController.onBarcodeFun = null;
            }

            if (pageWidget.controller is AssignmentInterface){
              homeController.assignmentFun = () async {
                pageWidget as BaseFormPage;
                (pageWidget.controller as AssignmentInterface).setAssignment();
              };
            }
            else {
              homeController.assignmentFun = null;
            }

            if (pageWidget.controller is SerialPortGetXListenerMixin){
              writeLog('${pageWidget} enableSerialPort true');
              (pageWidget.controller as SerialPortGetXListenerMixin).enableSerialPort = true;
            }

            if (pageWidget.controller is TcpSocketGetxListenerMixin){
              writeLog('${pageWidget} enableTcpSocket true');
              (pageWidget.controller as TcpSocketGetxListenerMixin).enableTcpSocket = true;
            }

          } catch (e){}
        }
      }
    }
    if (DialogUtils.isDialogOpen){
      Future.delayed(const Duration(milliseconds: 150), (){
        if (!DialogUtils.isDialogOpen){
          callback();
        }
      });
    }
    else {
      callback();
    }
  }

  ///进入到新页面前或是打开弹窗（内容弹窗）前：
  ///
  ///扫码图标、任务说明图标重置为 null；
  ///
  ///前一个页面禁止串口监听；
  ///
  ///（如果是 tab，则取当前选定选项卡）
  ///
  ///在 Get.toNamed、Route.didPush 前使用（通过 Get.toNamed 进入历史路由时，需要再执行一次 afterPop）
  Future<void> beforePush() async {
    writeLog('Observer beforePush');
    Widget? pageWidget;
    if (Get.rootDelegate.history.isNotEmpty){
      var page = Get.rootDelegate.history.last;
      if (page.currentPage?.binding != null) {
        pageWidget = page.currentPage?.page();
        if (pageWidget is HomeView){
          pageWidget = getHomeDestinationItemPage()?.page();
        }
      }
    }

    if (pageWidget != null) {
      if (pageWidget is BaseTabPage){
        pageWidget = pageWidget.controller.tabPageView[pageWidget.controller.tabController.index];
      }

      if (pageWidget is BaseFormPage) {
        try {
          var homeController = Get.find<HomeController>();
          homeController.onBarcodeFun = null;
          homeController.assignmentFun = null;
          if (pageWidget.controller is SerialPortGetXListenerMixin){
            writeLog('${pageWidget} enableSerialPort false beforePush');
            (pageWidget.controller as SerialPortGetXListenerMixin).enableSerialPort = false;
          }
          if (pageWidget.controller is TcpSocketGetxListenerMixin){
            writeLog('${pageWidget} enableTcpSocket false beforePush');
            (pageWidget.controller as TcpSocketGetxListenerMixin).enableTcpSocket = false;
          }
        } catch(e){}
      }
    }
  }

  ///前台构建时：
  ///
  ///扫码图标、任务说明图标重置成该页面的数据；
  ///
  ///该页面的串口监听打开；
  ///
  ///在 GetBuilder.initState 中使用
  ///
  Future<void> pageInitState(Object controller) async {
    writeLog('Observer pageInitState');
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        var homeController = Get.find<HomeController>();
        if (controller is ScanInterface){
          homeController.onBarcodeFun = (String searchString) async {
            controller.onBarcode(searchString);
          };
        }
        else {
          homeController.onBarcodeFun = null;
        }

        if (controller is AssignmentInterface){
          homeController.assignmentFun = () async {
            controller.setAssignment();
          };
        }
        else {
          homeController.assignmentFun = null;
        }

        if (controller is SerialPortGetXListenerMixin){
          writeLog('${controller} enableSerialPort true');
          controller.enableSerialPort = true;
        }

        if (controller is TcpSocketGetxListenerMixin){
          writeLog('${controller} enableTcpSocket true');
          controller.enableTcpSocket = true;
        }

        return false;
      } catch (e){
        return true;
      }
    });
  }

  ///前台销毁时：
  ///
  ///该页面禁止串口监听；
  ///
  ///在 GetBuilder.dispose 中使用
  ///
  Future<void> pageDispose(Object controller) async {
    writeLog('Observer pageDispose');
    try {
      if (controller is BaseFormController){
        ///这里不需要重置扫码图标、任务说明图标，新前台构建的时候会重置
        ///var homeController = Get.find<HomeController>();
        ///homeController.onBarcodeFun = null;
        ///homeController.assignmentFun = null;
        if (controller is SerialPortGetXListenerMixin){
          writeLog('${controller} enableSerialPort false pageDispose');
          (controller as SerialPortGetXListenerMixin).enableSerialPort = false;
        }
      }
    } catch (e){}
  }

  ///写入日志
  Future<void> writeLog(String str) async {
    //PrintUtil.printDebug(str);
    return;
    try {
      File testFile = File('${ShareStorageUtil.logDirectory!.path}\\'
          '${DateUtil.formatDateTime(DateTime.now().toString(), DateFormat.YEAR_MONTH_DAY)}.txt');
      await testFile.writeAsString(
          '${DateTime.now().toString()}: $str\n\n',
          mode: FileMode.append
      );
    } catch (e){
      PrintUtil.printDebug(e.toString());
    }
  }

  GetPage? getHomeDestinationItemPage(){
    GetPage? getPage;
    try {
      ///home页面加载完成后，路由不会指向当前导航页
      var homeController = Get.find<HomeController>();
      String routeName = homeController.destinations[homeController.selectedIndex!].content;
      String lastRoute = routeName.split('/').last;
      getPage = AppPages.pages.firstWhereOrNull(
              (element) => element.name == RoutePath.ROOT)?.children.firstWhereOrNull(
              (element) => element.name == RoutePath.HOME)?.children.firstWhereOrNull(
              (element) => element.name == '/$lastRoute');
    } catch(e){}
    return getPage;
  }

  //endregion

}