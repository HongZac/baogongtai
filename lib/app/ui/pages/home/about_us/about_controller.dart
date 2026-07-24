import 'dart:convert';
import 'dart:io';
import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_view.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_xupdate/flutter_xupdate.dart';
import 'package:get/get.dart';



///我的 关于软件
class AboutController extends GetxController {

  var http = Get.find<DioService>();
  var appService = Get.find<AppService>();
  UserInfoModal userInfo = BaseService.profile;
  late final String versionName = appService.versionName;
  late final String versionCode = appService.versionCode;

  ///服务器版本判断 返回内容
  dynamic data;

  String newVersionName = '';

  ///是否正在运行升级程序中...
  bool isUpdating = false;

  ///升级日志文件的位置
  File testFile = File('${ShareStorageUtil.logDirectory!.path}\\update_log.txt');


  @override
  Future<void> onReady() async {
    super.onReady();
    ProgressDialogUtil.showProgressDialog();
    try {
      await testFile.delete();
    } catch (e){
      PrintUtil.printDebug(e.toString());
    }
    await checkVersion();
    update();
    ProgressDialogUtil.update(value: 1);
  }

  ///写入日志
  Future<void> writeLog(String str) async {
    try {
      await testFile.writeAsString(
          '${DateTime.now().toString()}: $str\n\n',
          mode: FileMode.append
      );
    } catch (e){
      PrintUtil.printDebug(e.toString());
    }
  }

  ///检查版本
  Future<void> checkVersion() async{
    ///进行服务器版本判断  platform = '' 服务器版本判断不分设备
    //res.data返回内容：
    //{"HasUpdate":true,"IsIgnorable":true,"Code":0,"Msg":"","UpdateStatus":1,"VersionCode":2,
    //"VersionName":"1.0.0+2","ModifyContent":"版本2更新：更新测试",
    //"DownloadUrl":"http://123.60.78.67:8082/Upload/AppUpdate/desktop/app.apk",
    //"ApkSize":6666,"ApkMd5":"8b11ddde3da86f5a292cb7b9888bc745"}
    var res = await http.netFetch('${AddressService.updateServer}api/app/version?VersionCode=0&name=desktop&platform=');
    if (res.data != null && res.data.runtimeType != String) {
      newVersionName = res.data['VersionName'].toString();
      data = res.data;
      await writeLog('版本更新检查成功！最新版本：${data.toString()}。');
    }
    else {
      newVersionName = '';
      data = null;
      await writeLog('版本更新检查失败，${res.message}');
    }
  }


