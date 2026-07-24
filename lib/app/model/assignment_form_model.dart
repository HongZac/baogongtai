
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/app_config.dart';

class AssignmentFormModel {

  String field;
  String title;
  String sharedKey;

  /// 0 int
  ///
  /// 1 double
  ///
  /// 2 text
  int? dataType;

  /// 0 文本输入框
  ///
  /// 1  选择器
  int? formType;

  String? adapterHelpCode;
  final List<PickerDataModel> fieldList = [];

  final List<dynamic> dataList = [];

  String hintText;

  ///必须符合全部条件（No：符合其中一个条件即可）
  bool isAllConditionMustBeMet = AppConfig.isAllConditionMustBeMet;


  AssignmentFormModel({
    this.field = '',
    this.title = '',
    this.sharedKey = '',
    this.dataType,
    this.formType,
    this.adapterHelpCode,
    List<PickerDataModel>? fieldList,
    this.hintText = '',
    this.isAllConditionMustBeMet = AppConfig.isAllConditionMustBeMet,
  }){
    this.fieldList.addAll(fieldList ?? []);
    dataList.clear();
    var data = ShareStorageUtil.instance?.read(sharedKey);
    if (data != null){
      if (data is List){
        dataList.addAll(data);
      }
      else {
        dataList.add(data);
      }
    }
  }

  factory AssignmentFormModel.fromJson(Map<String, dynamic> json){
    var entity = AssignmentFormModel();
    entity.fromJson(json);
    return entity;
  }

  Map<String,dynamic> toJson(){
    return {
      'Field': field,
      'Title': title,
      'SharedKey': sharedKey,
      'DataType': dataType,
      'FormType': formType,
      'AdapterHelpCode': adapterHelpCode,
      'FieldList': fieldList.map((e) => e.toJson()).toList(),
      'DataList': dataList,
      'HintText': hintText,
      'IsAllConditionMustBeMet': isAllConditionMustBeMet,
    };
  }

  void fromJson(Map<String, dynamic> json){
    field = json['Field'] ?? '';
    title = json['Title'] ?? '';
    sharedKey = json['SharedKey'] ?? '';
    dataType = json['DataType'];
    formType = json['FormType'];
    adapterHelpCode = json['AdapterHelpCode'];
    fieldList.clear();
    fieldList.addAll(json['FieldList'] == null ? [] : (json['FieldList'] as List).map((e) => PickerDataModel.fromJson(e)));
    dataList.clear();
    dataList.addAll(json['DataList'] == null ? [] : (json['DataList'] as List));
    hintText = json['HintText'] ?? '';
    isAllConditionMustBeMet = json['IsAllConditionMustBeMet'] ?? AppConfig.isAllConditionMustBeMet;
  }

  void reset() {
    dataList.clear();
    var data = ShareStorageUtil.instance?.read(sharedKey);
    if (data != null){
      if (data is List){
        dataList.addAll(data);
      }
      else {
        dataList.add(data);
      }
    }

    isAllConditionMustBeMet = ShareStorageUtil.instance?.read(sharedKey + '-isAllConditionMustBeMet') ?? AppConfig.isAllConditionMustBeMet;
  }

}