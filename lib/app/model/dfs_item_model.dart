
class DFSItemModel{

  int width;
  String title;
  double alignmentX;
  final double alignmentY;
  String alignmentName;
  String enTitle;
  bool isVisible;

  DFSItemModel({
    this.width = 1,
    this.title = '',
    this.alignmentX = -1,
    this.alignmentY = 0,
    this.alignmentName = '左侧居中',
    this.enTitle = '',
    this.isVisible = true,
  });

  factory DFSItemModel.fromJson(Map<String, dynamic> json){
    var entity = DFSItemModel();
    entity.fromJson(json);
    return entity;
  }

  Map<String,dynamic> toJson(){
    return {
      'IsExpansionTileOpen': false,
      'Width' : width,
      'Title' : title,
      'EnTitle' : enTitle,
      'AlignmentX' : alignmentX,
      'AlignmentY' : alignmentY,
      'AlignmentName' : alignmentName,
    };
  }

  void fromJson(Map<String, dynamic> json){
    alignmentX = json['AlignmentX'] ?? -1;
    alignmentName = json['AlignmentName'] ?? '左侧居中';
    width = json['Width'] ?? 5;
    title = json['Title'] ?? '';
    enTitle = json['EnTitle'] ?? '';
  }

  double getAlignmentX(String alignmentName){
    switch (alignmentName){
      case '左侧居中':
        return -1;
      case '居中':
        return 0;
      case '右侧居中':
        return 1;
      default:
        return -1;
    }
  }

  String getAlignmentName(double alignmentX, double alignmentY){
    String alignmentName = '';
    if (alignmentX == 0 && alignmentY == 0){
      alignmentName = '居中';
    }
    else if (alignmentX == 1 && alignmentY == 0){
      alignmentName = '右侧居中';
    }
    else if (alignmentX == -1 && alignmentY == 0){
      alignmentName = '左侧居中';
    }
    else {
      alignmentName = '左侧居中';
    }
    return alignmentName;
  }

}