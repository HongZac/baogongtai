import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///提供了一系列与数字键盘控件相关的方法和常量
///主要用于管理和操作数字键盘的控制器、文本、焦点等
class NumPadUtil {

  //region 每增加一个字段定义，必须确保该字段的名称也被添加到[isFieldDefined]的 list 中！！！！！！！！！！！！！！

  ///称重重量(g)
  static const String eBWeight = 'eBWeight';
  ///称重件数
  static const String eBPiece = 'eBPiece';
  ///实际单重(g)
  static const String pieceWeight = 'pieceWeight';
  ///单箱皮重(kg)
  static const String packingWeight = 'packingWeight';

  ///入库箱数（装箱数）(整箱箱数)
  static const String num = 'num';

  ///单箱数量 == 单箱件数（一个箱子装多少件产品，或是一托里面装多少小箱）（从数据库中读取，且数据可修改）
  static const String singleBoxQty = 'singleBoxQty';
  ///尾箱数量 == 尾箱件数（箱子中数量未装满）
  static const String lastBoxQty = 'lastBoxQty';

  ///单托箱数，一托里面装多少小箱（从数据库中读取，且数据可修改）
  static const String boxNumOfPallet = 'boxNumOfPallet';

  ///单箱重量(kg)
  static const String singleBoxWeight = 'singleBoxWeight';
  ///尾箱重量(kg)
  static const String lastBoxWeight = 'lastBoxWeight';

  ///报工总数量
  static const String qty = 'qty';
  ///报工总重(kg)
  static const String weight = 'weight';

  ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重） (kg)
  static const String boxWeight = 'boxWeight';

  //endregion 每增加一个字段定义，必须确保该字段的名称也被添加到[isFieldDefined]的 list 中！！！！！！！！！！！！！！


  ///根据key返回控制器对象
  NumPadController? getNumPadController(String key, List<NumPadController> list){
    return list.firstWhereOrNull((element) => (element.key == key));
  }

  String? getText(String key, List<NumPadController> list){
    var ctl = getNumPadController(key, list);
    if (ctl != null){
      return ctl.controller.text.isEmpty ? null : ctl.controller.text;
    }
    return null;
  }

  ///[isDataByWeightMsg]：当前数据是否来自称重消息
  void setText(String key, String value, List<NumPadController> list, {bool isDataByWeightMsg = false}){
    var ctl = getNumPadController(key, list);
    if (ctl != null){
      ctl.isDataByWeightMsg = isDataByWeightMsg;
      ctl.controller.text = value;
    }
  }

  bool? getEnabled(String key, List<NumPadController> list){
    var ctl = getNumPadController(key, list);
    if (ctl != null){
      return ctl.enabled;
    }
    return null;
  }

  ///设置该输入框是否可以输入（如果该输入框不显示，应该设置成“不可输入”）
  void setEnabled(String key, bool enabled, List<NumPadController> list){
    var ctl = getNumPadController(key, list);
    if (ctl != null) {
      ctl.enabled = enabled;
    }
  }

  ///获取下一个焦点对象
  FocusNode? getNextFocusNode(String key, List<NumPadController> list){
    int nowIndex = list.indexWhere((element) => element.key == key);
    if (nowIndex != -1 && nowIndex < list.length - 1) {
      bool? enabled = getEnabled(list[nowIndex + 1].key, list);
      if (!enabled!){
        return getNextFocusNode(list[nowIndex + 1].key, list);
      }
      else {
        return list[nowIndex + 1].focusNode;
      }
    }
    else if (nowIndex != -1 && nowIndex == list.length - 1) {
      bool? enabled0 = getEnabled(list[0].key, list);
      if (enabled0!){
        return list[0].focusNode;
      }
      else {
        return getNextFocusNode(list[0].key, list);
      }
    }
    else {
      return null;
    }
  }

  bool isFieldDefined(String fieldName){
    List<String> list = [
      eBWeight,
      eBPiece,
      pieceWeight,
      packingWeight,
      num,
      singleBoxQty,
      lastBoxQty,
      boxNumOfPallet,
      singleBoxWeight,
      lastBoxWeight,
      qty,
      weight,
      boxWeight,
    ];
    return list.contains(fieldName);
  }

}