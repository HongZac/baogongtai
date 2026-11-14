import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/attach_view/attach_utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/inventory_attach/inventory_attach_controller.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///产品图纸查询 首页
class InventoryAttachPage extends BaseFormWithPageDataPage<InventoryAttachController, InventoryModel>{

  @override
  Widget headWidget(BuildContext context, InventoryAttachController _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              runSpacing: 8, spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_.isDataByScan)
                  _.resetScanWidget(context),
                if (_.isShowSearchInputBox)
                  _.searchInputWidget(context, needOpenBtn: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget dataItem(BuildContext context, InventoryAttachController _, InventoryModel item){
    InventoryAttachController _ = Get.find<InventoryAttachController>();
    List<InitialPreviewConfigModel> attachList = [];
    List<String> urlList = [];
    List<DMDocumentModel> dmDocumentList = _.attachListMap[item.invID ?? ''] ?? [];
    if (dmDocumentList.isNotEmpty){
      for (var element in dmDocumentList) {
        attachList.addAll(element.initialPreviewConfig ?? []);
        urlList.addAll(element.initialPreview ?? []);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${item.invName ?? ''}【${item.engineerFigNo ?? ''}】：',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4,),
        if (attachList.isNotEmpty)
          Wrap(
            spacing: 12, runSpacing: 12,
            children: List.generate(attachList.length, (index){
              String url = urlList.asMap()[index] ?? '';
              return SizedBox(
                width: 257, height: 266,
                child: attachItem(context, _, attachList[index], url),
              );
            }).toList(),
          ),
        const SizedBox(height: 8,),
      ],
    );
  }
  Widget attachItem(BuildContext context, InventoryAttachController _, InitialPreviewConfigModel item, String url){
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

  @override
  Widget footWidget(BuildContext context, InventoryAttachController _) {
    return Row(
      children: [
        const SizedBox(width: 4,),
        RichText(
          text: TextSpan(
            text: '共查询出 ',
            style: Theme.of(context).textTheme.bodyLarge,
            children: [
              TextSpan(
                text: _.total.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43
                )
              ),
              const TextSpan(text: ' 个产品，当前页共 '),
              TextSpan(
                text: _.nowPageAttachTotal.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43
                )
              ),
              const TextSpan(text: ' 条附件记录'),
            ]
          ),
          textScaler: TextScaler.linear(FontFamilyConfig.textScale),
        ),
        const Expanded(child: SizedBox.shrink()),
        const SizedBox(width: 8,),

        OutlinedButton(
          onPressed: () async{
            await controller.pageChanged(pageIndex: 1);
            _.update();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FluentIcons.arrow_sync_circle_16_regular,
                color: IconTheme.of(context).color,
                size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
              ),
              const SizedBox(width: 4,),
              Text(
                '刷新',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ],
          ),
        ),
        const SizedBox(width: 8,),

        OutlinedButton(
          onPressed: () async{
            if (_.nowPage == 1 || _.nowPage == 0 || _.totalPage == 0){
              ToastNotification(Get.overlayContext!).warn("当前已经是首页！");
              return;
            }
            await controller.pageChanged(pageIndex: _.dataListPageConfig.page - 1);
            _.update();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FluentIcons.arrow_circle_left_12_regular,
                color: IconTheme.of(context).color,
                size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
              ),
              const SizedBox(width: 4,),
              Text(
                '上一页',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ],
          ),
        ),
        const SizedBox(width: 16,),

        Text(
          '${_.nowPage} / ${_.totalPage}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(width: 16,),

        OutlinedButton(
          onPressed: () async{
            if (_.nowPage == _.totalPage || _.nowPage == 0 || _.totalPage == 0){
              ToastNotification(Get.overlayContext!).warn("当前已经是最后一页！");
              return;
            }
            await controller.pageChanged(pageIndex: _.dataListPageConfig.page + 1);
            _.update();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FluentIcons.arrow_circle_right_12_regular,
                color: IconTheme.of(context).color,
                size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
              ),
              const SizedBox(width: 4,),
              Text(
                '下一页',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ],
          ),
        ),
        const SizedBox(width: 4,),
      ],
    );
  }

}