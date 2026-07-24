import 'package:basement/utils.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SignColorUtil {

  Color getOrderSignColor(int sign){
    if (sign >= MoOpOrderSign.wpg.sign && sign < MoOpOrderSign.scz.sign){
      return AppColors.totalColor;
    }
    else if (sign >= MoOpOrderSign.scz.sign && sign < MoOpOrderSign.ysc.sign){
      return AppColors.runColor;
    }
    else if (sign >= MoOpOrderSign.ysc.sign){
      return AppColors.stopColor;
    }
    else {
      return AppColors.totalColor;
    }
  }

  Color getTaskSignColor(int sign){
    if (sign >= MoTaskSign.zd.sign && sign < MoTaskSign.scz.sign){
      return AppColors.totalColor;
    }
    else if (sign >= MoTaskSign.scz.sign && sign < MoTaskSign.ysc.sign){
      return AppColors.runColor;
    }
    else if (sign >= MoTaskSign.ysc.sign){
      return AppColors.stopColor;
    }
    else {
      return AppColors.totalColor;
    }
  }

  String getIPQCStatus(int sign, int category, {var type = MoCheckVoucherSign}){
    if ((type == MoCheckVoucherSign && sign == MoCheckVoucherSign.td.sign)
        || (type == MoInspectSign && sign == MoInspectSign.djy.sign)){
      if (category == IPQCCategory.sj.category){
        return '待${IPQCCategory.sj.name}';
      }
      else if (category == IPQCCategory.xj.category){
        return '待${IPQCCategory.xj.name}';
      }
      else if (category == IPQCCategory.mj.category){
        return '待${IPQCCategory.mj.name}';
      }
      else if (category == IPQCCategory.wj.category){
        return '待${IPQCCategory.wj.name}';
      }
      else if (category == IPQCCategory.zj.category){
        return '待${IPQCCategory.zj.name}';
      }
    }
    else if ((type == MoCheckVoucherSign && sign == MoCheckVoucherSign.ysh.sign)
        || (type == MoInspectSign && sign == MoInspectSign.jyz.sign)){
      if (category == IPQCCategory.sj.category){
        return '${IPQCCategory.sj.name}中';
      }
      else if (category == IPQCCategory.xj.category){
        return '${IPQCCategory.xj.name}中';
      }
      else if (category == IPQCCategory.mj.category){
        return '${IPQCCategory.mj.name}中';
      }
      else if (category == IPQCCategory.wj.category){
        return '${IPQCCategory.wj.name}中';
      }
      else if (category == IPQCCategory.zj.category){
        return '${IPQCCategory.zj.name}中';
      }
    }
    else if ((type == MoCheckVoucherSign && sign == MoCheckVoucherSign.ywg.sign)
        || (type == MoInspectSign && sign == MoInspectSign.yjy.sign)){
      if (category == IPQCCategory.sj.category){
        return '已${IPQCCategory.sj.name}';
      }
      else if (category == IPQCCategory.xj.category){
        return '已${IPQCCategory.xj.name}';
      }
      else if (category == IPQCCategory.mj.category){
        return '已${IPQCCategory.mj.name}';
      }
      else if (category == IPQCCategory.wj.category){
        return '已${IPQCCategory.wj.name}';
      }
      else if (category == IPQCCategory.zj.category){
        return '已${IPQCCategory.zj.name}';
      }
    }
    return '';
  }

  Color getIPQCSignColor(int sign, {var type = MoCheckVoucherSign}){
    if (type == MoCheckVoucherSign){
      if (sign == MoCheckVoucherSign.td.sign){
        return AppColors.standByColor;
      }
      else if (sign == MoCheckVoucherSign.ysh.sign){
        return AppColors.totalColor;
      }
      else if (sign == MoCheckVoucherSign.ywg.sign){
        return AppColors.runColor;
      }
      else {
        return AppColors.standByColor;
      }
    }
    else if (type == MoInspectSign){
      if (sign == MoInspectSign.djy.sign){
        return AppColors.standByColor;
      }
      else if (sign == MoInspectSign.jyz.sign){
        return AppColors.totalColor;
      }
      else if (sign == MoInspectSign.yjy.sign){
        return AppColors.runColor;
      }
      else {
        return AppColors.standByColor;
      }
    }
    return AppColors.notConnectedColor;
  }

  Color getDeviceSignColor(int sign) {
    switch (sign){
      case 1:
        return AppColors.runColor;
      case 2:
        return AppColors.standByColor;
      case 4:
        return AppColors.stopColor;
      case 8:
        return AppColors.notConnectedColor;
      default:
        return AppColors.notConnectedColor;
    }
  }

  ///根据设备状态值，返回背景颜色
  Color getDeviceSignBkgdColor(int deviceSign){
    switch (deviceSign){
      case 1:
        return const Color(0xFFEDFAF5);
      case 2:
        return Colors.yellow[50]!;
      case 4:
        return Colors.red[50]!;
      case 8:
        return Colors.grey[300]!;
      default:
        return Colors.grey[300]!;
    }
  }


}