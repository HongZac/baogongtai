import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/mes_task_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/utils/sign_color_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产派工单列表页面
class MesTaskPage extends BaseFormWithPageDataPage<MesTaskController, MoTaskModel>{

  Widget headWidget(BuildContext context, MesTaskController _){
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              runSpacing: 8, spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_.isShowSignFilter)
                  _.signWrapWidget(context),
                if (_.isShowDepPicker)
                  _.depFilterInputWidget(context),
                if (_.isShowLinePicker)
                  _.lineFilterInputWidget(context),
                if (_.isShowDatePicker)
                  _.dateFilterInputWidget(context),
                if (_.isDataByScan)
                  _.resetScanWidget(context),
                if (_.isShowSearchInputBox)
                  _.searchInputWidget(context),
              ],
            ),
          ),
          settingWidget(context, _, top: kIsWeb || GetPlatform.isWindows ? 9 : 0),
          const SizedBox(width: 6,)
        ],
      ),
    );
  }

  @override
  Widget dataItem(BuildContext context, MesTaskController _, MoTaskModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () async{
            await controller.itemOnTap(item);
          },
          onDoubleTap: () async{
            await controller.itemOnDoubleTap(item);
          },
          onLongPress: () async{
            await controller.itemOnLongPress(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///产品附件查看
                    MineIconButton(
                      onPressed: () async{
                        await controller.itemInvAttach(item);
                      },
                      tooltip: '产品附件',
                      icon: Icons.picture_as_pdf_outlined,
                      iconSize: 60,
                      iconColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                    ),

                    ///产品名称 + 工序 + 按钮组 + 详细信息0
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SelectableText.rich(
                                  TextSpan(
                                    text: '【${item.invName ?? ''}】',
                                    children: [
                                      TextSpan(
                                        text: (item.opName ?? '').isEmpty
                                            ? ''
                                            : '【${item.opName ?? ''}】',
                                      ),
                                      TextSpan(
                                        text: item.status ?? '',
                                        style: TextStyle(
                                          color: SignColorUtil().getTaskSignColor(item.sign ?? 0),
                                        ),
                                      ),
                                      TextSpan(
                                        text: '（${NumFormatUtil.qtyFormatConverter((item.submitQty ?? 0).toString())}'
                                            '/'
                                            '${NumFormatUtil.qtyFormatConverter((item.assignQty ?? 0).toString())}）',
                                      ),
                                    ]
                                  ),
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600
                                  ),
                                  onTap: () async{
                                    await controller.itemOnTap(item);
                                  },
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(width: 8,),

                              _.commandBarWidget(
                                context,
                                commandBarList: _.taskCommandBarList,
                                item: item,
                                btnPadding: kIsWeb || GetPlatform.isWindows
                                    ? const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                                    : const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                isExpanded: item.isExpanded,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 4),
                            constraints: BoxConstraints(
                              minHeight: 40,
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.end,
                              runSpacing: 4, spacing: 6,
                              children: _.getFieldList(
                                context,
                                infoFormList: _.taskListInfoFormListMap[0] ?? [],
                                item: item,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: !item.isExpanded ?
                  const SizedBox.shrink() :
                  Wrap(
                    runSpacing: 4, spacing: 6,
                    children: _.getFieldList(
                      context,
                      infoFormList: _.taskListInfoFormListMap[1] ?? [],
                      item: item,
                    ),
                  ),
                  crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}