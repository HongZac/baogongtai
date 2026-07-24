import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/mo_issuance_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///发料单 主页面
class MoIssuancePage extends BaseFormWithPageDataPage<MoIssuanceController, MoIssuanceModel> {


  @override
  Widget headWidget(BuildContext context, MoIssuanceController _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Wrap(
              runSpacing: 4, spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TitleTextBoxWidget(
                  title: '单据日期',
                  titleWidth: 125, width: 498,
                  titleStyle: Theme.of(context).textTheme.bodyLarge,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  customizeContent: PrefixTextField(
                    object: 3, height: 60, readOnly: true,
                    contentPadding: kIsWeb || GetPlatform.isWindows
                        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                        : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    initText: _.startDate == null || _.endDate == null
                        ? ''
                        : '${DateUtil.formatDateTime(_.startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
                        '到'
                        '${DateUtil.formatDateTime(_.endDate.toString(), DateFormat.YEAR_MONTH_DAY)}',
                    valueOnChanged: (String string) async{
                      await controller.dateChanged(string);
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 60,
                      width: _.isSearchWidgetOpen
                          ? 400
                          : 60,
                      child: TextField(
                        controller: _.searchTC,
                        focusNode: _.searchFN,
                        style: Theme.of(context).textTheme.bodyLarge,
                        onChanged: (String? string) async{
                          controller.searchTCOnChanged();
                        },
                        decoration: InputDecoration(
                          hintText: '请输入材料名称',
                          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                          ),
                          contentPadding: kIsWeb || GetPlatform.isWindows
                              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                              : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                          prefixIcon: Icon(
                            Icons.search,
                            size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                            color: Theme.of(context).inputDecorationTheme.iconColor,
                          ),
                          suffixIcon: _.searchTC.text.isEmpty ? null : MineIconButton(
                            icon: Icons.cancel,
                            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                            tooltip: '清空',
                            onPressed: () async{
                              await controller.searchTCClear();
                            },
                          ),
                          enabledBorder: _.isSearchWidgetOpen
                              ? null
                              : const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        ),
                      ),
                    ),
                    if (_.isSearchWidgetOpen)
                      const SizedBox(width: 4,),
                    if (_.isSearchWidgetOpen)
                      FilledButton(
                        onPressed: () async{
                          await controller.searchTCOnSearch();
                        },
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(const Size(100, 60)),
                        ),
                        child: Text(
                          '查询',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                          ),
                        ),
                      ),
                  ],
                )
              ],
            );
          }
      ),
    );
  }

  Widget dataItem(BuildContext context, MoIssuanceController _, MoIssuanceModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onDoubleTap: () async{
            await controller.itemOnDoubleTap(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText.rich( //SelectableText(
                            TextSpan(
                              text: '【${item.moIssueCode ?? ''}】${item.invName ?? ''}',
                            ),
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                        const SizedBox(width: 8,),

                        TextButton(
                          onPressed: () async{
                            await controller.itemOnDoubleTap(item);
                          },
                          style: ButtonStyle(
                              minimumSize: WidgetStateProperty.all(
                                  kIsWeb || GetPlatform.isWindows
                                      ? const Size(75, 50)
                                      : const Size(75, 40)
                              )
                          ),
                          child: Text(
                            '报工',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(width: 2,),

                        TextButton(
                          onPressed: (){
                            controller.issuanceItemExpandedOnChanged(item);
                          },
                          style: ButtonStyle(
                              minimumSize: WidgetStateProperty.all(
                                  kIsWeb || GetPlatform.isWindows
                                      ? const Size(75, 50)
                                      : const Size(75, 40)
                              )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 4,),
                              Text(
                                item.isExpanded ? '收起' : '展开',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              AnimatedRotation(
                                  turns: item.isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                    size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      runSpacing: 4, spacing: 6,
                      children: firstList(context, item),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: !item.isExpanded ? const SizedBox.shrink() : Wrap(
                    runSpacing: 4, spacing: 6,
                    children: secondList(context, item),
                  ),
                  crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> firstList(BuildContext context, MoIssuanceModel item){
    var _ = Get.find<MoIssuanceController>();
    List<Widget> list = [];
    list.add(
        itemWidget(item: item, title: '色粉', content: item.toner ?? '')
    );
    list.add(
        itemWidget(item: item, title: '材料名称', content: item.invName ?? '')
    );
    list.add(
        itemWidget(item: item, title: '产品名称', content: item.productName ?? '')
    );
    list.add(
        itemWidget(
            item: item, title: '总数量',
            content: NumFormatUtil.qtyFormatConverter((item.qty ?? 0).toString(), decimal: 2)
        )
    );
    list.add(
        itemWidget(item: item, title: '发料人', content: item.issuer ?? '')
    );
    //region define
    if (_.dataService.userDefMap['Define22']?.defCaption != null){
      list.add(
          itemWidget(
              item: item,
              title: _.dataService.userDefMap['Define22']!.defCaption!,
              content: item.define22 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define23']?.defCaption != null){
      list.add(
          itemWidget(
              item: item,
              title: _.dataService.userDefMap['Define23']!.defCaption!,
              content: item.define23 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define24']?.defCaption != null){
      list.add(
          itemWidget(
              item: item,
              title: _.dataService.userDefMap['Define24']!.defCaption!,
              content: item.define24 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define25']?.defCaption != null){
      list.add(
          itemWidget(
              item: item,
              title: _.dataService.userDefMap['Define25']!.defCaption!,
              content: item.define25 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define28']?.defCaption != null){
      list.add(
          itemWidget(
              item: item,
              title: _.dataService.userDefMap['Define28']!.defCaption!,
              content: item.define28 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define29']?.defCaption != null){
      list.add(
          itemWidget(
              item: item,
              title: _.dataService.userDefMap['Define29']!.defCaption!,
              content: item.define29 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define30']?.defCaption != null){
      list.add(
          itemWidget(
              item: item,
              title: _.dataService.userDefMap['Define30']!.defCaption!,
              content: item.define30 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define31']?.defCaption != null){
      list.add(
          itemWidget(
              item: item,
              title: _.dataService.userDefMap['Define31']!.defCaption!,
              content: item.define31 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define32']?.defCaption != null){
      list.add(
          itemWidget(
              item: item,
              title: _.dataService.userDefMap['Define32']!.defCaption!,
              content: item.define32 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['Define33']?.defCaption != null){
      list.add(
          itemWidget(
              item: item,
              title: _.dataService.userDefMap['Define33']!.defCaption!,
              content: item.define33 ?? ''
          )
      );
    }
    //endregion
    return list;
  }
  List<Widget> secondList(BuildContext context, MoIssuanceModel item){
    List<Widget> list = [];
    return list;
  }
  Widget itemWidget({double width = 500, required String title, required String content,
    Color? contentColor, required MoIssuanceModel item}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: width,
      titleWidth: 150,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      contentStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
          color: contentColor
      ),
    );
  }

}