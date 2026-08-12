import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_interface.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:flutter/material.dart';


///分页数据 基本页
abstract class BaseFormWithPageDataController<T extends ICloneable>
    extends BaseFormController
    with BaseFormWithPageDataInterface<T> {

  ///是否显示底部内容
  final bool isShowFootWidget;

  final List<T> dataList = [];
  late final PageConfig dataListPageConfig = PageConfig(
    page: 1,
    rows: 7,
    sord: 'desc',
    queryData: {},
  );
  final ScrollController dataListController = ScrollController();

  ///单据总数
  int total = 0;
  ///总页码
  int totalPage = 0;
  ///当前页码
  int nowPage = 0;


  BaseFormWithPageDataController({
    required super.progId,
    super.isShowProgressDialogInOnReady = true,
    super.isNeedGetObjectItem = true,
    this.isShowFootWidget = true,
  });


  @override
  Future<bool> initializeForm() async {
    var res = await _pageChanged(showLoading: false);
    return res;
  }

  Future<bool> _pageChanged({int pageIndex = 1, bool showLoading = true}) async{
    if (showLoading){
      ProgressDialogUtil.showProgressDialog();
    }
    dataListPageConfig.page = pageIndex;
    var res = await getDataList(dataListPageConfig);
    dataList.clear();
    dataList.addAll(res.rows);
    total = res.records ?? 0;
    totalPage = res.total ?? 0;
    nowPage = res.page ?? 0;
    if (!res.isSuccess && showLoading){
      ProgressDialogUtil.close();
      return false;
    }
    else if (showLoading){
      ProgressDialogUtil.update(value: 1);
    }
    return true;
  }
  Future<bool> Function({int pageIndex, bool showLoading}) get pageChanged => _pageChanged;

@override
  void onClose() {
    dataListController.dispose();
    super.onClose();
}
}