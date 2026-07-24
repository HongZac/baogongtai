import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:flutter/material.dart';


class MyRouteObserver extends NavigatorObserver {

  //didPush 页面被推入栈顶，显示在前台
  //didPopNext 当前页面再次显示
  //didPushNext 当前页面被新页面覆盖
  //didPop 页面从栈中弹出

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    MineGetDelegate().beforePush();
    super.didPush(route, previousRoute);
    MineGetDelegate().writeLog('Observer didPush');
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    MineGetDelegate().writeLog('Observer didPop');
    super.didPop(route, previousRoute);
    MineGetDelegate().afterPop();
  }

}