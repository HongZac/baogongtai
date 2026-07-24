import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BtnStyleUtils {

  ///20 12
  ///14 8
  ///18 14 decoration
  ///8 0
  ///Size(310, 72) Size(310, 60)


  static WidgetStateProperty<EdgeInsetsGeometry?>? padding() {
    ///四字？
    ///发起呼叫
    kIsWeb || GetPlatform.isWindows
        ? const EdgeInsets.symmetric(vertical: 20, horizontal: 16)
        : const EdgeInsets.symmetric(vertical: 12, horizontal: 16);

    ///额外信息填写
    const EdgeInsets.symmetric(vertical: 18, horizontal: 8);

    ///远程打印服务 修改 删除 取消服务 打印
    const EdgeInsets.symmetric(vertical: 14, horizontal: 14);

    const EdgeInsets.symmetric(vertical: 20, horizontal: 22);









    return WidgetStateProperty.all( ///paddingpadding
        kIsWeb || GetPlatform.isWindows
            ? const EdgeInsets.symmetric(vertical: 20, horizontal: 16)
            : const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
    );

  }
}