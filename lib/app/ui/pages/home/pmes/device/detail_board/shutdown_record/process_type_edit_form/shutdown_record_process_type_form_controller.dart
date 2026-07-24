import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_view.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///停机原因编辑窗体 670003
class ShutdownRecordProcessTypeFormController extends BaseFormController {

  ///停机原因分类列表（大类 + 大类下面的子类）
  final List<TreeViewModel> processTypeClassList = [];

  ///已经分类好的停机原因列表
  final Map<String, List<DataItemEntity>> processTypeTreeListMap = {};

  ///前台显示的拓展面板列表的展开状态
  final List<bool> isExpandedList = [];

  final double expansionPanelWidth = 350;
  final double expansionPanelHeight = 600;

  PersonAdapter? personAdapter;

  final String processId;
  String? processType;
  String? operatorId;
  String? operatorName;
  String? desc;


  ShutdownRecordProcessTypeFormController({
    super.progId = 670003,
    this.processType,
    this.desc,
    String? operatorId,
    required this.processId,
  }){
    this.operatorId = operatorId ?? BaseService.profile.objId;
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  @override
  Future<bool> initializeForm() async {
    await getProcessTypeParentList();
    await getProcessTypeList();
    await getPersonAdapter();
    return true;
  }

  Future<void> getProcessTypeParentList() async {
    var res = await DataItemRepository().getClassTree('');
    if (!res.isSuccess) {
      ToastNotification(Get.overlayContext!).error('获取停机原因分类列表时出错：${res.message}！');
      return;
    }
    TreeViewModel model = getProcessTypeClassDataItemTree(res.data);
    if (model.value != 'ProcessType') {
      ToastNotification(Get.overlayContext!).error('未获到取停机原因分类列表，请检查！');
      return;
    }
    processTypeClassList.add(model);
    processTypeClassList.addAll((model.childNodes ?? []).map((e) => e));
    isExpandedList.addAll(processTypeClassList.map((e) => true));
  }

  TreeViewModel getProcessTypeClassDataItemTree(List<TreeViewModel> list) {
    TreeViewModel model = TreeViewModel();
    for (var element in list) {
      if (element.value == 'ProcessType') {
        model = element;
        break; ///则跳出循环
      }
      else if ((element.childNodes ?? []).isNotEmpty) {
        model = getProcessTypeClassDataItemTree(element.childNodes!);
        if (model.id.isNotEmpty) {
          break; ///则跳出循环
        }
      }
    }

    return model;
  }

  Future<void> getProcessTypeList() async {
    if (processTypeClassList.isEmpty) {
      return;
    }
    final List<DataItemEntity> processTypeList = [];
    var res = await DataItemRepository().getPageList(PageConfig(
      page: 1,
      rows: 1000,
      queryData: {
        processTypeClassList[0].title ?? processTypeClassList[0].id: processTypeClassList[0].id,
      },
    ));
    if (!res.isSuccess) {
      ToastNotification(Get.overlayContext!).error('获取停机原因列表时出错：${res.message}！');
      return;
    }
    processTypeList.addAll(res.rows);
    processTypeTreeListMap.addEntries(processTypeClassList.map(
            (e) => MapEntry(e.value, [])));
    processTypeList.forEach((element) {
      if (processTypeTreeListMap.containsKey(element.itemCode)){
        processTypeTreeListMap[element.itemCode]!.add(element);
      }
    });

    processTypeTreeListMap.keys.toList().forEach((element) {
      if (processTypeTreeListMap[element]!.isEmpty){
        processTypeClassList.removeWhere((element1) => element1.value == element);
        isExpandedList.removeLast();
        processTypeTreeListMap.remove(element);
      }
    });
  }

  Future<void> getPersonAdapter() async{
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      isNeedLoadData: true,
      queryData: {
        'Active': 0, ///Active:0不显示离职人员
      },
      selectedItems: operatorId == null || operatorId!.isEmpty
          ? []
          : [PickerDataModel(id: operatorId)],
    ) as PersonAdapter;
    operatorName = operatorId == null || operatorId!.isEmpty
        ? null
        : personAdapter!.dataList.firstWhereOrNull(
            (element) => element.isSelected)?.name;
  }


  Future<void> processTypeOnChanged(String? value) async {
    processType = value;
    update();
  }

  Future<void> psnOnChanged(PickerDataModel model) async {
    operatorId = model.id;
    operatorName = model.name;
    update();
  }

  Future<void> descOnChanged() async {
    var dialogRes = await DialogUtils.showCustomDialog<EditFieldController, String>(
      Get.context!,
      title: '停机原因备注填写',
      onConfirmName: '确认',
      barrierDismissible: false,
      initialWidth: 550, initialHeight: 260,
      contentPadding: const EdgeInsets.all(12),
      content: EditFieldView(),
      controller: EditFieldController(
        initTCText: desc ?? '',
      ),
    );

    desc = dialogRes;
    update();
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      var res = await onSave();
      if (!res.isSuccess){
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      return DialogReturnDataModel(isCanCloseDialog: true, data: res.data ?? '');
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

  Future<ApiResult<String?>> onSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在提交！',
      );
      return ApiResult();
    }
    isLoading = true;
    //region 保存前校验
    if (processType == null || processType!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择停机原因！");
      isLoading = false;
      return ApiResult();
    }
    //endregion
    ProgressDialogUtil.showProgressDialog(msg: '正在提交全场呼叫', completedMsg: '全场呼叫提交成功！');
    Map<String, dynamic> dataMap = {
      'ProcessType': int.tryParse(processType!),
      'Operator': operatorId,
      'OperateDate': DateTime.now().toString(),
      'Description': desc,
    };
    var res = await MoProcessRepository().feedbackReason(processId, dataMap);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).warn('停机原因提交失败！${res.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return ApiResult();
    }

    isLoading = false;
    ProgressDialogUtil.update();
    await ProgressDialogUtil.awaitCompletionDelay();
    return res.data;
  }


}
