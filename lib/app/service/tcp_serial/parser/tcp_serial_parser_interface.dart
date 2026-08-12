

///串口/网络数据转换器 接口 （将串口数据解析,返回字符串型）
class TcpSerialParserInterface {
  Future<String?> parse(List<int> dataList) async {
    return null;
  }
}
