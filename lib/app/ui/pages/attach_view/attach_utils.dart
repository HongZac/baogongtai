import 'dart:typed_data';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop/app/model/pdf_controller_with_key_model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/attach_view/full_screen_wrapper.dart';
import 'package:desktop/app/ui/pages/pdf_screen/pdf_screen_controller.dart';
import 'package:desktop/app/ui/pages/pdf_screen/pdf_screen_page.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';


class AttachUtils {

  ///附件缩略图的显示控件
  static Widget buildImage(BuildContext context, InitialPreviewConfigModel item, String url, {
    Uint8List? pdfFirstPage,
    bool isNeedRadius = true,
    bool isNeedOnPressed = true,
    double iconSize = 120,
    Size itemSize = const Size(40, 40),
    required VoidCallback updateVoidCallback,
  }){
    String fileType = item.type ?? '';
    if (url.isEmpty){
      return Icon(
        FluentIcons.document_error_16_filled,
        size: iconSize,
        color: AppColors.totalColor
      );
    }
    else if (item.isDeviceImageError){
      return Container(
          width: itemSize.width,
          height: itemSize.height,
          alignment: Alignment.center,
          child: Text(
            'ERROR',
            style: Theme.of(context).textTheme.bodyLarge,
          )
      );
    }
    Widget widget;
    switch(fileType.toLowerCase()) {
      case 'image':
        widget = CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: AddressService.getUrl(url),
            imageBuilder: (BuildContext context, ImageProvider<Object> image){
              return ClipRRect(
                  borderRadius: isNeedRadius ?
                  const BorderRadius.vertical(
                      top: Radius.circular(4)
                  ) :
                  BorderRadius.zero,
                  child: Image(image: image, fit: BoxFit.cover)
              );
            },
            errorWidget: (BuildContext context, String url, Object error,){
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
                item.isDeviceImageError = true;
                updateVoidCallback.call();
              });
              return Container(
                width: itemSize.width,
                height: itemSize.height,
                alignment: Alignment.center,
                child: Text(
                  'ERROR',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              );
            },
            placeholder: (context, url){
              return Container(
                width: itemSize.width,
                height: itemSize.height,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.progressActiveBkgColor),
                  backgroundColor: AppColors.progressBkgColor,
                ),
              );
            }
        );
        break;
      case 'doc':
      case 'docx':
      case 'office':
        widget = Icon(
          Icons.description,
          size: iconSize,
          color: AppColors.totalColor
        );
        break;
      case 'pdf':
        if (pdfFirstPage != null && pdfFirstPage.isNotEmpty) {
          widget = Container(
              color: Colors.white,
              child: ClipRRect(
                  borderRadius: isNeedRadius ?
                  const BorderRadius.vertical(
                      top: Radius.circular(4)
                  ) :
                  BorderRadius.zero,
                  child: Image.memory(
                    pdfFirstPage,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  )
              )
          );
        }
        else {
          widget = Icon(
              Icons.picture_as_pdf,
              size: iconSize,
              color: AppColors.totalColor
          );
        }
        break;
      case 'mp4':
      case 'video':
        widget = Icon(
          Icons.ondemand_video,
          size: iconSize,
          color: AppColors.totalColor
        );
        break;
      default:
        widget = Icon(
          Icons.book,
          size: iconSize,
          color: AppColors.totalColor
        );
        break;
    }
    return widget;
  }

  ///查看详情（查看大图）
  Future<void> getDetail(InitialPreviewConfigModel item, String url) async {
    if (url.isEmpty){ return; }
    switch (item.type){
      case 'image':
        Get.to(() => FullScreenWrapper(
          imageProvider: CachedNetworkImageProvider(AddressService.getUrl(url)),
        ));
        break;
      case 'mp4':
      case 'video':
        Uri uri = Uri.parse(AddressService.getUrl(url));
        var res = await launchUrl(uri);
        if (!res){
          ToastNotification(Get.overlayContext!).error("文件打开失败！");
        }
        break;
      case 'pdf':
        Get.put<PdfScreenController>(PdfScreenController(
            pageTitle: '${item.caption ?? ''}',
            pdfUrl: AddressService.getUrl(url),
            onPressed: (){ Get.back(); }
        ));
        await Get.to(() => const Scaffold(
          body: PdfScreenPage(),
        ));
        Get.delete<PdfScreenController>(force: true);
        break;
      case 'doc':
      case 'docx':
      case 'office':
        //todo  AttachOfficeDetailController 原控件对应的 dart 版本太高，不适配
        break;
    }
  }

  ///获取 pdf 类型的附件的缩略图
  Future<PdfControllerWithKeyModel> getPdfUint8List({
    required String key,
    required String url,
  }) async {
    PdfControllerWithKeyModel pdfControllerWithKeyModel = PdfControllerWithKeyModel(
      keyName: key,
      imageUint8List: Uint8List(0),
    );
    Uint8List uint8listForAllPage = await DioService().downLoadFile(AddressService.getUrl(url));
    if (uint8listForAllPage.isNotEmpty){
      var list = Printing.raster(uint8listForAllPage, pages: [0], dpi: 72);
      var firstPage = await list.first;
      Uint8List uint8list = await firstPage.toPng();
      pdfControllerWithKeyModel = PdfControllerWithKeyModel(
        keyName: key,
        imageUint8List: uint8list,
      );
    }
    return pdfControllerWithKeyModel;
  }

}