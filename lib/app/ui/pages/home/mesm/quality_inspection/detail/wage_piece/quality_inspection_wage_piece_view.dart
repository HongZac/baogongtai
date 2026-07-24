import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dfs_item_model.dart';
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/wage_piece/quality_inspection_wage_piece_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///质量巡检首页 => 工序计划单/产品工艺路线 => 工资计件页面
class QualityInspectionWagePieceView extends GetView<QualityInspectionWagePieceController>{
  const QualityInspectionWagePieceView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QualityInspectionWagePieceController>(builder: (_){
      return Container(
        alignment: Alignment.topCenter,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            interactive: false,
            thumbVisibility: WidgetStateProperty.all(false),
            trackVisibility: WidgetStateProperty.all(false),
            thumbColor: WidgetStateProperty.all(Colors.transparent),
            trackColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Column(
            children: [
              Material(
                elevation: 4,
                surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                shadowColor: Colors.transparent,
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: List.generate(_.fieldList.length, (index) {
                      DFSItemModel item = _.fieldList[index];
                      if (!item.isVisible){
                        return const SizedBox.shrink();
                      }
                      return Expanded(
                        flex: item.width,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          alignment: Alignment(item.alignmentX, item.alignmentY),
                          child: Text(
                              item.title,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: _.workBillEntryList.length,
                  controller: _.workBillEntryScrollController,
                  itemBuilder: (BuildContext context, int index){
                    MoWorkBillEntryModel item = _.workBillEntryList[index];
                    return Column(
                      children: [
                        Container(
                          height: 55,
                          color: item.opId == _.opId ? Theme.of(context).colorScheme.primaryContainer : null,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: List.generate(_.fieldList.length, (index2) {
                              DFSItemModel dFSItemModel = _.fieldList[index2];
                              if (!dFSItemModel.isVisible){
                                return const SizedBox.shrink();
                              }
                              String content = '';
                              switch (dFSItemModel.enTitle){
                                case 'sequ':
                                  content = (item.sequ ?? '').toString();
                                  break;
                                case 'opCode':
                                  content = item.opCode ?? '';
                                  break;
                                case 'opName':
                                  content = item.opName ?? '';
                                  break;
                                case 'qty':
                                  content = NumFormatUtil.qtyFormatConverter((item.qty ?? '').toString());
                                  break;
                                case 'pieceRate':
                                  if (item.id.isEmpty){
                                    content = '总计：${NumFormatUtil.qtyFormatConverter(_.totalPieceRate.toString(), decimal: 2)}';
                                  }
                                  else {
                                    content = NumFormatUtil.qtyFormatConverter((item.pieceRate ?? 0).toString(), decimal: 2);
                                  }
                                  break;
                                case 'nowOpPieceRate':
                                  if (item.opId == _.opId){
                                    content = NumFormatUtil.qtyFormatConverter(_.nowOpPieceRate.toString(), decimal: 2);
                                  }
                                  break;
                                case 'opRate':
                                  if (item.id.isEmpty){
                                    content = '总计：${NumFormatUtil.qtyFormatConverter(_.totalRate.toString(), decimal: 2)}';
                                  }
                                  else {
                                    content = NumFormatUtil.qtyFormatConverter(((item.qty ?? 0) * (item.pieceRate ?? 0)).toString(), decimal: 2);
                                  }
                                  break;
                                case 'nowOpRate':
                                  if (item.opId == _.opId){
                                    content = NumFormatUtil.qtyFormatConverter(_.nowOpRate.toString(), decimal: 2);
                                  }
                                  break;
                              }
                              return Expanded(
                                flex: dFSItemModel.width,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  alignment: Alignment(dFSItemModel.alignmentX, dFSItemModel.alignmentY),
                                  child: Text(
                                    content,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                    textAlign: dFSItemModel.alignmentX == -1
                                        ? TextAlign.start
                                        : dFSItemModel.alignmentX == 0
                                        ? TextAlign.center
                                        : TextAlign.end,
                                  ),
                                ),
                              );
                            }),
                          )
                        ),

                        if (index != _.workBillEntryList.length - 1)
                          Divider(indent: 0, endIndent: 0, color: Theme.of(context).colorScheme.outlineVariant.withAlpha(102),),
                      ],
                    );
                  }
                ),
              )
            ],
          ),
        ),
      );
    }, initState: (GetBuilderState<QualityInspectionWagePieceController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<QualityInspectionWagePieceController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }

}