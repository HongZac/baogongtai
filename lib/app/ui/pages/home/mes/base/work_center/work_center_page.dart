import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/base/work_center/work_center_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/utils/sign_color_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///加工中心 660022
class WorkCenterPage extends BaseFormPage<WorkCenterController> {

  @override
  Widget contentWidget(BuildContext context, WorkCenterController _){
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
          Expanded(child: workCenterList(context, _))
        ],
      ),
    );
  }

  Widget headWidget(BuildContext context, WorkCenterController _){
    return Container(
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(right: 12, left: 4, top: 4, bottom: 8),
      child: Wrap(
        runSpacing: 4, spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ///DeviceSign
          Wrap(
            runSpacing: 6, spacing: 6,
            children: List.generate(_.deviceSignList.length, (index) {
              ChoiceChipModel item = _.deviceSignList[index];
              return RawChip(
                selected: !_.unVisibleDeviceSignList.contains(item.sign),
                selectedColor: item.activeColor,
                disabledColor: Colors.white,
                showCheckmark: false,
                onSelected: (bool bool) async{
                  await controller.deviceSignOnChanged(item);
                },
                side: BorderSide(
                  color: !_.unVisibleDeviceSignList.contains(item.sign)
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.onSurface.withAlpha(76)
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)
                ),
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: RichText(
                    text: TextSpan(
                      text: DataUtils.getNotConnectedZh(content: item.title, type: 1),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: !_.unVisibleDeviceSignList.contains(item.sign)
                            ? item.foreColor
                            : item.activeColor,
                      ),
                      children: [
                        TextSpan(
                          text: item.content.isEmpty ? ' ' : item.content,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.5,
                          ),
                        ),
                        const TextSpan(text: ' 台'),
                      ]
                    ),
                    textScaler: TextScaler.linear(FontFamilyConfig.textScale),
                  )
                ),
              );
            }).toList(),
          ),
          ///搜索框
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            width: _.isSearchWidgetOpen
                ? 230
                : 50,
            child: TextField(
              controller: _.searchTC,
              focusNode: _.searchFN,
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (String? string) async{
                await controller.searchTCOnSearch();
              },
              decoration: InputDecoration(
                hintText: '请输入加工中心编号',
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
                suffixIcon: _.searchTC.text.isNotEmpty ?
                MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () async{
                    await controller.searchTCClear();
                  },
                ) :
                null,
                enabledBorder: _.isSearchWidgetOpen
                    ? null
                    : const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget workCenterList(BuildContext context, WorkCenterController _) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: GridView.builder(
        shrinkWrap: false,
        semanticChildCount: 0,
        addAutomaticKeepAlives: true,
        controller: _.workCenterListController,
        padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 42),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 370, //300,
          childAspectRatio: _.itemAspectRatio,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: _.workCenterFilterList.length,
        itemBuilder: (BuildContext context, int index){
          MoWorkCenterModel item = _.workCenterFilterList[index];
          return dataItem(context, _, item);
        }
      ),
    );
  }

  Widget dataItem(BuildContext context, WorkCenterController _, MoWorkCenterModel item) {
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
          elevation: 4,
          //surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: (){  },
            onDoubleTap: () async {
              await controller.itemOnDoubleTap(item);
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(///渐变位置
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 1.0],
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).brightness == Brightness.light
                          ? SignColorUtil().getDeviceSignBkgdColor(item.sign ?? 0)
                          : SignColorUtil().getDeviceSignColor(item.sign ?? 0).withAlpha(25)
                    ]
                ),
                borderRadius: BorderRadius.circular(4),
              ),
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
                            color: SignColorUtil().getDeviceSignColor(item.sign ?? 0),
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Icon(
                            Icons.precision_manufacturing,
                            color: Theme.of(context).colorScheme.surface,
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

                                    Text(
                                      DataUtils.getNotConnectedZh(content: item.status ?? '', type: 1),
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          color: SignColorUtil().getDeviceSignColor(item.sign ?? 0),
                                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3
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