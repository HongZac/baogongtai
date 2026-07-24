# Desktop：   车间生产工作台
# description: 报工、质检

## debug模式下，运行中软件闪退的可能原因：WebSocket 长时间在尝试重连，[已修改，待测试（车间工作台、客户端）]

## Release 在windows下运行，需要VC运行库
VC 2017运行库
https://docs.microsoft.com/zh-CN/cpp/windows/latest-supported-vc-redist?view=msvc-170

## v1.2.0+30
[√] Flutter (Channel stable, 3.0.1, on Microsoft Windows [版本 10.0.17763.2928], locale zh-CN)
    • Flutter version 3.0.1 at E:\flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision fb57da5f94 (3 weeks ago), 2022-05-19 15:50:29 -0700
    • Engine revision caaafc5604
    • Dart version 2.17.1
    • DevTools version 2.12.2
    • Pub download mirror https://pub.flutter-io.cn
    • Flutter download mirror https://mirrors.sjtug.sjtu.edu.cn

## v1.1.0
[√] Flutter (Channel stable, 2.10.0, on Microsoft Windows [Version 10.0.22000.434], locale zh-CN)
    • Flutter version 2.10.0 at D:\Flutter\flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision 5f105a6ca7 (4 days ago), 2022-02-01 14:15:42 -0800
    • Engine revision 776efd2034
    • Dart version 2.16.0
    • DevTools version 2.9.2
    • Pub download mirror https://pub.flutter-io.cn
    • Flutter download mirror https://storage.flutter-io.cn

## 编译环境变量：
Picked up _JAVA_OPTIONS: -Xmx2048M -Dfile.encoding=utf-8  //encoding=utf-8解决中文乱码问题

## v1.0.0
Flutter 2.8.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision cf44000065 (4 days ago) • 2021-12-08 14:06:50 -0800
Engine • revision 40a99c5951
Tools • Dart 2.15.0
[√] Android toolchain - develop for Android devices (Android SDK version 30.0.3)
[√] Android Studio (version 4.1)

## 页面路由导航使用Navigator2.0，web路由特性
## Splash设计由MaterialApp.Builder中加载

## 图标更改
Windows下修改图标 /Windows/runner/resources/app_icon.ico
Windows下windows/runner/Runner.rc 文件中app_icon定义文件名称
Windows 下执行Shell //Process.start("WindowsFormsApp2.exe", [],mode: ProcessStartMode.detached);

## macOS: macos/runner/Assets.xcassets/AppIcon.appiconset

#网页上image显示错误
https://flutter.dev/docs/development/platform-integration/web-images
STEP 1: go to C:\src\flutter\packages\flutter_tools\lib\src\web 
        or navigate from your flutter root directory to flutter\packages\flutter_tools\lib\src\web.
STEP 2: open chrome.dart in your text editor.
STEP 3: add '--disable-web-security' under the like '--disable-extensions' as save the file.
SETP 4: delete flutter/bin/cache
STEP 5: run flutter clean in your project folder and run the app.

#SnackBar 消息显示现在用 ScaffoldMessenger
https://flutter.cn/docs/release/breaking-changes/scaffold-messenger
ScaffoldMessenger.of(context).showSnackBar(mySnackBar);
ScaffoldMessenger.of(context).hideCurrentSnackBar(mySnackBar);
ScaffoldMessenger.of(context).removeCurrentSnackBar(mySnackBar);

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
ScaffoldMessenger(
  key: scaffoldMessengerKey,
  child: ...
)

scaffoldMessengerKey.currentState.showSnackBar(mySnackBar);
scaffoldMessengerKey.currentState.hideCurrentSnackBar(mySnackBar);
scaffoldMessengerKey.currentState.removeCurrentSnackBar(mySnackBar);

// The root ScaffoldMessenger can also be accessed by providing a key to 
// MaterialApp.scaffoldMessengerKey. This way, the ScaffoldMessengerState can be directly accessed
// without first obtaining it from a BuildContext via ScaffoldMessenger.of. From the key, use
// the GlobalKey.currentState getter.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
MaterialApp(
  scaffoldMessengerKey: rootScaffoldMessengerKey,
  home: ...
)

rootScaffoldMessengerKey.currentState.showSnackBar(mySnackBar);
rootScaffoldMessengerKey.currentState.hideCurrentSnackBar(mySnackBar);
rootScaffoldMessengerKey.currentState.removeCurrentSnackBar(mySnackBar);

## Windows版本号在 windows/runner/Runner.rc 中修改

##解决windows版cpu占用高问题：替换下方函数
void RunLoop::Run() {
 MSG msg;
 while (GetMessage(&msg, nullptr, 0, 0)) {
   TranslateMessage(&msg);
   DispatchMessage(&msg);
 }
}

window_manager 需更改：windows/runner/win32_window.cpp
HWND window = CreateWindow(
    //window_class, title.c_str(), WS_OVERLAPPEDWINDOW | WS_VISIBLE,
    window_class, title.c_str(),
    WS_OVERLAPPEDWINDOW, // do not add WS_VISIBLE since the window will be shown later
    Scale(origin.x, scale_factor), Scale(origin.y, scale_factor),
    Scale(size.width, scale_factor), Scale(size.height, scale_factor),
    nullptr, nullptr, GetModuleHandle(nullptr), this);
    
## 自动升级 
AutoUpdater.exe 放到根目录下

## 本地打印(仅支持Windows平台)
1、nberp.Desktop.Service.Print 文件夹放到根目录下
2、打印模板放到根目录下的 assets\print 文件夹中

## Release版本在 Windows7 系统下闪退的解决方法
运行 Win7系统微软TTS语音修复_2018-02-06.exe

## 桌面端的软件文件夹放到D盘或E盘，否则自动更新程序可能无法运行（权限问题）



