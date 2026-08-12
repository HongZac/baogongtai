import 'package:basement/model.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///条码扫描接口
mixin ScanInterface<T> on SerialPortGetXListenerMixin<T> {

  ///当前的数据是否是通过扫码获取的（是否进行了扫码并成功回调）
  bool isDataByScan = false;

  ///扫码回调搜索时对应的关键字段名称
  final List<String> scanQueryDataList = [];


  Widget resetScanWidget(BuildContext context){
    return FilledButton(
      onPressed: () async{
        await resetScan();
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
            kIsWeb || GetPlatform.isWindows
                ? const EdgeInsets.symmetric(vertical: 20, horizontal: 22)
                : const EdgeInsets.symmetric(vertical: 13, horizontal: 22)
        ),
      ),
      child: Text(
        '重置扫描',
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
        ),
      ),
    );
  }

  ///获取默认的扫码标签格式
  String _getBarCodePrefix(String searchString, List<AttributeEntity> attributeList){
    String string = searchString;
    if (string.substring(0, 1) != '|'){
      AttributeEntity? attributeEntity = attributeList.firstWhereOrNull(
              (element) => element.code == 'barcode.prefix');
      if (attributeEntity != null && attributeEntity.text != null){
        String text = attributeEntity.text!;
        if (text.contains('{0}')){
          string = text.replaceAll('{0}', string);
        }
        else {
          string = text + string;
        }
      }
    }
    return string;
  }
  ///获取默认的扫码标签格式
  String Function(String searchString, List<AttributeEntity> attributeList) get getBarCodePrefix => _getBarCodePrefix;


  ///“重置扫描”按钮选中变化（取消扫描） 需要重写
  Future<void> resetScan() async {
    isDataByScan = false;
  }

  ///扫码回调处理
  Future<void> onBarcode(String searchString);

}