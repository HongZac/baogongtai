import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/ui/pages/attach_view/attach_utils.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'attach_controller.dart';


///附件与图片查看页面
class AttachPage extends GetView<AttachController>{

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttachController>(builder: (_) {
      return Column(
        children: [
          const SizedBox(height: 4,),
          if (_.showAppBar)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 250,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 8),
                  child: const BackOutlinedButton(),
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
                const SizedBox(width: 250,),
              ],
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              child: _.attachList.isNotEmpty ?
              GridView.builder(
              shrinkWrap: false,
              semanticChildCount: 0,
              addAutomaticKeepAlives: true,
              padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 42),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                childAspectRatio: 0.98,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _.attachList.length,
              itemBuilder: (BuildContext context, int index){
                InitialPreviewConfigModel item = _.attachList[index];
                String url = _.attachInitialPreviewMap[item.key ?? ''] ?? '';
                return attachItem(context, _, item, url);
              }
              ):
              const SizedBox.shrink(),
            ),
          )
        ],
      );
    }, initState: (GetBuilderState<AttachController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<AttachController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }

  Widget attachItem(BuildContext context, AttachController _, InitialPreviewConfigModel item, String url){
    return Material(
      elevation: 1,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: InkWell(
        onTap: () async {
          await AttachUtils().getDetail(item, url);
        },
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.6,
              child: Material(
                elevation: 10,
                shadowColor: Colors.transparent,
                surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)
                ),
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4)
                      )
                  ),
                  child: AttachUtils.buildImage(
                    context, item, url,
                    pdfFirstPage: _.pdfControllerList.firstWhereOrNull((element) => element.keyName == item.key)?.imageUint8List,
                    updateVoidCallback: (){
                      controller.update();
                    }
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        item.caption ?? '',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600
                        ),
                        maxLines: 2,overflow: TextOverflow.ellipsis
                    ),
                    const Expanded(child: SizedBox.shrink()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            DateUtil.getDateStrByDateTime(item.createDate,
                                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,overflow: TextOverflow.ellipsis
                        ),
                        Text(
                            '${((item.size ?? 0) / 1024 / 1024).toStringAsFixed(2)}MB',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,overflow: TextOverflow.ellipsis
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}