

///现有的解析器定义
enum TcpSerialParserEnum {

  ///默认
  defaultParser('默认'),

  ///无线卡尺 1
  wirelessMicroMeter('无线卡尺 1'),

  ///反向接收顺序
  msgReverseOrder('反向接收顺序'),

  ///读卡器 1
  cardReadA('读卡器 1');

  final String name;
  const TcpSerialParserEnum(this.name);

}