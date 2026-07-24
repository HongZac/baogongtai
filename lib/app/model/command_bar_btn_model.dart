import 'package:flutter/material.dart';

enum CommandBarBtnType {
  commandBar,
  filled,
  outlined,
  text,
}

class CommandBarBtnModel {

  String keyName;
  String title;
  IconData? icon;
  ///当按钮类型是[CommandBarBtnType.commandBar]时，该字段不起作用
  String? bkgdColorValue;
  ///同一组按钮组如果有一个按钮在类型是[CommandBarBtnType.commandBar]，其余的按钮类型都应该是[CommandBarBtnType.commandBar]
  CommandBarBtnType commandBarBtnType;
  bool isShow;
  ///该控件按钮的权限 keyName（对应数据库中的[ObjectsButtonEntity.enCode]）
  ///
  /// 如果该按钮不需要权限限制的话，该值传 null
  String? btnPermissionKeyName;

  CommandBarBtnModel({
    this.keyName = '',
    this.title = '',
    this.icon,
    this.bkgdColorValue,
    this.commandBarBtnType = CommandBarBtnType.text,
    this.isShow = true,
    this.btnPermissionKeyName,
  });

  factory CommandBarBtnModel.fromJson(Map<String, dynamic> json){
    var entity = CommandBarBtnModel();
    entity.fromJson(json);
    return entity;
  }

  Map<String,dynamic> toJson(){
    return {
      'KeyName': keyName,
      'Title': title,
      'Icon': icon == null
          ? null
          : '${icon!.codePoint},${icon!.fontFamily},${icon!.fontPackage}',
      'BkgdColorValue': bkgdColorValue,
      'CommandBarBtnType': commandBarBtnType.index,
      'IsShow': isShow,
      'BtnPermissionKeyName': btnPermissionKeyName,
    };
  }

  void fromJson(Map<String, dynamic> json){
    keyName = json['KeyName'] ?? '';
    title = json['Title'] ?? '';
    //region [icon]
    if (json['Icon'] == null){
      icon = null;
    }
    else {
      List<String> iconList = json['Icon'].split(',') ?? [];
      int? codePoint;
      if (iconList.length >= 2 && (codePoint = int.tryParse(iconList[0])) != null){
        icon = IconData(
          codePoint!,
          fontFamily: iconList[1] == 'null' ? null : iconList[1],
          fontPackage: iconList.length > 2 ? (iconList[2] == 'null' ? null : iconList[2]) : null
        );
      }
    }
    //endregion
    bkgdColorValue = json['BkgdColorValue'];
    //region
    int? commandBarBtnTypeIndex = int.tryParse(json['CommandBarBtnType'].toString()) ?? -1;
    if (commandBarBtnTypeIndex >= 0 && commandBarBtnTypeIndex < CommandBarBtnType.values.length){
      commandBarBtnType = CommandBarBtnType.values[commandBarBtnTypeIndex];
    }
    else {
      commandBarBtnType = CommandBarBtnType.text;
    }
    //endregion
    isShow = json['IsShow'] ?? true;
    btnPermissionKeyName = json['BtnPermissionKeyName'];
  }
}