
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/adapter_key_model.dart';
import 'package:desktop/app/model/text_edit_controller_key_model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/theme/app_theme.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/qm_inspection_detail/qm_inspection_form/qm_inspection_detail_form_controller.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///质量巡检 来料检验单详情页（编辑 + 查看）
class QMInspectionDetailFormPage extends BaseFormPage<QMInspectionDetailFormController> {

  @override
  Widget contentWidget(BuildContext context, QMInspectionDetailFormController _){
    return Container(
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4,),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 250,
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: 8),
                child: const BackOutlinedButton(),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    '检验详情',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 250,),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CardWidget(
              content: detailWidget(context, _),
            ),
          ),

          if (_.qmCheckVoucherItem.checkID.isNotEmpty || (_.qmCheckVoucherItem.inspectID != null && _.qmCheckVoucherItem.inspectID!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: numWidget(context, _),
            ),

          if (_.qmCheckVoucherItem.checkID.isNotEmpty || (_.qmCheckVoucherItem.inspectID != null && _.qmCheckVoucherItem.inspectID!.isNotEmpty))
            Expanded(
                child: dataReport(context, _)
            ),

          if (_.qmCheckVoucherItem.checkID.isNotEmpty || (_.qmCheckVoucherItem.inspectID != null && _.qmCheckVoucherItem.inspectID!.isNotEmpty))
            Material(
              elevation: 4,
              surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: verdictAndSaveWidget(context, _),
              ),
            ),
        ],
      ),
    );
  }

  Widget detailWidget(BuildContext context, QMInspectionDetailFormController _){
    return Container(
      height: 155,
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                '【${_.qmCheckVoucherItem.invName ?? ''}】'
                    ' ${_.qmCheckVoucherItem.engineerFigNo ?? ''}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600
                ), maxLines: 1,
              ),
              SelectableText(
                _.qmCheckVoucherItem.checkID.isEmpty ? '待检验' : '已检验',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: getSignColor(_.qmCheckVoucherItem.checkID.isEmpty ? 0 : 256),
                ), maxLines: 1,
              ),
              const Expanded(child: SizedBox.shrink()),

              FilledButton(
                onPressed: () async{
                  await controller.getInvAttach();
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.symmetric(vertical: 16, horizontal: 14)
                          : const EdgeInsets.symmetric(vertical: 12, horizontal: 14)
                  ),
                ),
                child: Text(
                  '产品附件',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ),
                ),
              ),
              const SizedBox(width: 8,),

              FilledButton(
                onPressed: () async{
                  await controller.getAttach();
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.symmetric(vertical: 16, horizontal: 14)
                          : const EdgeInsets.symmetric(vertical: 12, horizontal: 14)
                  ),
                ),
                child: Text(
                  '检验方案附件',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4,),

          Expanded(
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                interactive: false,
                thumbVisibility: WidgetStateProperty.all(false),
                trackVisibility: WidgetStateProperty.all(false),
                thumbColor: WidgetStateProperty.all(Colors.transparent),
                trackColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: SingleChildScrollView(
                controller: _.detailScrollController,
                child: Wrap(
                  runSpacing: 4, spacing: 6,
                  children: detailList(context, _),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  List<Widget> detailList(BuildContext context, QMInspectionDetailFormController _) {
    List<Widget> list = [];
    list.add(
        detailItemWidget(title: '来源单号', content: _.qmCheckVoucherItem.sourceCode ?? '')
    );
    list.add(
        detailItemWidget(title: '单据类型', content: _.qmCheckVoucherItem.vouchType ?? '')
    );
    list.add(
        detailItemWidget(title: '供应商', content: _.qmCheckVoucherItem.venName ?? '')
    );
    list.add(
        detailItemWidget(title: '产品规格', content: _.qmCheckVoucherItem.invStd ?? '')
    );
    list.add(
        detailItemWidget(title: '操作人员', content: _.qmCheckVoucherItem.inspectPerson ?? '')
    );
    list.add(
        detailItemWidget(title: '检验方式', isBold: true, content: getTestStyle(_.qmCheckVoucherItem.testStyle))
    );
    if (_.qmCheckVoucherItem.testStyle == 2 || _.qmCheckVoucherItem.testStyle == 3){
      list.add(
          detailItemWidget(title: '抽检规则', content: getDTMethod(_.qmCheckVoucherItem.dTMethod))
      );
      list.add(
          detailItemWidget(
              title: '抽检率',
              content: NumFormatUtil.qtyFormatConverter((_.qmCheckVoucherItem.dTRate ?? 0).toString(), decimal: 2)
          )
      );
    }

    list.add(
        detailItemWidget(title: 'AQL', content: _.qmCheckVoucherItem.aQL ?? '')
    );
    list.add(
        detailItemWidget(
            title: 'AC/RE',
            content: '${_.qmCheckVoucherItem.iAC?.toInt() ?? '0'}/${_.qmCheckVoucherItem.iRE?.toInt() ?? '0'}'
        )
    );
    list.add(
        detailItemWidget(
            title: '检验进度',
            isBold: true,
            content: '${_.finishedNum}/${_.totalNum}项'
        )
    );
    list.add(
        detailItemWidget(
            title: '报检数量',
            isBold: true,
            content: NumFormatUtil.qtyFormatConverter((_.qmCheckVoucherItem.quantity ?? 0).toString())
        )
    );
    /*list.add(
        detailItemWidget(title: '抽检方案', content: _.qmCheckVoucherItem.isRandorProject?.toString() ?? '')
    );
    list.add(
        detailItemWidget(title: '自定义抽检规则ID', content: _.qmCheckVoucherItem.ruleID ?? '')
    );*/
    return list;
  }
  Widget detailItemWidget({required String title, required String content,
    Color? titleColor, Color? contentColor, bool isBold = false, double width = 310}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: width,
      titleWidth: 100,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
        color: titleColor,
      ),
      contentStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
          color: contentColor,
          overflow: TextOverflow.ellipsis,
          fontWeight: isBold ? FontWeight.w600 : null
      ),
    );
  }

  Widget numWidget(BuildContext context, QMInspectionDetailFormController _){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _.qmCheckVoucherItem.checkID.isNotEmpty ?
          Wrap(
            runSpacing: 6, spacing: 24,
            children: [
              numItemWidget(
                context, _,
                title: '检验数量',
                content: NumFormatUtil.qtyFormatConverter((_.qmCheckVoucherItem.dTQuantity ?? 0).toString()),
              ),
              numItemWidget(
                context, _,
                title: '合格数量',
                content: NumFormatUtil.qtyFormatConverter((_.qmCheckVoucherItem.regQuantity ?? 0).toString()),
              ),
              numItemWidget(
                context, _,
                title: '让步接收数',
                content: NumFormatUtil.qtyFormatConverter((_.qmCheckVoucherItem.conQuantiy ?? 0).toString()),
              ),
              numItemWidget(
                context, _,
                title: '不合格数',
                content: NumFormatUtil.qtyFormatConverter((_.qmCheckVoucherItem.disQuantity ?? 0).toString()),
              ),
            ],
          ) :
          Wrap(
            runSpacing: 6, spacing: 8,
            children: [
              numItemReport(
                  context, _,
                  title: '    检验数量',
                  keyField: 'dTQuantity',
                  onChanged: (String str){
                    controller.calcQty('dTQuantity');
                  }
              ),
              numItemReport(
                  context, _,
                  title: '    合格数量',
                  keyField: 'regQuantity',
                  onChanged: (String str){
                    controller.calcQty('regQuantity');
                  }
              ),
              numItemReport(
                  context, _,
                  title: '让步接收数',
                  keyField: 'conQuantiy',
                  onChanged: (String str){
                    controller.calcQty('conQuantiy');
                  }
              ),
              numItemReport(
                  context, _,
                  title: '    不合格数',
                  keyField: 'disQuantity',
                  onChanged: (String str){
                    controller.calcQty('disQuantity');
                  }
              ),
            ],
          ),
        ),
        ///新增检验单表体项目内容
        if (_.canAddCheckGuide)
          PickerButtonWidget(
            adapter: _.checkGuideAdapter,
            pickerChoiceType: PickerChoiceType.chip,
            onTap: (List<PickerDataModel> selectList) async{
              await controller.checkGuideOnChanged(selectList);
            },
            buttonStyle: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              maximumSize: WidgetStateProperty.all(const Size(164, 55)),
              minimumSize: WidgetStateProperty.all(const Size(164, 55)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                ),
                const SizedBox(width: 4,),
                Text(
                  '新增检验项目'.tr,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ),
                ),
                const SizedBox(width: 4,),
              ],
            ),
          ),
        const SizedBox(width: 6,),
        MineIconButton(
          onPressed: (){
            controller.eCExpanded();
          },
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(6),
          tooltip: '检验方案全部展开/收起',
          icon: Icons.expand,
          iconSize: Theme.of(context).textTheme.titleMedium!.fontSize! * 1.5,
        ),
      ],
    );
  }
  Widget numItemReport(BuildContext context, QMInspectionDetailFormController _, {required String title, required String keyField, ValueChanged<String>? onChanged}){
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$title：',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w600
          ), maxLines: 1,
        ),
        SizedBox(
          width: 150, height: 50,
          child: NumPadTextField(
            numPadController: NumPadUtil().getNumPadController(keyField, _.numPadCTList)!,
            onChanged: (String str){
              onChanged?.call(str);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          ),
        ),
      ],
    );
  }
  Widget numItemWidget(BuildContext context, QMInspectionDetailFormController _, {required String title, required String content}){
    return Text(
      '$title：$content',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w600
      ), maxLines: 1,
    );
  }

  Widget dataReport(BuildContext context, QMInspectionDetailFormController _){
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        interactive: false,
        thumbVisibility: WidgetStateProperty.all(false),
        trackVisibility: WidgetStateProperty.all(false),
        thumbColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: ListView(
        cacheExtent: Get.height * 100,
        controller: _.dataReportScrollController,
        padding: const EdgeInsets.all(4),
        children: dataReportList(context, _),
      ),
    );
  }
  List<Widget> dataReportList(BuildContext context, QMInspectionDetailFormController _){
    bool isLight = Theme.of(context).brightness == Brightness.light;
    List<Widget> list = [];
    _.qmCheckVoucherItem.entryList.sort((left, right) => left.rowNo!.compareTo(right.rowNo!));
    int index = -1;
    for (var element in _.qmCheckVoucherItem.entryList) {
      index ++;
      Widget? trailing = verdictTypeEdit(context, _, element);

      list.add(
          Material(
            elevation: 1000,
            shadowColor: Colors.transparent,
            surfaceTintColor: index % 2 != 0
                ? Theme.of(context).colorScheme.surfaceTint
                : Theme.of(context).colorScheme.secondary,
            color: element.isUnqualifiedData
                ? AppColors.errorTextColor
                : null,
            child: ExpansionTile(
              controller: _.expansionTileControllerList[index],
              tilePadding: const EdgeInsets.only(left: 14, right: 12),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element.chkItemName ?? '',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: element.isUnqualifiedData
                              ? isLight
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4,),
                      Text(
                        element.chkGuideName ?? '',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: element.isUnqualifiedData
                              ? isLight
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4,),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.end,
                        verticalDirection: VerticalDirection.up,
                        runSpacing: 8, spacing: 48,
                        children: [
                          if (element.isUnqualifiedData)
                            SizedBox(
                              height: 45,
                              child: comDefectsAdapterEdit(context, _, element, index),
                            )
                          else
                            const SizedBox.shrink(),

                          if (element.isUnqualifiedData)
                            SizedBox(
                              height: 45,
                              child: quideDisQuantityEdit(context, _, element, index),
                            )
                          else
                            const SizedBox.shrink(),

                          SizedBox(
                            height: 45,
                            child: trailing,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: _.canAddCheckGuide ? 36 : 0,),
                ],
              ),
              trailing: !_.canAddCheckGuide ?
              const SizedBox.shrink() :
              MineIconButton(
                onPressed: () async{
                  await controller.removeCheckGuide(element);
                },
                tooltip: '移除',
                icon: FluentIcons.delete_16_regular,
                iconColor: element.isUnqualifiedData
                    ? isLight
                    ? Theme.of(context).colorScheme.onPrimary.withAlpha(128)
                    : Theme.of(context).colorScheme.onSurface.withAlpha(128)
                    : IconTheme.of(context).color!.withAlpha(128),
                iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.3,
              ),
              children: [
                detailItemWidget(
                  title: '检验标准', content: element.chkStandardProvision ?? '',
                  width: 2000,
                  titleColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                  contentColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                ),
                detailItemWidget(
                  title: '抽检规则',
                  content: '${getDTMethod(int.tryParse(element.iDTmethod.toString()))}'
                      '${element.iDTmethod == '3' ? '【${element.ruleName ?? ''}】' : ''}',
                  width: 2000,
                  titleColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                  contentColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                ),
                detailItemWidget(
                  title: '备注', content: element.bMemo ?? '', width: 2000,
                  titleColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                  contentColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                ),
                detailItemWidget(
                  title: '类型', width: 2000,
                  content: getChkGuidType(element.chkGuidType),
                  titleColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                  contentColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                ),
                if (element.chkGuidType == 1)
                  ...[
                    detailItemWidget(
                      title: '标准值', width: 2000,
                      content: NumFormatUtil.qtyFormatConverter((element.standardValue ?? 0).toString(), decimal: 2),
                      titleColor: element.isUnqualifiedData
                          ? isLight
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface
                          : null,
                      contentColor: element.isUnqualifiedData
                          ? isLight
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface
                          : null,
                    ),
                    detailItemWidget(
                      title: '上限值', width: 2000,
                      content: NumFormatUtil.qtyFormatConverter((element.upperLimit ?? 0).toString(), decimal: 2),
                      titleColor: element.isUnqualifiedData
                          ? isLight
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface
                          : null,
                      contentColor: element.isUnqualifiedData
                          ? isLight
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface
                          : null,
                    ),
                    detailItemWidget(
                      title: '下限值', width: 2000,
                      content: NumFormatUtil.qtyFormatConverter((element.lowerLimit ?? 0).toString(), decimal: 2),
                      titleColor: element.isUnqualifiedData
                          ? isLight
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface
                          : null,
                      contentColor: element.isUnqualifiedData
                          ? isLight
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface
                          : null,
                    ),
                  ],
                detailItemWidget(
                  title: 'AQL', width: 2000,
                  content: element.fAQL ?? '',
                  titleColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                  contentColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                ),
                detailItemWidget(
                  title: 'AC/RE', width: 2000,
                  content: '${element.aC?.toInt() ?? '0'}/${element.rE?.toInt() ?? '0'}',
                  titleColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                  contentColor: element.isUnqualifiedData
                      ? isLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface
                      : null,
                ),
              ],
            ),
          )
      );
    }
    list.add(const SizedBox(height: 12,));

    /*///附件
    list.add(
        Wrap(
          runSpacing: 12, spacing: 12,
          children: [
            ///已经上传了的附件
            if (_.dMDocumentModel.initialPreview != null && _.dMDocumentModel.initialPreview!.isNotEmpty)
              ...List.generate(_.dMDocumentModel.initialPreview!.length, (index) {
                String url = _.dMDocumentModel.initialPreview![index];
                return imageItemWidget(
                  context, _,
                  onTap: () async {
                    if (url.isEmpty){
                      return;
                    }
                    Get.to(() =>
                        FullScreenWrapper(
                          imageProvider: CachedNetworkImageProvider(AddressService.getUrl(url)),
                        )
                    );
                  },
                  child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: AddressService.getUrl(url),
                      imageBuilder: (BuildContext context, ImageProvider<Object> image){
                        return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image(image: image, fit: BoxFit.cover)
                        );
                      },
                      errorWidget: (BuildContext context, String url, Object error,){
                        return Container(
                            width: 40, height: 40,
                            alignment: Alignment.center,
                            child: Text(
                              'ERROR',
                              style: Theme.of(context).textTheme.bodyLarge,
                            )
                        );
                      },
                      placeholder: (context, url){
                        return Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(4)
                              )
                          ),
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(AppColors.progressActiveBkgColor),
                            backgroundColor: AppColors.progressBkgColor,
                          ),
                        );
                      }
                  ),
                );
              }),

            ///等待上传的附件
            ...List.generate(_.qmCheckVoucherItem.images_tou.length, (index) {
              Map<String, dynamic> map = _.qmCheckVoucherItem.images_tou[index];
              String key = map['key'] ?? '';
              String path = map['file'] ?? '';
              return imageItemWidget(
                context, _,
                onTap: () async {

                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        File(path),
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        color: Theme.of(context).colorScheme.onError.withAlpha(179),
                        child: MineIconButton(
                          onPressed: () async {
                            await controller.deleteCheckVoucherAttach(key);
                          },
                          icon: Icons.cancel,
                          iconSize: 24,
                          iconColor: Theme.of(context).colorScheme.error,
                          padding: const EdgeInsets.all(0),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            ///点击上传的按钮
            if (_.qmCheckVoucherItem.checkID.isEmpty)
              imageItemWidget(
                  context, _,
                  onTap: () async {
                    await controller.addCheckVoucherAttach();
                  },
                  bkgdColor: Theme.of(context).colorScheme.onInverseSurface,
                  child: Container(
                    child: Icon(Icons.add),
                  )
              ),
          ],
        )
    );*/

    return list;
  }
  Widget verdictTypeEdit(BuildContext context, QMInspectionDetailFormController _, QMCheckVouchersModel item) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    if (_.qmCheckVoucherItem.checkID.isNotEmpty){
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.verdict == 1 ? 'OK' : item.verdict == 2 ? 'NG' : '',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: item.isUnqualifiedData ? AppColors.errorBgColor : null,
            ),
          ),
        ],
      );
    }
    return Wrap(
      runSpacing: 4, spacing: 6,
      children: [
        FilterChip(
          selected: item.verdict == 1,
          selectedColor: AppColors.runColor,
          onSelected: (bool bool) async{
            await controller.verdictOnChanged(item, 1);
          },
          side: item.isUnqualifiedData
              ? isLight
              ? BorderSide(color: Theme.of(context).colorScheme.onPrimary)
              : BorderSide(color: Theme.of(context).colorScheme.onSurface)
              : null,
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          label: Text(
            'OK',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: item.verdict == 1 ? Theme.of(context).colorScheme.onPrimary : null
            ),
          ),
        ),
        FilterChip(
          selected: item.verdict == 2,
          selectedColor: AppColors.errorTextColor,
          onSelected: (bool bool) async{
            await controller.verdictOnChanged(item, 2);
          },
          side: item.isUnqualifiedData
              ? isLight
              ? BorderSide(color: Theme.of(context).colorScheme.onPrimary)
              : BorderSide(color: Theme.of(context).colorScheme.onSurface)
              : null,
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          label: Text(
            'NG',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: item.verdict == 2 ? Theme.of(context).colorScheme.onPrimary : null
            ),
          ),
        )
      ],
    );
  }

  ///单个项目检验不合格数 填报
  Widget quideDisQuantityEdit(BuildContext context, QMInspectionDetailFormController _, QMCheckVouchersModel item, int index){
    bool isLight = Theme.of(context).brightness == Brightness.light;
    TextEditingControllerKeyModel? textEditingControllerKeyModel = _.quideDisQuantityTCList.firstWhereOrNull(
            (element) => element.keyName == '${item.rowNo}');
    return TitleTextBoxWidget(
      title: '不合格数',
      content: NumFormatUtil.qtyFormatConverter((item.quideDisQuantity ?? '').toString()),
      customizeContent: _.qmCheckVoucherItem.checkID.isNotEmpty ? null : SizedBox(
        height: 45,
        child: Theme(
          data: item.isUnqualifiedData
              ? AppTheme.darkThemeData
              : AppTheme.lightThemeData,
          child: TextField(
            focusNode: textEditingControllerKeyModel?.fn,
            controller: textEditingControllerKeyModel?.tC,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: item.isUnqualifiedData
                  ? isLight
                  ? Theme.of(context).colorScheme.onPrimary
                  : null
                  : null,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (String string) async {
              await controller.verdictType23OnChanged(item, string);
            },
            cursorColor: item.isUnqualifiedData
                ? isLight
                ? Theme.of(context).colorScheme.primaryContainer
                : null
                : null,
            decoration: InputDecoration(
              hintText: textEditingControllerKeyModel?.tCType == TCType.double ? '请输入数字' : '请输入',
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
              ),
              enabledBorder: item.isUnqualifiedData
                  ? isLight
                  ? OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface))
                  : null
                  : null,
              focusedBorder: item.isUnqualifiedData
                  ? isLight
                  ? OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryContainer, width: 2))
                  : null
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              suffixIcon: (textEditingControllerKeyModel == null || textEditingControllerKeyModel.tC.text.isEmpty) ? null : MineIconButton(
                icon: Icons.cancel,
                iconColor: item.isUnqualifiedData
                    ? isLight
                    ? Theme.of(context).colorScheme.onPrimary
                    : null
                    : null,
                iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                tooltip: '清空',
                onPressed: () async {
                  textEditingControllerKeyModel.tC.text = '';
                  await controller.verdictType23OnChanged(item, textEditingControllerKeyModel.tC.text);
                },
              ),
            ),
          ),
        ),
      ),
      titleWidth: 85, width: 250,
      titleStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: item.isUnqualifiedData
            ? isLight
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface
            : null,
      ),
      contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: item.isUnqualifiedData
            ? isLight
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface
            : null,
      ),
      crossAxisAlignment: CrossAxisAlignment.center,
      onPress: (){
        controller.itemExpandedOnChanged(index);
      },
    );
  }

  ///缺陷原因选择
  Widget comDefectsAdapterEdit(BuildContext context, QMInspectionDetailFormController _, QMCheckVouchersModel item, int index){
    bool isLight = Theme.of(context).brightness == Brightness.light;
    AdapterKeyModel? adapterKeyModel = _.comDefectsAdapterList.firstWhereOrNull((element) => element.keyName == '${item.rowNo}');
    return TitleTextBoxWidget(
      title: '缺陷原因',
      content: item.defectsQtys ?? '',
      customizeContent: _.qmCheckVoucherItem.checkID.isNotEmpty ? null : Theme(
          data: item.isUnqualifiedData
              ? AppTheme.darkThemeData
              : AppTheme.lightThemeData,
          child: PickerInputWidget(
            height: 45,
            adapter: adapterKeyModel?.adapter,
            onTap: (List<PickerDataModel> selectList) async{
              if (selectList.isNotEmpty){
                await controller.comDefectsOnChanged(item, selectList);
              }
              else {
                await controller.comDefectsOnChanged(item, []);
              }
            },
          )
      ),
      titleWidth: 85, width: 300,
      titleStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: item.isUnqualifiedData
            ? isLight
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface
            : null,
      ),
      contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: item.isUnqualifiedData
            ? isLight
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface
            : null,
      ),
      crossAxisAlignment: CrossAxisAlignment.center,
      onPress: (){
        controller.itemExpandedOnChanged(index);
      },
    );
  }

  Widget imageItemWidget(BuildContext context, QMInspectionDetailFormController _, {AsyncCallback? onTap, required Widget child, Color? bkgdColor}){
    return Material(
      borderRadius: BorderRadius.circular(4),
      color: bkgdColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 80, width: 80,
          child: child,
        ),
      ),
    );
  }

  Widget verdictAndSaveWidget(BuildContext context, QMInspectionDetailFormController _){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (_.qmCheckVoucherItem.checkID.isEmpty)
          Expanded(
              child: Wrap(
                runSpacing: 8, spacing: 22,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [

                  ///提交人员选择
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '提交人：',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600
                        ), maxLines: 1,
                      ),
                      SizedBox(
                          width: 240, height: 50,
                          child: PickerInputWidget(
                            adapter: _.personAdapter,
                            onTap: (List<PickerDataModel> selectList) async{
                              if (selectList.isNotEmpty){
                                await controller.personOnChanged(selectList[0]);
                              }
                              else {
                                await controller.personOnChanged(PickerDataModel());
                              }
                            },
                          )
                      ),
                    ],
                  ),

                  ///结论
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '结论：',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600
                        ), maxLines: 1,
                      ),
                      Wrap(
                        runSpacing: 4, spacing: 6,
                        children: [
                          FilterChip(
                            selected: _.qmCheckVoucherItem.batchChkResult == 0,
                            selectedColor: AppColors.runColor,
                            onSelected: (bool bool) async{
                              await controller.overAllVerdictOnChanged(0);
                            },
                            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            label: Text(
                              '接收',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: _.qmCheckVoucherItem.batchChkResult == 0 ? Theme.of(context).colorScheme.onPrimary : null
                              ),
                            ),
                          ),
                          FilterChip(
                            selected: _.qmCheckVoucherItem.batchChkResult == 1,
                            selectedColor: AppColors.errorTextColor,
                            onSelected: (bool bool) async{
                              await controller.overAllVerdictOnChanged(1);
                            },
                            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            label: Text(
                              '不接收',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: _.qmCheckVoucherItem.batchChkResult == 1 ? Theme.of(context).colorScheme.onPrimary : null
                              ),
                            ),
                          ),
                          FilterChip(
                            selected: _.qmCheckVoucherItem.batchChkResult == 2,
                            selectedColor: AppColors.totalColor,
                            onSelected: (bool bool) async{
                              await controller.overAllVerdictOnChanged(2);
                            },
                            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            label: Text(
                              '让步',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: _.qmCheckVoucherItem.batchChkResult == 2 ? Theme.of(context).colorScheme.onPrimary : null
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  ///备注（扣款）
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '扣款：',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600
                        ), maxLines: 1,
                      ),
                      SizedBox(
                        width: 565, height: 50,
                        child: NumPadTextField(
                          numPadController: NumPadUtil().getNumPadController('desc', _.numPadCTList)!,
                          hintText: '选填',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        ),
                      ),
                    ],
                  ),

                ],
              )
          )
        else ///已检验
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '结论：',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600
                ), maxLines: 1,
              ),
              Text(
                _.qmCheckVoucherItem.batchChkResult == 0
                    ? '接收'
                    : _.qmCheckVoucherItem.batchChkResult == 1
                    ? '不接收'
                    : _.qmCheckVoucherItem.batchChkResult == 2
                    ? '让步'
                    : '',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _.qmCheckVoucherItem.batchChkResult == 0
                        ? AppColors.runColor
                        : _.qmCheckVoucherItem.batchChkResult == 1
                        ? AppColors.errorTextColor
                        : _.qmCheckVoucherItem.batchChkResult == 2
                        ? AppColors.totalColor
                        : AppColors.totalColor
                ), maxLines: 1,
              ),
              const SizedBox(width: 24,),


              Text(
                '扣款：${_.qmCheckVoucherItem.memo ?? ''}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600
                ), maxLines: 1,
              ),
            ],
          ),

        if (_.qmCheckVoucherItem.checkID.isEmpty)
          FilledButton(
            onPressed: () async{
              await controller.onSave();
            },
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size(200, 55)),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric()),
            ),
            child: Text(
              '提交',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              ),
            ),
          ),
      ],
    );
  }


  ///标准值类型 0-字符,1-数值
  String getChkGuidType(int? chkGuidType){
    switch (chkGuidType){
      case 0:
        return '字符';
      case 1:
        return '数值';
      default:
        return '';
    }
  }

  ///检验方式 0-全检,1-免检,2-破坏性抽检,3-非破坏性抽检
  String getTestStyle(int? testStyle) {
    switch (testStyle){
      case 0:
        return '全检';
      case 1:
        return '免检';
      case 2:
        return '破坏性抽检';
      case 3:
        return '非破坏性抽检';
      default:
        return '';
    }
  }

  ///抽检规则 0-比例,1-定量,2-国标,3-自定义抽检规则
  String getDTMethod(int? dTMethod) {
    switch (dTMethod){
      case 0:
        return '比例';
      case 1:
        return '定量';
      case 2:
        return '国标';
      case 3:
        return '自定义抽检规则';
      default:
        return '';
    }
  }

  Color getSignColor(int sign){
    ///已检验
    switch(sign){
      case 0: ///待
        return AppColors.standByColor;
      case 1: ///中
        return AppColors.totalColor;
      case 256: ///已
        return AppColors.runColor;
      default:
        return AppColors.standByColor;
    }
  }

}