import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/base/belt_line/belt_line_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///产线管理 660003；加工中心 660022; 生产班组 660021 ; 生产工位 660025 ;
class BeltLinePage extends BaseFormPage<BeltLineController> {

  BeltLinePage({required this.customTag});

  final String customTag;

  @override
  String? get tag => customTag;

  
  @override
  Widget contentWidget(BuildContext context, BeltLineController _){
    return Container(
      padding: const EdgeInsets.all(4),
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          headWidget(context, _),
          Divider(
            indent: 0, endIndent: 0,
            color: Theme.of(context).dividerTheme.color!.withAlpha(102),
          ),
          Expanded(child: beltLineList(context, _))
        ],
      ),
    );
  }

  Widget headWidget(BuildContext context, BeltLineController _){
    return Container(
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(right: 12, left: 4, top: 4, bottom: 8),
      child: Wrap(
        runSpacing: 4, spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ///搜索框
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            width: 230,
            child: TextField(
              controller: _.searchTC,
              focusNode: _.searchFN,
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (String? string) async{
                await controller.searchTCOnSearch();
              },
              decoration: InputDecoration(
                hintText: '请输入${_.typeTitle}编号',
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
                suffixIcon: _.searchTC.text.isNotEmpty ? MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () async{
                    await controller.searchTCClear();
                  },
                ) :
                null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget beltLineList(BuildContext context, BeltLineController _) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: GridView.builder(
          shrinkWrap: false,
          semanticChildCount: 0,
          addAutomaticKeepAlives: true,
          controller: _.beltLineListController,
          padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 42),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 370, //300,
            childAspectRatio: _.itemAspectRatio,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _.beltLineFilterList.length,
          itemBuilder: (BuildContext context, int index){
            MoBeltLineModel item = _.beltLineFilterList[index];
            return dataItem(context, _, item);
          }
      ),
    );
  }

  Widget dataItem(BuildContext context, BeltLineController _, MoBeltLineModel item) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints){
        if (_.itemWidth != constraints.maxWidth){
          _.itemAspectRatio = constraints.maxWidth / _.itemHeight;
          _.itemWidth = constraints.maxWidth;
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            controller.update();
          });
        }
        return Material(
          elevation: 1,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: () async {
              //await controller.blAllocate(item);
            },
            onDoubleTap: () async {
              await controller.itemOnDoubleTap(item);
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 70,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///Icon
                        Container(
                          width: 70, height: 70,
                          margin: const EdgeInsets.only(left: 4, top: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha(25),
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Icon(
                            _.progId == 660003
                                ? Icons.conveyor_belt
                                : _.progId == 660021
                                ? Icons.groups_2
                                : Icons.home,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8,),

                        ///编号 名称
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${(item.lineCode ?? '').isNotEmpty ? item.lineCode : ' '}',
                                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                              fontWeight: FontWeight.w900,
                                              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.7
                                          ), maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                  '${item.lineName ?? ''}',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3,
                                  ), maxLines: 1, overflow: TextOverflow.ellipsis
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8,),
                      ],
                    ),
                  ),

                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}