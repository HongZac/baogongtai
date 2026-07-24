import 'package:basement/item_model.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_interface.dart';
import 'package:desktop/app/ui/pages/home/home_controller.dart';
import 'package:desktop/app/ui/pages/root/root_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///基本页
abstract class BaseFormController
    extends GetxController
    with GetSingleTickerProviderStateMixin,
        BaseFormInterface,
        WidgetsBindingObserver {

  final rootCtl = Get.find<RootController>();
  final HomeController homeController = Get.find<HomeController>();
  final appService = Get.find<AppService>();
  final dataService = Get.find<DataService>();
  ///单据系统对象 xt_objects，用来取系统对象数据（系统对象、查询条件列表、表格列名列表、打印文件、权限项列表、着色器列表），
  final int progId;
  ///编辑界面的对象（通过[objectItem.commandLineMap]获取）
  int? mxProgid;
  ///获取的系统对象相关属性
  EditFormItem objectItem = EditFormItem();

  ///执行 onReady(); 时，是否使用加载数据弹窗
  final bool isShowProgressDialogInOnReady;

  ///是否获取系统对象
  final bool isNeedGetObjectItem;

  ///需要额外通过 FormRepository().getSystemAttribute() 获取的系统参数列表
  ///
  /// {"ItemCode": "SystemCode"}
  final Map<String, String> accItemMap = {};
  ///通过 FormRepository().getSystemAttribute() 获取的系统参数列表
  final Map<String, AttributeEntity?> accInformationMap = {};

  final GlobalKey contentWidgetKey = GlobalKey();
  Size? contentWidgetSize;
  Size? windowSize;

  bool isLoading = false;


  BaseFormController({
    required this.progId,
    this.isShowProgressDialogInOnReady = true,
    this.isNeedGetObjectItem = true,
  });


  @override
  void onInit() {
    super.onInit();

    ///注册观察者
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  Future<void> onReady() async {
    super.onReady();
    if (isShowProgressDialogInOnReady){
      ProgressDialogUtil.showProgressDialog();
    }

    ///读取系统对象值
    var res1 = await _asyncSystemData();

    accItemMap.clear();
    accItemMap.addAll(setAccItemMap());
    accInformationMap.clear();
    for (var key in accItemMap.keys){
      String systemCode = accItemMap[key]!;
      String itemCode = key;
      var res = await FormRepository().getSystemAttribute(objectItem.progid ?? -1, systemCode, itemCode);
      AttributeEntity? item;
      if (res.isSuccess){
        item = res.data;
      }
      accInformationMap.addAll({key: item});
    }

    ///窗体数据创建过程
    var res2 = await initializeForm();

    update();
    if (isShowProgressDialogInOnReady){
      if (!res1 || !res2){
        ProgressDialogUtil.close();
      }
      ProgressDialogUtil.update(value: 1);
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      if (GetPlatform.isAndroid){
        getContentWidgetSize();
      }
    });

  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      if (GetPlatform.isAndroid){
        getContentWidgetSize();
      }
    });
  }

  ///读取表单的系统对象数据
  Future<bool> _asyncSystemData() async {
    if (isNeedGetObjectItem && progId != -1){
      var res = await FormRepository().getFormSystem(progId);
      if (!res.isSuccess) {
        ToastNotification(Get.overlayContext!).error('获取系统对象时出错：${res.message}');
        return false;
      }
      objectItem = res.data;
      if (objectItem.commandLineMap.isNotEmpty && objectItem.commandLineMap['mxprogid'] != null){
        mxProgid = int.tryParse(objectItem.commandLineMap['mxprogid']!);
      }
      return res.isSuccess;
    }
    return true;
  }

  /// {"ItemCode": "SystemCode"}
  Map<String, String> setAccItemMap(){
    return {};
  }

  ///对话框按钮事件 （返回 true 关闭弹窗，）
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async {
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

  void getContentWidgetSize() {
    try {
      ///如果窗体大小没有变化，则不用重新计算 contentWidget 区域大小
      if (windowSize != Get.size){
        windowSize = Get.size;
        final RenderBox renderBox = contentWidgetKey.currentContext!.findRenderObject() as RenderBox;
        final Size size = renderBox.size;
        if (contentWidgetSize?.height != size.height
            || contentWidgetSize?.width != size.width){
          contentWidgetSize = size;
          update();
        }
      }
    } catch(e){
      PrintUtil.printDebug(e.toString());
    }
  }

  @override
  void onClose() {
    ///移除观察者
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

}