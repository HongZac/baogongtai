import 'dart:core';
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './about_controller.dart';



class AboutView extends GetView<AboutController> {
  const AboutView({super.key});


  showAboutDialog(BuildContext context, String? versionName) {

    showDialog(
        context: context,
        builder: (BuildContext context) => AboutDialog(
          applicationName: "app.name".tr,
          applicationVersion: "${"app.version".tr}: ${versionName ?? 'unknown'}",
          applicationIcon: const Image(image: AssetImage('assets/images/logo.png'), width: 50.0, height: 50.0),
          applicationLegalese: "app.copyright".tr,
        ));
  }

  List<Widget> _dialogContext(BuildContext context, AboutController _){
    List<Widget> list = [];

    list.add(const Expanded(flex: 1, child: SizedBox.shrink()));
    //list.add(const SizedBox(height: 36,));

    list.add(
      InkWell(
        onTap: (() => showAboutDialog(context, controller.versionName)),
        child: Image.asset(
          'assets/images/app_logo.png',
          width: 72.0,
          fit: BoxFit.fill,
          height: 72.0,
        ),
      ),
    );

    list.add(const SizedBox(height: 4,));

    list.add(
      Text(
        '版本号：${controller.versionName}+${controller.versionCode}',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );

    list.add(const SizedBox(height: 12));

    list.add(const Divider(indent: 0, endIndent: 0,));
    list.add(
        Material(
            child: ListTile(
              onTap: () => controller.appUpdate(),
              title: Text(
                  '版本检测',
                  style: Theme.of(context).textTheme.labelLarge
              ),
              trailing: Text(
                  _.newVersionName.isNotEmpty ? '最新版本:${_.newVersionName}' : '',
                  style: Theme.of(context).textTheme.labelLarge
              ),
            )
        )
    );
    list.add(const Divider(indent: 0, endIndent: 0,));

    list.add(const Expanded(flex: 1, child: SizedBox.shrink()));

    ///页脚
    list.add(
      Container(
        alignment: AlignmentDirectional.bottomCenter,
        padding: const EdgeInsets.only(bottom: 0),
        child: Text(
          '${"app.copyright".trParams({"year":DateTime.now().year.toString()})} Nberp.CN\nAll Rights Reserved.\nQQ(微信):41722866',
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AboutController>(builder: (_){
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _dialogContext(context,_),
      );
    }, initState: (GetBuilderState<AboutController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<AboutController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }
}