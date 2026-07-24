import 'dart:convert';

import 'package:basement/logger.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/service/sound_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';


enum ToastType {
  info,
  error,
  success,
  warn,
}

class ToastsColorProps {
  final Color textColor;
  final Color backgroundColor;
  ToastsColorProps(this.textColor, this.backgroundColor);
}

class ToastNotification {
  final FToast toast = FToast();

  ToastNotification(BuildContext context){
    toast.init(context);
  }

  /// Return text and background color for toasts type
  ToastsColorProps _getToastColor(ToastType type) {
    if (type == ToastType.success) {
      return new ToastsColorProps(
        AppColors.successTextColor,
        AppColors.successBgColor,
      );
    } else if (type == ToastType.error) {
      return new ToastsColorProps(
          AppColors.errorTextColor, AppColors.errorBgColor);
    } else if (type == ToastType.warn) {
      return new ToastsColorProps(
          AppColors.warnTextColor, AppColors.warnBgColor);
    } else {
      return new ToastsColorProps(
          AppColors.infoTextColor, AppColors.infoBgColor);
    }
  }

  /// Display the toast on the overlay
  void _showToast(ToastType type, String content, IconData icon) {
    toast.showToast(
      child: _buildToast(type, content, icon),
      gravity: ToastGravity.TOP,
    );
    PrintUtil.print(jsonEncode({
      LoggerCollector.logLevel: type == ToastType.info
          ? Level.info.name
          : type == ToastType.error
          ? Level.error.name
          : type == ToastType.success
          ? Level.info.name
          : type == ToastType.warn
          ? Level.warning.name
          : Level.debug.name,
      LoggerCollector.logMsg: content,
    }));
  }

  /// Display Success toast
  void success(String content) {
    _showToast(ToastType.success, content, Icons.check);
  }

  /// Display Error toast
  void error(String content) {
    Get.find<SoundService>().playError();
    _showToast(ToastType.error, content, Icons.error);
  }

  /// Display Info toast
  void info(String content) {
    Get.find<SoundService>().playInfo();
    _showToast(ToastType.info, content, Icons.info);
  }

  /// Display Warning toast
  void warn(String content) {
    Get.find<SoundService>().playError();
    _showToast(ToastType.warn, content, Icons.warning);
  }

  /// Construct the toast notification Widget structure
  Widget _buildToast(
      ToastType type,
      String content,
      IconData icon,
      ) =>
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 560, maxWidth: 360),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _getToastColor(type).backgroundColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _getToastColor(type).textColor),
              SizedBox(width: 16),
              Flexible(
                /*child: Text(
                  content,
                  style: TextStyle(
                    color: _getToastColor(type).textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),*/
                child: SelectableText(
                  content,
                  style: TextStyle(
                    color: _getToastColor(type).textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

