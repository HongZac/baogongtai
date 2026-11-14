import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
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

  ///通用标签条码（解析）
  ///（二维码标签，以$符号作为组分隔符，以#作为内容分隔符号 $10#H10-3900050$80#1500;）
  ///
  /// {String.key: (<String.FieldName>, <String.TitleName, int.DataType>)}
  ///
  /// [DataType]：0-String, 1-Int, 2-Double, 3-DateTime, 4-Bool
  static const Map<String, (String, String, int)> splitBy$BarcodeAnalysisMap = {
    '10': ('InvCode', '物料编码', 0),
    '11': ('InvId', '物料 Id', 0),
    '12': ('Batch', '批次号', 0),
    '13': ('PosCode', '货位号', 0),
    '15': ('EngineerFigNo', '产品图号', 0),
    '30': ('SupplyCode', '供应商编码', 0),
    '31': ('SupplyId', '供应商 Id', 0),
    '32': ('CustomerCode', '客户编码', 0),
    '33': ('CustomerId', '客户名称', 0),
    '34': ('WarehouseCode', '仓库编码', 0),
    '35': ('WarehouseId', '仓库 Id', 0),
    '36': ('DepCode', '车间编码', 0),
    '37': ('DepId', '车间 Id', 0),
    '38': ('EmployeeCode', '员工编码', 0),
    '39': ('EmployeeId', '员工 Id', 0),
    '40': ('DeviceCode', '设备编码', 0),
    '41': ('DeviceId', '设备 Id', 0),
    '42': ('MouldCode', '模具编码', 0),
    '43': ('MouldId', '模具 Id', 0),
    '50': ('Progid', '系统对象', 1),
    '51': ('InnerId', '单据 Id', 0),
    '52': ('BillCode', '单据编号', 0),
    '54': ('SoCode', '销售单号', 0),
    '55': ('MtoNo', '需求跟踪号', 0),
    '56': ('MtoSeq', '需求跟踪行号', 1),
    '80': ('Qty', '数量', 2),
    '81': ('Unit', '计量单位', 0),
    '82': ('Weight', '重量(数量)', 2),
    '83': ('BoxQty', '箱数', 2),
  };


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
    if (string.substring(0, 1) == r'$'){
    }
    else if (string.substring(0, 1) != '|'){
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


  //region 扫码回调解析处理

  ///通过通用标签条码获取派工单 $10#H10-3900050$80#1500
  Future<ApiResult<T>> splitBy$BarcodeCheckTask<T>(String searchString, {
    Map<String, dynamic> extraParams = const {},
    int rows = 1,
    String? sidx,
  }) async {
    List<String> list = searchString.split(r'$');
    Map<String, dynamic> map = {};
    for (var element in list){
      if (element.isNotEmpty){
        List<String> parts = element.split('#');
        if (parts.length == 2){
          if (ScanInterface.splitBy$BarcodeAnalysisMap.containsKey(parts[0])){
            String key = ScanInterface.splitBy$BarcodeAnalysisMap[parts[0]]!.$1;
            dynamic value = parts[1];
            int dataType = ScanInterface.splitBy$BarcodeAnalysisMap[parts[0]]!.$3;
            switch (dataType){
              //region
              case 1:
                value = int.tryParse(value);
                break;
              case 2:
                value = double.tryParse(value);
                break;
              case 3:
                value = DateTime.tryParse(value);
                break;
              case 4:
                switch (value.toLowerCase()){
                  case 'true':
                  case '1':
                    value = true;
                    break;
                  case 'false':
                  case '0':
                    value = false;
                    break;
                }
                break;
              default:
                break;
              //endregion
            }
            map.addAll({key: value});
          }
        }
      }
    }
    map.addAll(extraParams);
    var res = await MoTaskRepository().getPageList(PageConfig(
      page: 1, rows: rows,
      sidx: sidx,
      queryData: map,
    ));
    if (!res.isSuccess){
      return ApiResult(
        info: '获取派工单时出错：${res.message}',
      );
    }
    if (res.rows.isEmpty){
      return ApiResult(
        info: '未查询到派工单！',
      );
    }
    if (T == MoTaskModel && (res.total ?? 0) > 1){
      return ApiResult(
        info: '查询到多条派工单！',
      );
    }

    return ApiResult(
      code: 200,
      data: T == MoTaskModel
          ? res.rows[0] as T
          : T == (List<MoTaskModel>)
          ? res.rows as T
          : T == (PageResult<MoTaskModel>)
          ? res as T
          : null,
    );
  }

  ///通过通用标签条码获取任务单
  Future<ApiResult<T>> splitBy$BarcodeCheckOrder<T>(String searchString, {
    Map<String, dynamic> extraParams = const {},
    int rows = 1,
    String? sidx,
  }) async {
    List<String> list = searchString.split(r'$');
    Map<String, dynamic> map = {};
    for (var element in list){
      if (element.isNotEmpty){
        List<String> parts = element.split('#');
        if (parts.length == 2){
          if (ScanInterface.splitBy$BarcodeAnalysisMap.containsKey(parts[0])){
            String key = ScanInterface.splitBy$BarcodeAnalysisMap[parts[0]]!.$1;
            dynamic value = parts[1];
            int dataType = ScanInterface.splitBy$BarcodeAnalysisMap[parts[0]]!.$3;
            switch (dataType){
              //region
              case 1:
                value = int.tryParse(value);
                break;
              case 2:
                value = double.tryParse(value);
                break;
              case 3:
                value = DateTime.tryParse(value);
                break;
              case 4:
                switch (value.toLowerCase()){
                  case 'true':
                  case '1':
                    value = true;
                    break;
                  case 'false':
                  case '0':
                    value = false;
                    break;
                }
                break;
              default:
                break;
              //endregion
            }
            map.addAll({key: value});
          }
        }
      }
    }
    map.addAll(extraParams);
    var res = await MoOrderRepository().getPageList(PageConfig(
      page: 1, rows: rows,
      sidx: sidx,
      queryData: map,
    ));
    if (!res.isSuccess){
      return ApiResult(
        info: '获取任务单时出错：${res.message}',
      );
    }
    if (res.rows.isEmpty){
      return ApiResult(
        info: '未查询到任务单！',
      );
    }
    if (T == MoOpOrderModel && (res.total ?? 0) > 1){
      return ApiResult(
        info: '查询到多条任务单！',
      );
    }

    return ApiResult(
      code: 200,
      data: T == MoOpOrderModel
          ? res.rows[0] as T
          : T == (List<MoOpOrderModel>)
          ? res.rows as T
          : T == (PageResult<MoOpOrderModel>)
          ? res as T
          : null,
    );
  }

  ///通过通用标签条码获取物料
  Future<ApiResult<T>> splitBy$BarcodeCheckInv<T>(String searchString, {
    Map<String, dynamic> extraParams = const {},
    int rows = 1,
    String? sidx,
  }) async {
    List<String> list = searchString.split(r'$');
    Map<String, dynamic> map = {};
    for (var element in list){
      if (element.isNotEmpty){
        List<String> parts = element.split('#');
        if (parts.length == 2){
          if (ScanInterface.splitBy$BarcodeAnalysisMap.containsKey(parts[0])){
            String key = ScanInterface.splitBy$BarcodeAnalysisMap[parts[0]]!.$1;
            dynamic value = parts[1];
            int dataType = ScanInterface.splitBy$BarcodeAnalysisMap[parts[0]]!.$3;
            switch (dataType){
              //region
              case 1:
                value = int.tryParse(value);
                break;
              case 2:
                value = double.tryParse(value);
                break;
              case 3:
                value = DateTime.tryParse(value);
                break;
              case 4:
                switch (value.toLowerCase()){
                  case 'true':
                  case '1':
                    value = true;
                    break;
                  case 'false':
                  case '0':
                    value = false;
                    break;
                }
                break;
              default:
                break;
              //endregion
            }
            map.addAll({key: value});
          }
        }
      }
    }
    map.addAll(extraParams);
    var res = await InventoryRepository().getPageList(PageConfig(
      page: 1, rows: rows,
      sidx: sidx,
      queryData: map,
    ));
    if (!res.isSuccess){
      return ApiResult(
        info: '获取物料时出错：${res.message}',
      );
    }
    if (res.rows.isEmpty){
      return ApiResult(
        info: '未查询到物料！',
      );
    }
    if (T == InventoryModel && (res.total ?? 0) > 1){
      return ApiResult(
        info: '查询到多条物料！',
      );
    }

    return ApiResult(
      code: 200,
      data: T == InventoryModel
          ? res.rows[0] as T
          : T == (List<InventoryModel>)
          ? res.rows as T
          : T == (PageResult<InventoryModel>)
          ? res as T
          : null,
    );
  }

  //endregion

}