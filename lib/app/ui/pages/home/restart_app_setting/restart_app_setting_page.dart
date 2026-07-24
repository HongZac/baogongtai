
import 'package:desktop/app/ui/pages/home/restart_app_setting/restart_app_setting_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/ui/widget/touch_spin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';


///定时重启设置页面
class RestartAppSettingView extends BaseDialogPage<RestartAppSettingController> {

  Widget contentWidget(BuildContext context, RestartAppSettingController _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        mineInputBoxWithTitle(
          context, _,
          title: '定时重启',
          contentWidget: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Switch(
                  value: _.isNeedTimedRestart,
                  onChanged: (bool boolValue){
                    controller.isNeedTimedRestartOnChanged();
                  },
                ),
                if (_.isNeedTimedRestart)
                  Text(
                    _.nextRestartTime,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ],
            ),
          ),
        ),
        mineInputBoxWithTitle(
            context, _,
            title: '选择一个时间',
            contentWidget: Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () async {
                    if (context.mounted) {
                      final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _.timeOfDayOfAppRestart ?? TimeOfDay(hour: 0, minute: 0),
                          builder: (context, child){
                            return TimePickerTheme(
                              data: TimePickerThemeData(
                                dayPeriodTextStyle: Theme.of(context).textTheme.titleLarge,
                                helpTextStyle: Theme.of(context).textTheme.titleLarge,
                                hourMinuteTextStyle: Theme.of(context).textTheme.titleLarge,
                              ),
                              child: TextButtonTheme(
                                  data: TextButtonThemeData(
                                      style: ButtonStyle(
                                          textStyle: WidgetStateProperty.all(
                                              Theme.of(context).textTheme.titleLarge
                                          )
                                      )
                                  ),
                                  child: Localizations(
                                      locale: Get.locale!,
                                      delegates: const <LocalizationsDelegate>[
                                        DefaultMaterialLocalizations.delegate,
                                        DefaultCupertinoLocalizations.delegate,
                                        DefaultWidgetsLocalizations.delegate,
                                        GlobalMaterialLocalizations.delegate,
                                        GlobalWidgetsLocalizations.delegate,
                                      ],
                                      child: child
                                  )
                              ),
                            );
                          }
                      );
                      if (pickedTime != null){
                        _.timeOfDayOfAppRestart = pickedTime;
                        controller.update();
                      }
                    }
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 0
                    )),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8,),
                      Text(
                        _.timeOfDayOfAppRestart == null
                            ? '00:00'
                            : '${_.timeOfDayOfAppRestart!.hour < 10 ? '0${_.timeOfDayOfAppRestart!.hour}' : _.timeOfDayOfAppRestart!.hour}'
                            ':'
                            '${_.timeOfDayOfAppRestart!.minute < 10 ? '0${_.timeOfDayOfAppRestart!.minute}' : _.timeOfDayOfAppRestart!.minute}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 8,),
                      Icon(
                        Icons.edit,
                        size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                      ),
                      const SizedBox(width: 8,),
                    ],
                  )
              ),
            )
        ),
        mineInputBoxWithTitle(
          context, _,
          title: '选择天数',
          contentWidget: Container(
            alignment: Alignment.centerLeft,
            child: TouchSpin(
              width: 140,
              numValue: _.dayOfAppRestart?.toDouble() ?? 0,
              numMin: 0,
              textStyle: Theme.of(context).textTheme.titleLarge,
              iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
              addIcon: const Icon(Icons.add_circle_outline),
              subtractIcon: const Icon(Icons.remove_circle_outline),
              canInput: false,
              numOnChanged: (value){
                _.dayOfAppRestart = value.toInt();
                controller.update();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget mineInputBoxWithTitle(BuildContext context, RestartAppSettingController _, {
    required String title,
    String? content, TextStyle? contentStyle, Widget? contentWidget,
  }) {
    return TitleTextBoxWidget(
      title: title,
      width: 1000, titleWidth: 180,
      margin: const EdgeInsets.only(bottom: 16),
      crossAxisAlignment: CrossAxisAlignment.center,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      content: content ?? '',
      contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(171)
      ),
      customizeContent: contentWidget,
    );
  }

}