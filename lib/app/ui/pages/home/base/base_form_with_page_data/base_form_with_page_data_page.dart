import 'package:basement/model.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///分页数据 基本页
abstract class BaseFormWithPageDataPage<T extends BaseFormWithPageDataController<V>, V extends ICloneable>
    extends BaseFormPage<T> {

  @override
  Widget contentWidget(BuildContext context, T _){
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headWidget(context, _),

          ///列表主内容
          Expanded(
            child: _.dataList.isNotEmpty ? dataListWidget(context, _) : emptyWidget(context, _),
          ),

          if (_.isShowFootWidget)
            const SizedBox(height: 4,),

          ///总记录数 翻页
          if (_.isShowFootWidget)
            footWidget(context, _),
        ],
      ),
    );
  }

  Widget headWidget(BuildContext context, T _){ return SizedBox.shrink(); }

  Widget emptyWidget(BuildContext context, T _){ return const SizedBox.shrink(); }

  Widget dataListWidget(BuildContext context, T _){
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        interactive: false,
        thumbVisibility: WidgetStateProperty.all(false),
        trackVisibility: WidgetStateProperty.all(false),
        thumbColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: ListView.builder(
        controller: _.dataListController,
        itemCount: _.dataList.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (BuildContext context, int index){
          V item = _.dataList[index];
          return dataItem(context, _, item);
        },
      ),
    );
  }

  Widget dataItem(BuildContext context, T _, V item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: Container(height: 160,),
      ),
    );
  }

  Widget footWidget(BuildContext context, T _){
    return Row(
      children: [
        const SizedBox(width: 4,),
        RichText(
          text: TextSpan(
              text: '共 ',
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
                const TextSpan(
                    text: ' 条记录'
                )
              ]
          ),
          textScaler: TextScaler.linear(FontFamilyConfig.textScale),
        ),
        const Expanded(child: SizedBox.shrink()),
        const SizedBox(width: 8,),

        OutlinedButton(
          onPressed: () async{
            await controller.pageChanged(pageIndex: 1);
            controller.update();
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
            controller.update();
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
            controller.update();
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