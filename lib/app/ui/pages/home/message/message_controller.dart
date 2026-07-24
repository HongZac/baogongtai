import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';


///系统消息 —— 主页面
class MessageController extends BaseFormWithPageDataController<MsgTypeModel> {

  MessageController({
    super.progId = 150001,
    super.isShowFootWidget = false,
  });


  ///获取消息分类列表,每一个分类的最后一条信息，及总未读数
  @override
  Future<PageResult<MsgTypeModel>> getDataList(PageConfig pageConfig) async{
    var res = await MessageRepository().getTypeList();
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取消息分类列表时出错：${res.message}');
      return PageResult();
    }
    return PageResult(code: 200, rows: res.data, total: 1, page: 1, records: res.data.length);
  }


  @override
  void onClose() {
    super.onClose();
  }
}