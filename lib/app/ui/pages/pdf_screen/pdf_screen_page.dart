import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/ui/pages/pdf_screen/pdf_screen_controller.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/pdf_view/pdf_view.dart';
import 'package:desktop/app/ui/widget/pdf_view/pdf_view_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///PDF的查看和打印页面
class PdfScreenPage extends GetView<PdfScreenController>{

  final String extraTag;

  @override
  String? get tag => extraTag.isNotEmpty ? extraTag : null;


  const PdfScreenPage({
    super.key,
    this.extraTag = '',
  });


  @override
  Widget build(BuildContext context) {
    return GetBuilder<PdfScreenController>(tag: tag, builder: (_){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8,),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 260,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: BackOutlinedButton(
                  onPressed: _.onPressed,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    _.pageTitle,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
              Container(
                  width: 260,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 12),
                  child: toolWidget(context, _),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
              child: childWidget(context, _),
          ),
        ]
      );
    }, initState: (GetBuilderState<PdfScreenController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<PdfScreenController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }

  Widget toolWidget(BuildContext context, PdfScreenController _){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MineIconButton(
          onPressed: () async{
            if (_.pdfViewDataManager != null){
              _.pdfViewDataManager!.rotate(true);
            }
          },
          tooltip: '顺时针旋转',
          icon: Icons.rotate_90_degrees_cw_outlined,
          iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
        ),
        const SizedBox(width: 12,),

        MineIconButton(
          onPressed: () async{
            if (_.pdfViewDataManager != null){
              _.pdfViewDataManager!.rotate(false);
            }
          },
          tooltip: '逆时针旋转',
          icon: Icons.rotate_90_degrees_ccw_outlined,
          iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
        ),
        const SizedBox(width: 12,),

        MineIconButton(
          onPressed: () async{
            if (_.pdfViewDataManager != null){
              _.pdfViewDataManager!.zoomOnChanged(isZoomOut: true);
            }
          },
          tooltip: '缩小',
          icon: Icons.zoom_out,
          iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
        ),
        const SizedBox(width: 12,),

        MineIconButton(
          onPressed: () async{
            if (_.pdfViewDataManager != null){
              _.pdfViewDataManager!.zoomOnChanged(isZoomOut: false);
            }
          },
          tooltip: '放大',
          icon: Icons.zoom_in,
          iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
        ),
        const SizedBox(width: 12,),

        MineIconButton(
          onPressed: () async{
            await controller.pdfPrint();
          },
          tooltip: '打印',
          icon: Icons.print,
          iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
        ),
      ],
    );
  }

  Widget childWidget(BuildContext context, PdfScreenController _){
    if (!_.isInitData){
      return const SizedBox.shrink();
    }
    return PdfView(
      pdfFileUint8List: _.pdfUint8List,
      onLoaded: (PdfViewDataManager pdfViewDataManager) async {
        ///只有第一次 pdf 加载完成后才需要赋值
        if (_.pdfViewDataManager == null){
          _.pdfViewDataManager = pdfViewDataManager;
          ///在监听前，有些数据可能已经改变，这里先执行 pdfViewDataManagerListener
          _.pdfViewDataManagerListener();
          _.pdfViewDataManager!.addListener(_.pdfViewDataManagerListener);
        }
      },
    );
  }

}