  ///初始化
  void _initXUpdate() async {
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterXUpdate.init(
        ///是否输出日志
          debug: true,
          ///是否使用post请求
          isPost: false,
          ///post请求是否是上传json
          isPostJson: false,
          ///是否开启自动模式
          isWifiOnly: false,
          ///是否开启自动模式
          isAutoMode: false,
          ///需要设置的公共参数
          supportSilentInstall: false,
          ///在下载过程中，如果点击了取消的话，是否弹出切换下载方式的重试提示弹窗
          enableRetry: false
      ).then((value) {
        //ToastNotification(Get.overlayContext!).success("初始化成功！");
      }).catchError((error) {
        PrintUtil.printDebug(error);
      });
    } else {
      ToastNotification(Get.overlayContext!).error("暂只支持安卓端自动更新！");
    }
  }

  Future<void> appUpdate() async {
    if (isUpdating){
      ToastNotification(Get.overlayContext!).error("正在升级！");
      return;
    }
    isUpdating = true;

    if (data != null && (data['VersionCode'] ?? 0) > num.parse(versionCode)) {

      var confirm = await DialogUtils.showConfirmationDialog(Get.overlayContext!,
          msg: "发现有新版本：${data['VersionCode'] ?? 0}，是否升级？");
      if (confirm == null || !confirm) {
        isUpdating = false;
        return;
      }
      await writeLog('开始升级……');

      ///如果不是web版本，并且是windows平台下
      if (!kIsWeb && Platform.isWindows){
        ///Windows平台下自动升级功能,通过进程调用升级主程序
        ///参数说明
        /// Args[0].当前版本号（0.9.0.0）
        /// Args[1].升级版本号（1.0.0.0）
        /// Args[2].更新描述URL（https://github.com/WELL-E）
        /// Args[3].更新包文件的URL（http://localhost：9090/UpdateFile.zip）
        /// Args[4].更新了文件发布路径（E:\PlatformPath）
        /// Args[5].更新程序包文件MD5代码（2b406701f8ad92922feb537fc789561a）

        String executable = '${Directory.current.path}\\AutoUpdater.exe';
        ///检测升级主程序是否存在
        if(!(await File(executable).exists())){
          ToastNotification(Get.overlayContext!).error("没有发现升级主程序AutoUpdater!");
          await writeLog('没有发现升级主程序AutoUpdater，升级失败！');
          isUpdating = false;
          return;
        }
        await writeLog('检测到升级主程序AutoUpdater……');

        //var res0 = await http.netFetch('${AddressService.updateServer}api/App/GenerateUpdateFile?appName=desktop&platform=windows&machineCode=');
        //if (!res0.isSuccess || res0.data == null) {
        //  ToastNotification(Get.overlayContext!).error("生成更新文件失败！");
        //  return;
        //}
        //String md5 = res0.data.substring(res0.data.lastIndexOf(" ") + 1);
        //String zipName = res0.data.substring(0, res0.data.lastIndexOf(" "));
        /////命令行参数里面的 '&' 前面要加 '^' https://blog.csdn.net/muslim377287976/article/details/117328157
        //List<String> arguments = [
        //  versionName, //当前版本号
        //  newVersionName, //升级版本号
        //  "${AddressService.updateServer}/upload/common/desktop.htm",
        //  "${AddressService.updateServer}/api/App/DownloadFile?appName=desktop^&platform=windows^&machineCode=^&zipName=$zipName",
        //  Directory.current.path,
        //  md5,
        //  Platform.executable, //'desktop.exe',
        //  'true'
        //];

        var result = await AppRepository().getVersion(0, 'desktop', 'windows');
        if(!result.isSuccess){
          isUpdating = false;
          await writeLog('软件升级地址获取失败：api/app/Version：${result.message}。');
          return;
        }
        await writeLog('软件升级地址获取成功：${jsonEncode(result.data.toJson())}。');

        ///命令行参数里面的 '&' 前面要加 '^' https://blog.csdn.net/muslim377287976/article/details/117328157
        List<String> arguments = [
          versionName,          ///当前版本号
          newVersionName,       ///升级版本号
          result.data.descriptionUrl ?? "${AddressService.updateServer}/upload/common/desktop.htm",
          result.data.downloadUrl ?? "",
          Directory.current.path,
          result.data.md5 ?? "",
          Platform.executable,   ///运行的exe文件名,Platform.resolvedExecutable:带全路径的exe文件名
          (result.data.reboot ?? false).toString()
        ];

        ///启动进程进行软件升级
        ///
        ///Process.start 创建新线程并在新线程中执行
        ///
        ///Process.run 直接在旧线程中执行
        await writeLog('启动进程进行软件升级（参数：${jsonEncode(arguments)}）……');
        try {
          /*Process.start(executable, arguments, mode: ProcessStartMode.detached, runInShell: true).then((value) async {
            await writeLog('进程成功启动，标准输出：${value.stdout}；标准错误：${value.stderr}；返回码：${value.exitCode}。');
          });*/
          var processResult = await Process.run(executable, arguments);
          await writeLog('进程成功启动，标准输出：${processResult.stdout}；标准错误：${processResult.stderr}；返回码：${processResult.exitCode}。');

        } catch (e){
          await writeLog('进程启动时发生异常：${e.toString()}。');
        }
      }
      else if (!kIsWeb && Platform.isAndroid) {
        ///Android平台的自动升级功能 先初始化升级功能
        _initXUpdate();

        ///以下执行apk下载安装
        FlutterXUpdate.updateByInfo(updateEntity: UpdateEntity(
            hasUpdate: true,
            isIgnorable: true,
            versionCode: data['VersionCode'],
            versionName: data['VersionName'],
            updateContent: data['ModifyContent'],
            downloadUrl: data['DownloadUrl'],
            apkSize: data['ApkSize']));
      }
      else {
        ///需要提供一个链接地址下载
        Get.showSnackbar(GetSnackBar(
            title:'发现有新版本',
            message:"服务器发现新版本$newVersionName,请联系服务商更新！！",
            duration:const Duration(seconds: 3))
        );
        return;
      }
    }
    else {
      ToastNotification(Get.overlayContext!).error("已是最新版本！");
    }

    isUpdating = false;
  }

  ///升级地址修改
  Future<void> updateServerOnChanged() async{
    var res = await DialogUtils.showCustomDialog<EditFieldController, String>(
      Get.context!,
      title: '升级服务器地址修改',
      isMaximize: false,
      initialHeight: 250, initialWidth: 580,
      content: EditFieldView(),
      controller: EditFieldController(
        hintContent: AddressService.updateServer,
        initTCText: AddressService.updateServer,
        beforeConfirmCallback: (String str) async {
          if (str.isEmpty){
            ToastNotification(Get.overlayContext!).error('端口号填写错误！');
            return false;
          }
          return true;
        }
      ),
    );
    if (res != null){
      if (AddressService.updateServer != res){
        AddressService.updateServer = res;
        ShareStorageUtil.instance?.write(BaseSharedPreferencesKeys.UPDATE_URL_KEY, AddressService.updateServer);
        ProgressDialogUtil.showProgressDialog(msg: '正在重新检查最新版本');
        await checkVersion();
        update();
        ProgressDialogUtil.update(value: 1);
      }
    }
  }

}