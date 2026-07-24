

///数据字段显示项的模型
class InfoFormModel {

  String keyName;
  String title;
  ///组号 0 第一组； 1 第二组
  int groupType;
  int width;
  bool isShow;
  ///是否突出显示（用红色加粗来突出显示关键信息）
  bool isHighlight;

  InfoFormModel({
    this.keyName = '',
    this.title = '',
    this.groupType = -1,
    this.width = 320,
    this.isShow = false,
    this.isHighlight = false,
  });

  factory InfoFormModel.fromJson(Map<String, dynamic> json){
    var entity = InfoFormModel();
    entity.fromJson(json);
    return entity;
  }

  Map<String,dynamic> toJson(){
    return {
      'KeyName': keyName,
      'Title': title,
      'GroupType': groupType,
      'Width': width,
      'IsShow': isShow,
      'IsHighlight': isHighlight,
    };
  }

  void fromJson(Map<String, dynamic> json){
    keyName = json['KeyName'] ?? '';
    title = json['Title'] ?? '';
    groupType = json['GroupType'] ?? -1;
    width = json['Width'] ?? 320;
    isShow = json['IsShow'] ?? false;
    isHighlight = json['IsHighlight'] ?? false;
  }

}

