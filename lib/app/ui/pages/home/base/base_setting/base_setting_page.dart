import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/ui/widget/mine_expansion_panel/mine_expansion_panel.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;


///设置页面 基础页
abstract class BaseSettingPage<T extends BaseSettingController> extends BaseFormPage<T>{

  @override
  Widget contentWidget(BuildContext context, T _) {
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
            if (_.isShowHeadWidget)
              const SizedBox(height: 4,),

            ///标题、返回键
            if (_.isShowHeadWidget)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 250,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 8),
                    child: _.isShowBackOutlinedButton
                        ? const BackOutlinedButton()
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          _.title,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      )
                  ),
                  const SizedBox(width: 250,),
                ],
              ),
            if (_.isShowHeadWidget)
              const SizedBox(height: 8,),

            ///主内容
            Expanded(
              child: tabAreaWidget(context, _),
            )
          ],
        ),
      ),
    );
  }

  Widget tabAreaWidget(BuildContext context, T _){
    return Row(
      children: [
        Container(
          width: AppConfig.tabWidth,
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: ExpansionPanelList(
              key: const ValueKey('settingPageTabBar'),
              elevation: 0,
              dividerColor: Colors.transparent,
              expandedHeaderPadding: const EdgeInsets.all(0),
              children: List.generate(_.tabValueList.length, (index){
                ChoiceChipModel item = _.tabValueList[index];
                return ExpansionPanel(
                  isExpanded: item.isOpen,
                  canTapOnHeader: true,
                  backgroundColor: _.currentTabKey == item.keyName
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return tabBarItem(context, _, item);
                  },
                  body: Column(
                    children: List.generate(item.children.length, (index){
                      ChoiceChipModel childItem = item.children[index];
                      return tabBarItem(context, _, childItem);
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const VerticalDivider(indent: 0, endIndent: 0,),

        Expanded(
          child: Container(
            padding: const EdgeInsets.only(right: 4, left: 4, bottom: 4),
            child: _.currentTabIndex < 0 ?
            const SizedBox.shrink() :
            tabPageView(context, _)[_.currentTabIndex],
          )
        ),
      ],
    );
  }

  Widget tabBarItem(BuildContext context, T _, ChoiceChipModel item){
    return Material(
      elevation: 0,
      color: _.currentTabKey == item.keyName
          ? Theme.of(context).colorScheme.primary
          : Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Icon(
          item.icon,
          size: Theme.of(context).textTheme.titleMedium!.fontSize! * 1.43,
          color: _.currentTabKey == item.keyName
              ? Colors.white
              : Theme.of(context).iconTheme.color,
        ),
        title: Text(
          item.title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: _.currentTabKey == item.keyName
                ? Colors.white
                : null,
          ),
        ),
        trailing: item.children.isEmpty ? null : Icon(
          item.isOpen ? Icons.arrow_drop_down : Icons.arrow_right,
          size: Theme.of(context).textTheme.titleMedium!.fontSize! * 1.5,
          color: _.currentTabKey == item.keyName
              ? Colors.white
              : Theme.of(context).iconTheme.color,
        ),
        onTap: () async {
          controller.tabOnChanged(item);
        },
      )
    );
  }

  List<Widget> tabPageView(BuildContext context, T _){ return []; }

  Widget settingSaveBtnWidget(BuildContext context, {VoidCallback? onPressed}){
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all( ///sizesize
            const Size(2000, 70)
          ),
        ),
        child: Text(
          '确认修改',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
          ),
        ),
      ),
    );
  }

}