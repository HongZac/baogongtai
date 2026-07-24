

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/pages/home/andon/andon_add/extra_form/andon_add_extra_form_controller.dart';
import 'package:desktop/app/ui/pages/home/andon/andon_add/extra_form/andon_add_extra_form_page.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///安灯系统 新增全场呼叫页面
class AndonAddController extends BaseFormController{

  ///首页选中的车间 Id
  final String initDepId;

  final String initDeviceId;
  final String initDeviceCode;
  final String initDeviceName;

  ///是否选中默认的呼叫类型
  final bool isNeedSelectedIsDefault;

  final MoAndonServiceModel andonServiceModel = MoAndonServiceModel();

  ///全场呼叫分类明细列表
  final List<MoAndonClassModel> andonClassList = [];
  /////全场呼叫分类树形结构列表
  //final List<MoAndonClassModel> andonClassTreeList = [];
  ///车间过滤后的全场呼叫分类树形结构列表
  final List<MoAndonClassModel> andonClassFilterTreeList = [];
  bool isAndonClassListNoChild = true;
  ///前台显示的拓展面板列表的数据源
  final List<List<MoAndonClassModel>> andonClassChoiceList = [];
  ///前台显示的拓展面板列表的展开状态
  final List<bool> isExpandedList = [];
  ///前台选中的的分类列表（多级列表，可能会选中多个，提交时取最后一个）
  final List<MoAndonClassModel> andonClassSelectedList = [];

  /////全场呼叫流程模板列表
  //final List<WfSchemeInfoModel> schemeInfoList = [];

  ///是否显示【数量】  1 显示；0 不显示
  int? showAffected;
  ///异常类别组: 1:模具 2:设备 4:材料
  int? serviceKind;
  /////关联的流程实例Id（工作流模板Id）
  //String? schemeInfoId;
  DepartmentAdapter? departmentAdapter;


  AndonAddController({
    super.progId = 710012,
    this.initDepId = '',
    this.initDeviceId = '',
    this.initDeviceCode = '',
    this.initDeviceName = '',
    this.isNeedSelectedIsDefault = false,
  });


  @override
  void onInit(){
    super.onInit();
    andonServiceModel.depId = initDepId;
    andonServiceModel.deviceId = initDeviceId;
    andonServiceModel.deviceCode = initDeviceCode;
    andonServiceModel.deviceName = initDeviceName;
  }

  @override
  Future<bool> initializeForm() async {
    await getAndonClassList();
    //await getSchemeInfoList();
    getAndonClassFilterTreeList();
    await getDepAdapter();
    if (isNeedSelectedIsDefault){
      if (andonClassChoiceList.isNotEmpty && andonClassChoiceList[0].isNotEmpty){
        await andonClassOnChanged(0, andonClassChoiceList[0][0]);
      }
    }
    else {
      //region 如果拓展面板列表的单个项列表中只有一个项，则默认选中
      andonClassChoiceList.forEach((element) async {
        if (element.length == 1){
          await andonClassOnChanged(0, element[0]);
        }
      });
      //endregion
    }
    return true;
  }


  Future<void> getAndonClassList() async {
    andonClassList.clear();
    PageConfig pageConfig = PageConfig(
      page: 1, rows: 999,
    );
    var result = await MoAndonClassRepository().getPageList(pageConfig);
    if (result.isSuccess) {
      andonClassList.addAll(result.rows);
    }
  }

  void getAndonClassFilterTreeList(){
    List<MoAndonClassModel> andonClassList = [];
    if ((andonServiceModel.depId ?? '').isEmpty){
      andonClassList.addAll(
        this.andonClassList.map((e) => MoAndonClassModel.fromJson(e.toJson()))
      );
    }
    else {
      andonClassList.addAll(this.andonClassList.where(
              (element) => element.depId == andonServiceModel.depId
      ).map((e) => MoAndonClassModel.fromJson(e.toJson())));
    }

    andonClassFilterTreeList.clear();
    ///先把父级都放入[andonClassFilterTreeList]中
    andonClassFilterTreeList.addAll(andonClassList.where(
            (element) => (element.parentId.isEmpty || element.parentId == '0')
    ));

    ///默认的呼叫类型
    List<MoAndonClassModel> defaultList = andonClassList.where((element) => element.isDefault == 1).toList();

    ///如果总列表的长度和父级列表的长度相同，或者父级列表为空，总长度不为空，则代表这些项没有子级
    isAndonClassListNoChild = isNeedSelectedIsDefault && defaultList.isNotEmpty
        ? true
        : (andonClassList.length == andonClassFilterTreeList.length
        || (andonClassList.isNotEmpty && andonClassFilterTreeList.isEmpty));


    if (isNeedSelectedIsDefault && defaultList.isNotEmpty){
      andonClassChoiceList.clear();
      andonClassChoiceList.add(defaultList);
    }
    else if (!isAndonClassListNoChild){
      List<MoAndonClassModel> list = andonClassList.where(
              (element) => element.parentId.isNotEmpty && element.parentId != '0'
      ).toList();
      for (var element in andonClassList) {
        if (element.parentId.isNotEmpty && element.parentId != '0'){
          List<MoAndonClassModel> children = list.where(
                  (element1) => element1.parentId == element.id).toList();
          if (children.isNotEmpty){
            element.children.addAll(children);
          }
          MoAndonClassModel? parentItem1 = andonClassFilterTreeList.firstWhereOrNull(
                  (element1) => element1.id == element.parentId);
          if (parentItem1 != null){
            parentItem1.children.add(element);
          }
        }
      }
      andonClassChoiceList.clear();
      andonClassChoiceList.add(andonClassFilterTreeList);
    }
    else {
      andonClassChoiceList.clear();
      andonClassChoiceList.add(andonClassList);
    }

    isExpandedList.clear();
    isExpandedList.add(true);
    andonClassSelectedList.clear();
    andonServiceModel.serviceClass = null;
    andonServiceModel.serviceCode = null;
    andonServiceModel.serviceName = null;
    showAffected = null;
    serviceKind = null;
    //schemeInfoId = null;
    afterAndonClassOnChanged();
  }


