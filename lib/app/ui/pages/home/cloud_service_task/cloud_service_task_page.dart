import 'dart:math';
import 'dart:typed_data';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:desktop/app/model/pdf_controller_with_key_model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/attach_view/attach_utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/cloud_service_task/cloud_service_task_controller.dart';
import 'package:desktop/app/ui/pages/pdf_screen/pdf_screen_controller.dart';
import 'package:desktop/app/ui/pages/pdf_screen/pdf_screen_page.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';


///远程云消息列表显示窗口
class CloudServiceTaskPage extends BaseFormPage<CloudServiceTaskController> {

  @override
  Widget contentWidget(BuildContext context, CloudServiceTaskController _){
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.all(8),
            child: topWidget(context, _),
          ),

          Expanded(
            child: _.isLoadNewData ?
            SpinKitCircle(
              color: Colors.grey,
              size: min(Get.width, Get.height) * 0.2,
            ) :
            _.selectedItem != null ?
            largeViewWidget(context, _) :
            SizedBox.shrink(),
          ),

          ///轮播图
          //if (_.taskList.length > 1)
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                skipBtnWidget(
                  context, _,
                  iconData: Icons.skip_previous,
                  onPressed: (){
                    controller.sliderPagePrevious();
                  },
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints){
                      int num = (constraints.maxWidth / _.sliderItemSize.width).truncate();
                      _.isShowSliderController = _.taskList.length > num;

                      Widget itemWidget(int index) {
                        return Material(
                          child: InkWell(
                            onTap: (){
                              controller.sliderPageJump(index);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _.sliderPageIndex == index
                                      ? AppColors.starColor
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: sliderItemWidget(
                                context,
                                _,
                                _.taskList[index],
                              ),
                            ),
                          ),
                        );
                      }

                      if (_.taskList.length <= num){
                        return SizedBox(
                          height: _.sliderItemSize.height,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_.taskList.length, (index){
                              return itemWidget(index);
                            }),
                          ),
                        );
                      }
                      else {
                        return CarouselSlider(
                          carouselController: _.sliderController,
                          options: CarouselOptions(
                            height: _.sliderItemSize.height,
                            initialPage: _.sliderPageIndex,
                            viewportFraction: 1 / num,
                            enableInfiniteScroll: _.taskList.length > num,
                            onPageChanged: (int index, CarouselPageChangedReason reason){
                              controller.sliderPageIndexOnChanged(index);
                            },
                          ),
                          items: List.generate(_.taskList.length, (index){
                            return itemWidget(index);
                          }),
                        );
                      }
                    },
                  ),
                ),

                skipBtnWidget(
                  context, _,
                  iconData: Icons.skip_next,
                  onPressed: (){
                    controller.sliderPageNext();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget topWidget(BuildContext context, CloudServiceTaskController _){
    switch (_.cloudServiceTaskEntity?.name){
      case 'singleAttach':
      case 'attachs':
        if (_.selectedItem?['model'] is InitialPreviewConfigModel){
          InitialPreviewConfigModel data = _.selectedItem!['model'] as InitialPreviewConfigModel;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(
                    data.caption ?? '',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis
                ),
                const SizedBox(width: 4,),
                Text(
                    '${((data.size ?? 0) / 1024 / 1024).toStringAsFixed(2)}MB',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis
                ),
                const SizedBox(width: 4,),
                Expanded(
                  child: commandBarWidget(context, _),
                ),
              ],
            ),
          );
        }
    }
    return SizedBox.shrink();
  }

  Widget commandBarWidget(BuildContext context, CloudServiceTaskController _){
    switch (_.cloudServiceTaskEntity?.name) {
      case 'singleAttach':
      case 'attachs':
        if (_.selectedItem?['model'] is InitialPreviewConfigModel) {
          InitialPreviewConfigModel data = _.selectedItem!['model'] as InitialPreviewConfigModel;
          switch (data.type){
            case 'pdf':
              PdfScreenPage view = _.selectedItem!['view'] as PdfScreenPage;
              PdfScreenController ctl = _.selectedItem!['controller'] as PdfScreenController;
              return view.toolWidget(
                context, ctl,
              );
          }
        }
        break;
    }
    return SizedBox.shrink();
  }

  Widget largeViewWidget(BuildContext context, CloudServiceTaskController _){
    switch (_.cloudServiceTaskEntity?.name) {
      case 'singleAttach':
      case 'attachs':
        if (_.selectedItem?['model'] is InitialPreviewConfigModel) {
          InitialPreviewConfigModel data = _.selectedItem!['model'] as InitialPreviewConfigModel;
          switch (data.type){
            case 'pdf':
              PdfScreenPage view = _.selectedItem!['view'] as PdfScreenPage;
              PdfScreenController ctl = _.selectedItem!['controller'] as PdfScreenController;
              return view.childWidget(context, ctl);
            case 'image':
              return _.selectedItem!['view'];
            case 'mp4':
            case 'video':
              return InkWell(
                onTap: () async {
                  String url = _.selectedItem!['url'];
                  Uri uri = Uri.parse(AddressService.getUrl(url));
                  var res = await launchUrl(uri);
                  if (!res){
                    ToastNotification(Get.overlayContext!).error("文件打开失败！");
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.ondemand_video,
                        size: 120,
                        color: AppColors.totalColor
                      ),
                      Text(
                        '点击播放视频',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              );
            case 'doc':
            case 'docx':
            case 'office':
              return Icon(
                Icons.description,
                size: 120,
                color: AppColors.totalColor
              );
          }
        }
        break;
    }
    return SizedBox.shrink();
  }

  /// [item]：
  ///
  /// {
  ///
  /// 'docId': docId,
  ///
  /// 'id': id,
  ///
  /// 'progid': progid,
  ///
  /// 'category': category,
  ///
  /// 'key': item.key,
  ///
  /// 'model': <InitialPreviewConfigModel>
  ///
  /// 'url': <String>
  ///
  /// 'pdfDataModel': <PdfControllerWithKeyModel>
  ///
  /// 'view'
  ///
  /// 'controller'
  ///
  /// 'onDispose':
  ///
  /// }
  Widget sliderItemWidget(BuildContext context, CloudServiceTaskController _, Map<String, dynamic> item){
    Widget child = SizedBox.shrink();
    switch (_.cloudServiceTaskEntity?.name){
      case 'singleAttach':
      case 'attachs':
        if (item['model'] is InitialPreviewConfigModel){
          InitialPreviewConfigModel data = item['model'] as InitialPreviewConfigModel;
          Uint8List? pdfFirstPage;
          if (item['pdfDataModel'] is PdfControllerWithKeyModel){
            PdfControllerWithKeyModel pdfData = item['pdfDataModel'] as PdfControllerWithKeyModel;
            pdfFirstPage = pdfData.imageUint8List;
          }
          child = SizedBox(
            width: _.sliderItemSize.width,
            height: _.sliderItemSize.height,
            child: AttachUtils.buildImage(
              context,
              data,
              item['url'],
              pdfFirstPage: pdfFirstPage,
              isNeedRadius : false,
              isNeedOnPressed: false,
              iconSize: min(_.sliderItemSize.width, _.sliderItemSize.height) * 0.8,
              itemSize: _.sliderItemSize,
              updateVoidCallback: () {
                controller.update();
              },
            ),
          );
        }
        break;
    }
    return child;
  }

  Widget skipBtnWidget(BuildContext context, CloudServiceTaskController _, {
    required IconData iconData,
    required void Function()? onPressed,
  }){
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.surface
        ),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            )
        ),
      ),
      child: SizedBox(
        height: _.sliderItemSize.height,
        child: Icon(
          iconData,
          size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 2,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
  
}