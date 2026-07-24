import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/base/base_tab/base_tab_controller.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:flutter/material.dart';


///Tab页面 基础页
abstract class BaseTabPage<T extends BaseTabController> extends BaseFormPage<T> {

  @override
  Widget contentWidget(BuildContext context, T _) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          const SizedBox(height: 4,),

          ///TabBar、返回键、设置键
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 150,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: _.isShowBackOutlinedButton
                    ? const BackOutlinedButton()
                    : const SizedBox.shrink(),
              ),
              Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: _.isShowSettingButton
                        ? tabBarWidget(context, _)
                        : const SizedBox.shrink(),
                  )
              ),
              Container(
                  width: 150,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 12),
                  child: settingWidget(context, _)
              ),
            ],
          ),

          ///主内容
          Expanded(
            child: TabBarView(
              controller: _.tabController,
              physics: const NeverScrollableScrollPhysics(),//禁用左右滑动
              children: _.tabPageView,
            ),
          )
        ],
      ),
    );
  }

  Widget tabBarWidget(BuildContext context, T _){
    return TabBar(
      isScrollable: true,
      indicatorWeight: 2,
      tabAlignment: TabAlignment.center,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: Theme.of(context).textTheme.labelLarge,
      controller: _.tabController,
      tabs: List.generate(_.tabValueList.length, (index) {
        return Tab(text: _.tabValueList[index]);
      }).toList(),
    );
  }

}