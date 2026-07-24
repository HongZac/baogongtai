import 'package:basement/picker.dart';
import 'package:desktop/app/model/assignment_form_model.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///任务说明新增单个项
class AssignmentAddFormController extends BaseDialogController {

  late final AssignmentFormModel model;

  IPickerAdapter? adapter;
  TextEditingController? tC;
  FocusNode? fn;

  final List<dynamic> dataList = [];

  AssignmentAddFormController({
    required AssignmentFormModel model,
  }){
    this.model = AssignmentFormModel.fromJson(model.toJson());
  }


  @override
  Future<void> onInit() async {
    super.onInit();
    switch (model.formType){
      case 1:
        adapter = await AdapterHelper.getAsyncAdapter(
          model.adapterHelpCode ?? '',
          title: model.title,
          selectedItems: [],
          fieldList: model.fieldList,
          multipleSelection: true,
        );
        break;
      case 0:
      default:
        tC = TextEditingController(text: '');
        fn = FocusNode();
        break;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async { ///页面加载完成后执行
    if (fn != null){
      FocusScope.of(Get.context!).requestFocus(fn);
      fn!.requestFocus();
    }
    });
  }

  void adapterDataOnChanged(List<PickerDataModel> list) {
    dataList.clear();
    dataList.addAll(list.map((e) => e.id));
    update();
  }

  void tcDataOnChanged(String str) {
    dataList.clear();
    switch (model.dataType){
      case 0:
        dataList.add(int.tryParse(str));
        break;
      case 1:
        dataList.add(double.tryParse(str));
        break;
      case 2:
      default:
        dataList.add(str);
        break;
    }
    update();
  }

  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    //r'^(10#[A-Za-z0-9]{5,20})'
    if (actionName == DialogButtonActionEnum.confirm){
      if (dataList.isEmpty){
        ToastNotification(Get.overlayContext!).error('请选择或输入内容！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      dataList;
      model.dataList;
      bool isRepeated = dataList.any((e) => model.dataList.toSet().contains(e));
      if (isRepeated){
        ToastNotification(Get.overlayContext!).error('有内容重复，请检查！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      return DialogReturnDataModel(isCanCloseDialog: true, data: dataList);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }


  @override
  void onClose() {
    tC?.dispose();
    fn?.dispose();
    super.onClose();
  }

}