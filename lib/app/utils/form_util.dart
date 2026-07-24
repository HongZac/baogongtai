class FormUtil {

  //region judgeType（数据校验判断）

  /// 是否日期型格式（2: 10）
  static bool isDate(int? judgeType){
    if (judgeType == null){
      return false;
    }
    return judgeType & 2 == 2;
  }

  /// 是否必填（4: 100）
  static bool isRequired(int? judgeType){
    if (judgeType == null){
      return false;
    }
    return judgeType & 4 == 4;
  }

  ///是否只读（8：1000）
  static bool isReadOnly(int? judgeType){
    if (judgeType == null){
      return false;
    }
    return judgeType & 8 == 8;
  }

  ///是否不能是负数 正数 或 0（16：10000）
  static bool isCannotBeNegativeNum(int? judgeType){
    if (judgeType == null){
      return false;
    }
    return judgeType & 16 == 16;
  }

  ///是否是整数（32：100000）
  static bool isInteger(int? judgeType){
    if (judgeType == null){
      return false;
    }
    return judgeType & 32 == 32;
  }

  ///是否不能为 0（64：1000000）
  static bool isCannotBeZero(int? judgeType){
    if (judgeType == null){
      return false;
    }
    return judgeType & 64 == 64;
  }

  //endregion
}