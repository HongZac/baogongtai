
import 'package:basement/model.dart';

class MoSignModel extends ICloneable{
  String keyName;

  @Deprecated('弃用')
  bool isSelected;
  String title;
  String content;
  int sign;
  int? lTSign;
  int? gESign;

  MoSignModel({
    this.keyName = '',
    this.isSelected = false,
    this.title = '',
    this.content = '',
    required this.sign,
    this.lTSign,
    this.gESign,
  });

  factory MoSignModel.fromJson(Map<String, dynamic> json) {
    var model = MoSignModel(sign: -1);
    model.fromJson(json);
    return model;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    keyName = json['KeyName'];
    isSelected = json['IsSelected'];
    title = json['Title'];
    content = json['Content'];
    sign = json['Sign'];
    lTSign = json['LTSign'];
    gESign = json['GESign'];
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'KeyName': keyName,
      'IsSelected': isSelected,
      'Title': title,
      'Content': content,
      'Sign': sign,
      'LTSign': lTSign,
      'GESign': gESign,
    };
    return map;
  }

}