  //region Adapter

  Future<void> getDepAdapter() async {
    List<PickerDataModel> list = [PickerDataModel(id: initDepId)];
    departmentAdapter = await AdapterHelper.getAsyncAdapter(
      'dep',
      selectedItems: list,
    ) as DepartmentAdapter;
  }

  //endregion


  //region OnChanged

  /// 全场呼叫类型选择变化
  ///
  /// index：当前选择器是第几个
  Future<void> andonClassOnChanged(int index, MoAndonClassModel item) async {
    MoAndonClassModel? selectedAndonClassModel;
    if (isAndonClassListNoChild){
      for (var element in andonClassChoiceList[0]) { element.isChoice = false; }
      item.isChoice = true;
      selectedAndonClassModel = andonClassChoiceList[0][index];
      andonClassSelectedList.clear();
      andonClassSelectedList.add(selectedAndonClassModel);
    }
    else {
      for (var element in andonClassChoiceList[index]) { element.isChoice = false; }
      item.isChoice = true;
      if (andonClassSelectedList.length > index && andonClassSelectedList[index].id == item.id){
        return;
      }
      if (index < andonClassChoiceList.length - 1){
        andonClassChoiceList.removeRange(index + 1, andonClassChoiceList.length);
        isExpandedList.removeRange(index + 1, isExpandedList.length);
      }
      andonClassSelectedList.clear();
      andonClassSelectedList.addAll(andonClassChoiceList.map((e){
        MoAndonClassModel? item = e.firstWhereOrNull((element) => element.isChoice);
        return item ?? MoAndonClassModel();
      }));
      List<MoAndonClassModel> acList = [];
      acList.addAll(andonClassFilterTreeList);
      for (var element in andonClassSelectedList) {
        MoAndonClassModel? model = acList.firstWhereOrNull((element1) => element1.id == element.id);
        acList.clear();
        if (model != null){
          acList.addAll(model.children);
        }
      }
      if (acList.isNotEmpty){
        for (var element in acList) { element.isChoice = false; }
        andonClassChoiceList.add(acList);
        isExpandedList.add(true);
      }
      String lastSelectedId = andonClassChoiceList.last.firstWhereOrNull((element) => element.isChoice)?.id ?? '';
      selectedAndonClassModel = andonClassList.firstWhereOrNull((element) => element.id == lastSelectedId);
    }
    andonServiceModel.serviceClass = selectedAndonClassModel?.id;
    andonServiceModel.serviceCode = selectedAndonClassModel?.classCode;
    andonServiceModel.serviceName = selectedAndonClassModel?.className;
    showAffected = selectedAndonClassModel?.showAffected;
    serviceKind = selectedAndonClassModel?.kind;
    //schemeInfoId = selectedAndonClassModel?.schemeInfoId;
    afterAndonClassOnChanged();
    if (selectedAndonClassModel?.depId != andonServiceModel.depId){
      await departmentAdapter?.validModelValue(selectedAndonClassModel?.depId);
      depOnChanged(
        PickerDataModel(
          id: selectedAndonClassModel?.depId,
          code: selectedAndonClassModel?.depCode,
          name: selectedAndonClassModel?.depName,
        ),
        filterAndonClassList: false,
      );
    }
    update();
  }
  void afterAndonClassOnChanged(){
    andonServiceModel.mouldId = null;
    andonServiceModel.mouldCode = null;
    andonServiceModel.mouldName = null;
    if (initDeviceId.isEmpty){
      andonServiceModel.deviceId = null;
      andonServiceModel.deviceCode = null;
      andonServiceModel.deviceName = null;
    }
    andonServiceModel.invId = null;
    andonServiceModel.invCode = null;
    andonServiceModel.invName = null;
    andonServiceModel.affected = null;
  }

