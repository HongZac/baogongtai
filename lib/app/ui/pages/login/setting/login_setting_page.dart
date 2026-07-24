
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/ui/widget/drag_to_move_area_without_double_tap.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'login_setting_controller.dart';


///登录界面服务器参数设置
class LoginSettingPage extends GetView<LoginSettingController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginSettingController>(builder:(_){
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (GetPlatform.isAndroid){
            ///点击空白关闭软键盘
            FocusManager.instance.primaryFocus?.unfocus();
            ///全屏，关闭状态栏
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          }
        },
        child: GetPlatform.isWindows && !kIsWeb ?
        DragToMoveAreaWithoutDoubleTap(
            child: contentWidget(context, _),
        ) :
        contentWidget(context, _),
      );
    }, initState: (GetBuilderState<LoginSettingController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<LoginSettingController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }

  Widget contentWidget(BuildContext context, LoginSettingController _){
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(height: 24,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 24,),

              ///返回登录页面
              const BackOutlinedButton(),
              const Expanded(child: SizedBox.shrink(),),

              ///软键盘
              if (!kIsWeb && GetPlatform.isWindows)
                MineIconButton(
                  onPressed: () async {
                    await controller.rootCtl.openKeyboard();
                  },
                  tooltip:  'app.softKeyBoard'.tr,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  iconColor: Theme.of(context).textTheme.bodyLarge!.color,
                  icon: Icons.keyboard,
                ),
              const SizedBox(width: 8,),

              ///退出系统
              TextButton(
                  onPressed: () async{ await controller.rootCtl.exitApp(); },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 6, right: 14, left: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          color: IconTheme.of(context).color,
                        ),
                        const SizedBox(width: 4,),
                        Text(
                          '退出系统'.tr,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
              ),

              const SizedBox(width: 24,),
            ],
          ),

          const Expanded(flex: 1, child: SizedBox.shrink()),

          ///标题
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 400,
            alignment: Alignment.bottomLeft,
            child: Text(
              'loginSetting.pageName'.tr,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32,),

          ///IP地址
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 400, height: 50,
            child: TextField(
              controller: _.serverController,
              autofocus: true,
              style: Theme.of(context).textTheme.bodyLarge,
              onEditingComplete: () async{
                await controller.setting();
              },
              decoration: InputDecoration(
                hintText: 'loginSetting.hintIpSetting'.tr,
                hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                ),
                contentPadding: kIsWeb || GetPlatform.isWindows
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                    : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                prefixIcon: MenuBar(
                  children: [
                    SubmenuButton(
                      menuChildren: List.generate(_.historyServerMap.keys.length, (index) {
                        String serverIP = _.historyServerMap.keys.toList()[index];
                        String anotherName = _.historyServerMap[serverIP]!;
                        return MenuItemButton(
                          onPressed: () {
                            controller.historyServerOnSelected(serverIP);
                          },
                          leadingIcon: MineIconButton(
                            onPressed: () async {
                              await controller.editAnotherName(serverIP, anotherName);
                            },
                            icon: Icons.edit_note,
                            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                            tooltip: '别名',
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(left: 9),
                          ),
                          child: Container(
                            width: 288,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    serverIP,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  anotherName,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          trailingIcon: MineIconButton(
                            onPressed: () {
                              controller.deleteHistoryServer(serverIP);
                            },
                            icon: Icons.cancel,
                            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                            tooltip: '删除该历史记录',
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(right: 9),
                          ),
                        );
                      }).toList(),
                      child: Icon(
                        Icons.computer,
                        size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        color: Theme.of(context).inputDecorationTheme.iconColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8,),

          ///清除部分本地参数配置
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _.isRemoveStorage,
                  onChanged: (value){
                    _.isRemoveStorage = !_.isRemoveStorage;
                    controller.update();
                  }
                ),
                Text(
                  '清除部分本地参数配置',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24,),

          ///提交按钮
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: () async{
                  await controller.setting();
                },
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(408, 60)),
                ),
                child: Text(
                  'loginSetting.saveBtn'.tr,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  ),
                ),
              )
          ),

          const Expanded(flex: 2, child: SizedBox.shrink()),
          ///页脚
          Container(
            alignment: AlignmentDirectional.bottomCenter,
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "app.copyright".trParams({"year":DateTime.now().year.toString()}),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

}