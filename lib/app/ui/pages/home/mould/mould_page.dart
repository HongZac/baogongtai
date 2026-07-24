import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/mould/mould_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///模具查询 首页
class MouldPage extends BaseFormWithPageDataPage<MouldController, MouldModel> {
  
  @override
  Widget headWidget(BuildContext context, MouldController _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 480, height: 50,
            child: TextField(
              controller: _.searchTC,
              focusNode: _.searchFN,
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (String? string){
                controller.searchTCOnChanged();
              },
              decoration: InputDecoration(
                hintText: '请输入查询内容',
                hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
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
              ),
            )
          ),
          const SizedBox(width: 2,),

          MenuBar(
            style: MenuStyle(
                backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                padding: WidgetStateProperty.all(EdgeInsets.zero)
            ),
            children: [
              SubmenuButton(
                menuChildren: _.searchBtnTypeMenuList,
                style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero)
                ),
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () async{
                          await controller.searchTCOnSearch();
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                              kIsWeb || GetPlatform.isWindows
                                  ? const EdgeInsets.only(top: 20, bottom: 20, left: 12)
                                  : const EdgeInsets.only(top: 13, bottom: 13, left: 12)
                          ),
                        ),
                        child: Text(
                          _.searchBtnTypeName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          const SizedBox(width: 4,),
        ],
      ),
    );
  }

  @override
  Widget dataListWidget(BuildContext context, MouldController _){
    if (_.dataList.isEmpty){
      return Center(
        child: Text(
          '没有符合条件数据或未进行搜索。\n请输入编号并点击查询按钮，或扫码！',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w600
          ),
        ),
      );
    }
    return super.dataListWidget(context, _);
  }

  @override
  Widget dataItem(BuildContext context, MouldController _, MouldModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
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
                  ///附件查看
                  MineIconButton(
                    onPressed: () async{
                      await controller.itemAttach(item);
                    },
                    tooltip: '模具附件',
                    icon: Icons.picture_as_pdf_outlined,
                    iconSize: 60,
                    iconColor: Theme.of(context).colorScheme.primary,
                    //padding: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SelectableText.rich( //SelectableText(
                                TextSpan(
                                  text: '【${item.mouldCode ?? ''}】',
                                  children: [
                                    TextSpan(
                                      text: '${item.mouldName ?? ''}',
                                    ),
                                  ]
                                ),
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                            const SizedBox(width: 8,),

                            TextButton(
                              onPressed: (){
                                //controller.mouldItemExpandedOnChanged(item);
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
                                    style: Theme.of(Get.context!).textTheme.bodyLarge,
                                  ),
                                  AnimatedRotation(
                                    turns: item.isExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 100),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: Theme.of(Get.context!).textTheme.bodyLarge!.color,
                                      size: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43,
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
                  )
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
    );
  }

  List<Widget> firstList(BuildContext context, MouldModel item){
    List<Widget> list = [];
    list.add(
      itemWidget(item: item, title: '模具分类', content: item.mouldClass ?? '')
    );
    list.add(
        itemWidget(item: item, title: '模具类型', content: item.mouldType ?? '')
    );
    list.add(
        itemWidget(item: item, title: '存放位置', content: item.location ?? '')
    );
    list.add(
        itemWidget(
            item: item, title: '标准模穴',
            content: NumFormatUtil.qtyFormatConverter((item.output ?? 0).toString())
        )
    );
    list.add(
        itemWidget(
            item: item, title: '实际模穴',
            content: NumFormatUtil.qtyFormatConverter((item.availOutput ?? 0).toString())
        )
    );
    list.add(
        itemWidget(
            item: item, title: '标准周期',
            content: NumFormatUtil.qtyFormatConverter((item.outCycle ?? 0).toString(), decimal: 2)
        )
    );
    list.add(
        itemWidget(item: item, title: '备注', content: item.description ?? '')
    );
    return list;
  }
  List<Widget> secondList(BuildContext context, MouldModel item){
    List<Widget> list = [];
    return list;
  }
  Widget itemWidget({double width = 310, required String title, required String content, Color? contentColor, required MouldModel item}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: width,
      titleWidth: 100,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      contentStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
        color: contentColor
      ),
      onPress: () async{
      },
    );
  }
  
}