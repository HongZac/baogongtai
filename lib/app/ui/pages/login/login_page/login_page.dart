
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/ui/widget/drag_to_move_area_without_double_tap.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'login_controller.dart';


/// 登录页
/// Created by 王维峰
/// Date: 2021-07-20
class LoginPage extends GetView<LoginController> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (_) {
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
    }, initState: (GetBuilderState<LoginController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<LoginController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }

  Widget contentWidget(BuildContext context, LoginController _){
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(height: 24,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 24,),

              ///设置 IP地址修改
              OutlinedButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings_outlined, // FluentIcons.settings_16_regular
                      color: IconTheme.of(context).color,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    ),
                    const SizedBox(width: 4,),
                    Text(
                      '服务器设置'.tr,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
                onPressed: () async {
                  Get.rootDelegate.toNamed(AppRoutes.LOGIN_SETTING_PAGE);
                },
              ),
              const Expanded(child: SizedBox.shrink(),),

              ///软键盘
              if (!kIsWeb && GetPlatform.isWindows)
                MineIconButton(
                  icon: Icons.keyboard,
                  tooltip:  'app.softKeyBoard'.tr,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  iconColor: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () async {
                    await controller.rootCtl.openKeyboard();
                  },
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
            alignment: Alignment.bottomCenter,
            child: Text(
              'login.pageName'.tr,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32,),

          ///账号
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: 400, height: 50,
              child: TextField(
                controller: _.userController,
                focusNode: _.uNFocusNode,
                style: Theme.of(context).textTheme.bodyLarge,
                onEditingComplete: (){
                  _.uNFocusNode.unfocus();
                  _.pWFocusNode.requestFocus();
                },
                decoration: InputDecoration(
                  hintText: 'login.hintUser'.tr,
                  hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                  ),
                  contentPadding: kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                      : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  prefixIcon: Icon(
                    Icons.supervised_user_circle_outlined,
                    size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    color: Theme.of(context).inputDecorationTheme.iconColor,
                  ),
                ),
              )
          ),
          const SizedBox(height: 16,),

          ///密码
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: 400, height: 50,
              child: TextField(
                controller: _.pwController,
                focusNode: _.pWFocusNode,
                obscureText: _.obscureTextLogin,
                style: Theme.of(context).textTheme.bodyLarge,
                onEditingComplete: () async{
                  _.pWFocusNode.unfocus();
                  await controller.signIn();
                },
                decoration: InputDecoration(
                  hintText: 'login.hintPassword'.tr,
                  hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                  ),
                  contentPadding: kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                      : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  prefixIcon: Icon(
                    Icons.keyboard,
                    size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    color: Theme.of(context).inputDecorationTheme.iconColor,
                  ),
                  suffixIcon: MineIconButton(
                    onPressed: () {
                      _.obscureTextLogin = !_.obscureTextLogin;
                    },
                    tooltip:  _.obscureTextLogin ? 'login.showPassword'.tr : 'login.hidePassword'.tr,
                    padding: const EdgeInsets.all(12),
                    iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    icon: _.obscureTextLogin ? FluentIcons.eye_off_16_filled : FluentIcons.eye_12_filled,
                  ),
                ),
              )
          ),
          const SizedBox(height: 16,),

          ///是否记住密码
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                    value: _.reservePassword,
                    onChanged: (value){
                      _.reservePassword = value;
                    }
                ),
                Text(
                  'login.reserved'.tr,
                  style: Theme.of(context).textTheme.labelSmall,
                )
              ],
            ),
          ),
          const SizedBox(height: 24,),

          ///登录按钮
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: () async{
                  await controller.signIn();
                },
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(408, 60)),
                ),
                child: Text(
                  'login.loginBtn'.tr,
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
              "app.copyright".trParams({"year": DateTime.now().year.toString()}),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

