import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_interface.dart';


///分页数据 基本页
abstract class BaseFormWithPageDataInterface<T extends ICloneable> implements BaseFormInterface{

  ///获取列表数据源
  Future<PageResult<T>> getDataList(PageConfig pageConfig) async{ return PageResult(); }

}