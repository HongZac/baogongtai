
///对话框返回的数据模型
class DialogReturnDataModel {

  ///是否可以关闭弹窗
  bool isCanCloseDialog;

  ///传递回去的数据
  dynamic data;

  DialogReturnDataModel({required this.isCanCloseDialog, this.data});
}