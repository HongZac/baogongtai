import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_interface.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';


///序列号不间断接收
mixin SerialNumberScanInterface<T>
on BaseFormController,
    TcpSocketGetxListenerMixin<T>,
    SubmitInterface {

  ///序列号不间断接收列表
  final snContinuouslyReceivedList = [];

  bool _isLoading = false;


  ///序列号接收
  Future<void> _serialNumberScanOnBarcode({
    required String searchString,
    required String? invCCode,
  }) async {
    await Future.doWhile(() async {
      if (_isLoading || isLoading){ ///isLoading 等待报工结束
        await Future.delayed(const Duration(milliseconds: 1000));
        return true;
      }
      return false;
    });
    _isLoading = true;

    if (searchString.isEmpty){
      ToastNotification(Get.overlayContext!).warn('条码为空！');
      _isLoading = false;
      return;
    }

    if (submitType != AppConfig.serialNumberSubmit && submitType != AppConfig.singleBoxSerialNumberSubmit){
      TipsUtils.showTip(
        msg: '当前报工方式不需要选择生产序列号！',
        toastType: ToastType.warn,
      );
      _isLoading = false;
      return;
    }

    ///判断装箱情况
    if (submitType == AppConfig.singleBoxSerialNumberSubmit){
      String singleBoxQtyString = NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '';
      int? singleBoxQty = int.tryParse(singleBoxQtyString);
      String qtyString = NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '';
      int? qty = int.tryParse(qtyString);
      if (singleBoxQty == null || singleBoxQty < 1){
        TipsUtils.showTip(
          msg: '请输入单箱数量！',
          toastType: ToastType.warn,
        );
        _isLoading = false;
        return;
      }
      if (singleBoxQty == qty){
        TipsUtils.showTip(
          msg: '当前装箱已满，请提交报工！',
          toastType: ToastType.warn,
        );
        _isLoading = false;
        return;
      }
      if (qty != null && singleBoxQty < qty){
        TipsUtils.showTip(
          msg: '当前装箱已超，请检查！',
          toastType: ToastType.warn,
        );
        _isLoading = false;
        return;
      }
    }

    String string; ///解析后的生产序列号条码
    if (searchString.substring(0, 1) != '|') {
      string = searchString;
    }
    else {
      List<String> list = searchString.split('|');
      if (list.length < 3 || list[1] != 'X'){
        TipsUtils.showTip(
          msg: '序列号条码错误，请检查条码格式！',
          toastType: ToastType.warn,
        );
        _isLoading = false;
        return;
      }
      string = list[2];
    }

    void exit({int? errCode = 1, String? msg}) {
      if (errCode != null){
        serialNumberBarcodeMap.addAll({string: errCode});
      }
      if ((submitType == AppConfig.serialNumberSubmit || submitType == AppConfig.singleBoxSerialNumberSubmit)
          && autoCommitSubmit){
        setIsAutoCommitSuccess(false);
      }
      if (msg != null && msg.isNotEmpty){
        TipsUtils.showTip(
          msg: msg,
          toastType: ToastType.error,
        );
      }
      update();
      _isLoading = false;
      return;
    }

    MoOrderSNModel? orderSNModel;
    if (!isBMoSN){
      //region 报废序列号判断
      var scrapCheckRes = await scrapCheck(string);
      if (!scrapCheckRes){
        return exit(errCode: 7);
      }
      //endregion
      var snRes = await MoOrderSNRepository().getModel(string);
      if (!snRes.isSuccess){
        return exit(errCode: 2, msg: '获取序列号数据时出错：${snRes.message}！');
      }
      if (snRes.data.id.isEmpty){
        return exit(errCode: 3, msg: '查询不到该序列号！');
      }
      if ((snRes.data.moOrderId ?? '').isEmpty){
        return exit(errCode: 4, msg: '该序列号还未被分配任务单！');
      }
      if (snRes.data.enableMark != 1){
        return exit(errCode: 7, msg: '该序列号已失效！');
      }
      orderSNModel = snRes.data;
    }
    if (serialNumberCheckCodeList.isNotEmpty){ ///序列号校验码判断 todo 先暂时这样处理
      bool isEligibility(String cc){
        if (cc.startsWith('%') || cc.endsWith('%')){
          String serialNumberCheckCode = cc.replaceAll('%', '');
          if (serialNumberCheckCode.isNotEmpty){
            if (cc.startsWith('%') && cc.endsWith('%') && string.contains(serialNumberCheckCode)){
              return true;
            }
            else if (cc.startsWith('%') && string.endsWith(serialNumberCheckCode)){
              return true;
            }
            else if (cc.endsWith('%') && string.startsWith(serialNumberCheckCode)){
              return true;
            }
            else if (!cc.startsWith('%') && !cc.endsWith('%') && string == serialNumberCheckCode){
              return true;
            }
            return false;
          }
          return false;
        }
        else {
          ///判断正则表达式
          RegExp pattern = RegExp(cc);
          return pattern.hasMatch(string);
          return string.contains(pattern);
        }
        return false;
      }
      String? sCCRes = serialNumberCheckCodeList.firstWhereOrNull((cc){
        return serialNumberIsAllConditionMustBeMet ? !isEligibility(cc) : isEligibility(cc);
      });
      if (serialNumberIsAllConditionMustBeMet ? sCCRes != null : sCCRes == null){
        return exit(errCode: 8, msg: '该序列号与校验码不一致！\n当前效验码：${serialNumberCheckCodeList.join(', ')}');
      }
    }
    //region 判断该序列号是否已选中，已选中，则退出
    List<MoOrderSNModel> selectedList = orderSNAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
    List<String> serialNumberList = selectedList.map((e) => e.id).toList();
    if (serialNumberList.contains(string)){
      _isLoading = false;
      return;
    }
    //endregion

    ///任务单不一致，提示并退出
    if (!isBMoSN && orderSNModel != null && orderSNModel.moOrderId != null
        && orderSNModel.moOrderId != submitModel.moOrderId){
      return exit(errCode: 8, msg: '该序列号已被分配到其他任务单');
    }

    ///按单箱序列号报工，暂时可以不用没有工序
    ///这里两种报工方式分开判断
    if (submitType == AppConfig.serialNumberSubmit){
      ///有选中的工序，且只选中一条
      if ((submitModel.opId ?? '').isNotEmpty && submitModel.opId!.split(',').length == 1){
        ///写入序列号前，需要先判断序列号的报工情况：
        ///未通过，退出；
        ///通过，（如果是自动报工，且按序列号报工，则需要先提交前检查）选中扫描的序列号，写入报工数量（如果是自动报工，则执行报工前检查并报工，最后退出）；
        bool isCanContinue = await checkOpSerialNumber(string);
        if (!isCanContinue){
          ///[checkOpSerialNumber()] 中已写入 [serialNumberBarcodeMap]，也执行了 msg
          return exit(errCode: null);
        }
        if (autoCommitSubmit){
          Map<bool, String> checkMap = submitCheck(
            isPrint: false,
            invCCode: invCCode,
            needCheckQty: false,
            needCheckOp: false,
            needCheckSN: false,
          );
          if (checkMap.containsKey(false)){
            return exit(msg: checkMap[false]!);
          }
        }
        await orderSNAdapter?.validViewValue([orderSNModel ?? MoOrderSNModel(id: string, code: string)]);
        orderSNOnChanged([orderSNModel ?? MoOrderSNModel(id: string, code: string)]);
        if (autoCommitSubmit){
          ///此时所有报工数据都已填写完成，符合自动报工的条件，直接提交报工记录
          update();
          serialNumberBarcodeMap.addAll({string: 200});
          try {
            await saveSubmit(false, byAutoSubmit: true);
          }
          finally {
            _isLoading = false;
          }
          return;
        }
        serialNumberBarcodeMap.addAll({string: 200});
      }
      ///没有选中工序，或者选中多条
      else {
        ///清空选中的工序列表，并提示
        submitModel.workBillEntryId = null;
        submitModel.opId = null;
        submitModel.opName = null;
        submitModel.inspectFlag = null;
        submitModel.pieceRate = null;
        processAdapter?.clearSelection();
        return exit(msg: '当前没有选中工序，或选中多条，请重新选择工序后再次扫描序列号条码！');
      }
    }
    else if (submitType == AppConfig.singleBoxSerialNumberSubmit){
      List<MoOrderSNModel> list = orderSNAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
      list.add(orderSNModel ?? MoOrderSNModel(id: string, code: string));
      await orderSNAdapter?.validViewValue(list);
      orderSNOnChanged(list);
      if (singleBoxSerialNumberSubmitAutoCommit){
        ///数量符合，可以执行自动提交
        ///报工提交前检查，未通过则退出
        Map<bool, String> checkMap = submitCheck(
          isPrint: true,
          invCCode: invCCode,
          needCheckQty: true,
          needCheckOp: true,
          needCheckSN: true,
        );
        if (checkMap.containsKey(false)){
          return exit(msg: checkMap[false]!);
        }
        ///符合自动报工的条件，直接提交报工记录
        update();
        serialNumberBarcodeMap.addAll({string: 200});
        try {
          await saveSubmit(true, byAutoSubmit: true);
        }
        finally {
          _isLoading = false;
        }
        return;
      }
      serialNumberBarcodeMap.addAll({string: 200});
    }


    update();
    _isLoading = false;
  }

  ///序列号接收
  Future<void> Function({
    required String searchString,
    required String? invCCode,
  }) get serialNumberScanOnBarcode => _serialNumberScanOnBarcode;

}
