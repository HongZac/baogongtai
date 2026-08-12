import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_interface.dart';


///串口/网络数据转换器 无线千分尺
///
///数据格式：一般是11个字节组成 56 56 2D 30 31 33 32 2E 34 32 6D
///             ascii 显示  vv-0132.42m
///
///数据结构： 第1、2字节为发射器地址， 第3-10字节为测量数据，11字节为结束符
///         第3字节 2D 测量结果为负数"-",2B 测量结果为正数"+"
///         4-10字节为测量结果, 0132.42 0对齐
///         11 结束符, 6D m 代表公制单位毫米  69 i 代表英制单位的英寸 0A 为量表专用
class WirelessMicroMeterParser extends TcpSerialParserInterface {

  @override
  Future<String?> parse(List<int> dataList) async {
    if (dataList.isEmpty) {
      return null;
    }

    ///默认数据长度是11
    if (dataList.length != 11){
      return null;
    }

    if (!(dataList.last == 109 || dataList.last == 105 || dataList.last == 10)){
      return null;
    }

    ///此处返回没有处理结束符，直接返回获取测量值
    var data = String.fromCharCodes(dataList.sublist(2, 10));
    return data;
  }
}