  void depOnChanged(PickerDataModel model, {bool filterAndonClassList = true}) {
    andonServiceModel.depId = model.id;
    if (filterAndonClassList){
      getAndonClassFilterTreeList();
    }
    update();
  }

  ///额外的信息填写
  Future<void> editExtraForm() async {
    var res = await DialogUtils.showCustomDialog<AndonAddExtraFormController, MoAndonServiceModel>(
      Get.context!,
      title: '发起新的全场呼叫-额外信息填写',
      isMaximize: true,
      contentPadding: const EdgeInsets.all(12),
      content: AndonAddExtraFormPage(),
      controller: AndonAddExtraFormController(
        andonServiceModel: andonServiceModel,
        showAffected: showAffected,
        serviceKind: serviceKind,
        andonClassSelectedTitle: andonClassSelectedList.isNotEmpty
            ? andonClassSelectedList.map((e) => e.className).join(' > ')
            : '请选择呼叫类型',
        isShowDevicePicker: initDeviceId.isEmpty,
      ),
    );
    if (res == null){
      return;
    }
    andonServiceModel.mouldId = res.mouldId;
    andonServiceModel.mouldCode = res.mouldCode;
    andonServiceModel.mouldName = res.mouldName;
    if (initDeviceId.isEmpty) {
      andonServiceModel.deviceId = res.deviceId;
      andonServiceModel.deviceCode = res.deviceCode;
      andonServiceModel.deviceName = res.deviceName;
    }
    andonServiceModel.invId = res.invId;
    andonServiceModel.invCode = res.invCode;
    andonServiceModel.invName = res.invName;
    andonServiceModel.affected = res.affected;
    andonServiceModel.submitDescription = res.submitDescription;
    andonServiceModel.imageList.clear();
    andonServiceModel.imageList.addAll(res.imageList);
    andonServiceModel.attach = res.attach;
    update();
  }

  //endregion


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
    if (andonServiceModel.serviceClass == null || andonServiceModel.serviceClass!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择呼叫类型！");
      isLoading = false;
      return ApiResult();
    }
    if (((serviceKind ?? 0) & 1 == 1) && (andonServiceModel.mouldId == null || andonServiceModel.mouldId!.isEmpty)){
      ToastNotification(Get.overlayContext!).warn("请选择模具！");
      isLoading = false;
      return ApiResult();
    }
    if (((serviceKind ?? 0) & 2 == 2) && (andonServiceModel.deviceId == null || andonServiceModel.deviceId!.isEmpty)){
      ToastNotification(Get.overlayContext!).warn("请选择设备！");
      isLoading = false;
      return ApiResult();
    }
    if (((serviceKind ?? 0) & 4 == 4) && (andonServiceModel.invId == null || andonServiceModel.invId!.isEmpty)){
      ToastNotification(Get.overlayContext!).warn("请选择产品！");
      isLoading = false;
      return ApiResult();
    }
    if (showAffected == 1 && andonServiceModel.affected == null){
      ToastNotification(Get.overlayContext!).warn("请输入数量！");
      isLoading = false;
      return ApiResult();
    }
    //endregion
    /*var _dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!,
      barrierDismissible: false,
      msg: '确认提交全场呼叫？',
    );
    if (_dialogRes == null || !_dialogRes){
      isLoading = false;
      return ApiResult();
    }*/
    ProgressDialogUtil.showProgressDialog(msg: '正在提交全场呼叫', completedMsg: '全场呼叫提交成功！');
    andonServiceModel.progid = progId;
    andonServiceModel.serviceSign = 1;
    andonServiceModel.sign = 1;
    andonServiceModel.submitDate = DateTime.now();
    var res = await AndonServiceRepository().saveVoucher('', andonServiceModel, andonServiceModel.imageList);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).warn('全场呼叫提交失败！${res.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return ApiResult();
    }
    //if (schemeInfoId != null && schemeInfoId!.isNotEmpty){
    //  WfSchemeInfoModel? item = schemeInfoList.firstWhereOrNull((element) => element.id == schemeInfoId);
    //  if (item != null){
    //    item.progid;
    //    switch (item.progid){
    //      case 700204:
    //        //region 模具问题(模具维修)
    //        //endregion
    //        break;
    //      case 811010:
    //        //region 产品问题（次品）
    //        //endregion
    //        break;
    //      case 220016:
    //        //region 设备问题（设备维修）
    //        //endregion
    //        break;
    //    }
    //  }
    //}

    isLoading = false;
    ProgressDialogUtil.update();
    await ProgressDialogUtil.awaitCompletionDelay();
    res.data.data ??= '';
    return res.data;
  }


  @override
  void onClose() {
    super.onClose();
  }

}