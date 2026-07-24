
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/model/dfs_item_model.dart';
import 'package:desktop/app/ui/pages/home/home_controller.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///质量巡检首页 => 工序计划单/产品工艺路线 => 工资计件页面
class QualityInspectionWagePieceController extends GetxController{

  final String moOrderId;

  final String opId;

  final double qualifiedQty;

  final List<MoWorkBillEntryModel> workBillEntryList = [];
  final ScrollController workBillEntryScrollController = ScrollController();

  ///当前工序 + 已经生产的工序 总工资
  double nowOpRate = 0;

  ///总工资
  double totalRate = 0;

  ///当前工序 + 已经生产的工序 当前总单价
  double nowOpPieceRate = 0;

  ///总单价
  double totalPieceRate = 0;

  final List<DFSItemModel> fieldList = [
    DFSItemModel(title: '顺序号', enTitle: 'sequ', alignmentX: 0),
    DFSItemModel(title: '工艺编号', enTitle: 'opCode', width: 2, alignmentX: 0),
    DFSItemModel(title: '工艺名称', enTitle: 'opName', width: 6),
    DFSItemModel(title: '生产数量', enTitle: 'qty', width: 3),
    DFSItemModel(title: '工艺定额', enTitle: 'pieceRate', width: 3), ///单价
    DFSItemModel(title: '当前总定额', enTitle: 'nowOpPieceRate', width: 3), ///当前总单价
    DFSItemModel(title: '计件工资', enTitle: 'opRate', width: 3, isVisible: false),
    DFSItemModel(title: '当前总工资', enTitle: 'nowOpRate', width: 3, isVisible: false),
  ];


  QualityInspectionWagePieceController({
    required this.moOrderId,
    required this.opId,
    required this.qualifiedQty,
  });

  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    ProgressDialogUtil.showProgressDialog();

    workBillEntryList.clear();
    nowOpRate = 0;
    totalRate = 0;
    nowOpPieceRate = 0;
    totalPieceRate = 0;
    var orderRes = await MoOrderRepository().getFormData(moOrderId);
    if (orderRes.isSuccess){
      if ((orderRes.data.wbId ?? '').isNotEmpty){
        var res1 = await MoWorkBillRepository().getFormData(orderRes.data.wbId, '', {}, 0);
        if (res1.isSuccess && res1.data.entryList.isNotEmpty) {
          workBillEntryList.addAll(res1.data.entryList);
        }
      }
      else if ((orderRes.data.productId ?? '').isNotEmpty) {
        var res = await MoRoutingRepository().getRoutingByInvId(orderRes.data.productId!);
        if (res.isSuccess && res.data.entryList.isNotEmpty){
          for (var element in res.data.entryList) {
            MoWorkBillEntryModel model = MoWorkBillEntryModel.fromJson(element.toJson());
            model.sequ = element.opSequ;
            model.pieceRate = element.opCost;
            model.qualifiedQty = qualifiedQty;
            workBillEntryList.add(model);
          }
        }
      }
    }
    workBillEntryList.sort((left, right) => left.sequ!.compareTo(right.sequ!));

    bool isNowOpRateCalcCompleted = false;
    for (var element in workBillEntryList) {
      totalPieceRate = totalPieceRate + (element.pieceRate ?? 0);
      totalRate = totalRate + (element.qty ?? 0) * (element.pieceRate ?? 0);
      if (!isNowOpRateCalcCompleted){
        nowOpPieceRate = nowOpPieceRate + (element.pieceRate ?? 0);
        nowOpRate = nowOpRate + (element.qty ?? 0) * (element.pieceRate ?? 0);
      }
      if (element.opId == opId){
        isNowOpRateCalcCompleted = true;
      }
    }

    ///在最后新增一条空白记录，用来显示总工资
    workBillEntryList.add(MoWorkBillEntryModel());

    update();

    ProgressDialogUtil.update(value: 1);
  }




}