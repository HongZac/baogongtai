import 'package:basement/item_model.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/utils/app_config.dart';


class AdapterHelper {

  static IPickerAdapter getAdapter(String helpCode, {
    List<PickerDataModel>? selectedItems,
    List<PickerDataModel>? fieldList,
    String? tag, int? progid, String? title,
    Map<String, dynamic>? queryData,
    bool multipleSelection = false,
  }) {
    IPickerAdapter adapter;
    switch(helpCode){
      //region
      case 'inventory': ///产品目录  200090
        adapter = InventoryAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          multipleSelection: multipleSelection,
          initSelectedItems: selectedItems?.map((e) => InventoryModel(id: e.id)).toList(),
        );
        break;
      case 'device':  ///机台、设备选择
        adapter = EAMDeviceAdapter(
          tag: tag,
          progid: progid,
          multipleSelection: multipleSelection,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => EAMDeviceModel(id: e.id)).toList(),
        );
        break;
      case 'dep': /// 车间
        adapter = DepartmentAdapter(
          tag: tag,
          progid: progid,
          type: 4,
          initSelectedItems: selectedItems?.map((e) => DepartmentModel(id: e.id, code: e.code, name: e.name)).toList(),
          multipleSelection: multipleSelection
        );
        break;
      case 'warehouse':  ///仓库
        adapter = DepartmentAdapter(
          tag: tag,
          progid: progid,
          type: 1,
          initSelectedItems: selectedItems?.map((e) => DepartmentModel(id: e.id, code: e.code, name: e.name)).toList(),
          multipleSelection: multipleSelection
        );
        break;
      case 'team': ///班次
        adapter = TeamAdapter(
          tag: tag,
          progid: progid,
          depCode: queryData?['depCode'],
          dateTime: DateTime.tryParse(queryData?['dateTime']?.toString() ?? ''),
          initSelectedItems: selectedItems?.map((e) => MoTeamTimeItem(id:e.id)).toList(),
          multipleSelection: multipleSelection
        );
        break;
      case 'person': ///人员
        adapter = PersonAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => PersonModel(id:e.id)).toList(),
          multipleSelection: multipleSelection,
          customPsnList: fieldList == null
              ? null
              : fieldList.map((e) => PersonModel.fromJson(e.toJson())).toList(),
        );
        break;
      case 'process': ///工序
        bool isNeedGetPostFilter = queryData?['isNeedGetPostFilter'] ?? false;
        List<PostModel>? postInitSelectedItems = queryData?['postInitSelectedItems'];
        bool needGetSOP = queryData?['needGetSOP'] ?? false;
        queryData?.remove('isNeedGetPostFilter');
        queryData?.remove('postInitSelectedItems');
        queryData?.remove('needGetSOP');
        adapter = ProcessAdapter(
          tag: tag,
          progid: progid,
          wbId: queryData?['wbId'],
          moOrderId: queryData?['moOrderId'],
          invId: queryData?['invId'],
          initSelectedItems: selectedItems?.map((e) => MoWorkBillEntryModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
          needGetSOP: needGetSOP,
          isNeedGetPostFilter: isNeedGetPostFilter,
          postInitSelectedItems: postInitSelectedItems,
        );
        break;
      case 'task': ///派工单
        adapter = TaskAdapter(
          tag: tag,
          progid: progid,
          isNeedGetAttributeForm: progid != null,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => MoTaskModel(id:e.id)).toList(),
          multipleSelection: multipleSelection
        );
        break;
      case 'post': ///岗位
        adapter = PostAdapter(
          tag: tag,
          progid: progid,
          initSelectedItems: selectedItems?.map((e) => PostModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'comDefect': ///次品原因
        String itemCode = queryData?['itemCode'] ?? 'ComDefects';
        adapter = DataItemAdapter(
          tag: tag,
          progid: progid,
          adapterTitle: '次品原因选择',
          itemCode: itemCode,
          initSelectedItems: selectedItems,
          multipleSelection: multipleSelection,
        );
        break;
      case 'checkVouchType': ///首检类别
        adapter = DataItemAdapter(
          tag: tag,
          progid: progid,
          adapterTitle: '首检类别选择',
          itemCode: 'CheckType.Vouch',
          initSelectedItems: selectedItems,
          multipleSelection: multipleSelection,
        );
        break;
      case 'eamRole': ///设备角色
        adapter = EAMRoleNoPageAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => EAMRoleModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'andonClass': ///全场呼叫类型
        adapter = AndonClassWithNoPageAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => MoAndonClassModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'mould': ///模具
        adapter = MouldAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => MouldModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'moMixture': ///拌料单
        adapter = MoMixtureAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems!.map((e) => MoMixtureModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'custom': ///自定义
        adapter = CustomAdapter(
            tag: tag,
            progid: progid,
            initSelectedItems: selectedItems,
            fieldList: fieldList ?? [],
            title: title ?? '选择',
            multipleSelection: multipleSelection
        );
        break;
      case 'checkGuide': ///检验指标
        adapter = CheckGuideAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => QMCheckGuideModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'workCenter': ///加工中心
        adapter = MoWorkCenterWithNoPageAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => MoWorkCenterModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'line': ///产线
        adapter = MoBeltLineWithNoPageAdapter(
          tag: tag,
          progid: progid,
          title: title,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => MoBeltLineModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'container': ///装箱容器
        adapter = MoContainerWithNoPageAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => MoContainerModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'orderSN': ///产品序列号
        adapter = MoOrderSNAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => MoOrderSNModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'invClass': ///产品类别
        adapter = InvClassAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => InventoryClassModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'moOper': ///工艺定义
        adapter = MoOperAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => MoOperModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      case 'bomEntry': ///物料清单明细
        adapter = MoBomEntryAdapter(
          tag: tag,
          progid: progid,
          queryData: queryData,
          initSelectedItems: selectedItems?.map((e) => MoBomEntryModel(id: e.id)).toList(),
          multipleSelection: multipleSelection,
        );
        break;
      default:
        adapter = EmptyAdapter(
          tag: tag,
          progid: progid,
          initSelectedItems: selectedItems,
          multipleSelection: multipleSelection
        );
        break;
      //endregion
    }
    return adapter;
  }

  static Future<IPickerAdapter> getAsyncAdapter(String helpCode, {
    List<PickerDataModel>? selectedItems,
    List<PickerDataModel>? fieldList,
    int? progid, String? title,
    Map<String, dynamic>? queryData,
    bool isNeedLoadData = true,
    bool multipleSelection = false
  }) async{
    IPickerAdapter adapter = getAdapter(
        helpCode,
        tag: helpCode,
        progid: progid,
        title: title,
        queryData: queryData,
        selectedItems: selectedItems,
        multipleSelection: multipleSelection,
        fieldList: fieldList
    );

    if (adapter.isUsedPageConfig) {
      Map<String, dynamic> queryData = getQueryData(adapter);
      adapter.pageConfig.queryData!.addAll(queryData);
    }

    if (isNeedLoadData){
      await adapter.loadData();
    }

    if (selectedItems != null){
      await adapter.validModelValue(selectedItems.map((e){
        String data = e.id;
        return data;
      }).toList().join(','));
    }

    return adapter;
  }



  static Map<String, dynamic> getQueryData(IPickerAdapter adapter){
    Map<String, dynamic> queryData = {};

    if (adapter.isUsedPageConfig) {
      //region 状态标签
      ///单据状态标签选中对象的 sign（可多选，取二进制的和）
      int selectedSignBinary = ShareStorageUtil.instance?.read('${BaseSharedPreferencesKeys.PICKER_SIGN_SELECTED_KEY}-${adapter.tag}') ?? AppConfig.selectedSignBinaryNull;
      List<MoSignModel> signList = adapter is TaskAdapter
          ? List.unmodifiable(AppConfig.taskSignList)
          : [];
      if (signList.isNotEmpty){
        List<String> statusList = [];
        for (var element in signList) {
          if (selectedSignBinary & element.sign == element.sign){
            statusList.add(element.content);
          }
        }
        String status = statusList.join(',');
        queryData.addAll({'status': status});
      }
      //endregion
    }

    return queryData;

  }

}