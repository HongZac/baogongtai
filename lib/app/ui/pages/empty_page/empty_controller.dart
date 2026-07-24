import 'package:get/get.dart';

class EmptyController extends GetxController {
  final String progId;

  /// 1 显示回退按钮
  final String isShowBackButtonString;
  late final bool isShowBackButton = isShowBackButtonString != '0';


  EmptyController({this.progId = '', this.isShowBackButtonString = '0'});

}