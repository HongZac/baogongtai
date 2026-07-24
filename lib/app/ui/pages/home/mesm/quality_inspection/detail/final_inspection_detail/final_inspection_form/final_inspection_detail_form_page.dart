import 'dart:io';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop/app/model/adapter_key_model.dart';
import 'package:desktop/app/model/text_edit_controller_key_model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/theme/app_theme.dart';
import 'package:desktop/app/ui/pages/attach_view/full_screen_wrapper.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/final_inspection_detail/final_inspection_form/final_inspection_detail_form_controller.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/sign_color_util.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///质量巡检 终检检验单（生产完工检验单）详情页（编辑 + 查看）
class FinalInspectionDetailFormPage extends BaseFormPage<FinalInspectionDetailFormController>{

  @override
  Widget contentWidget(BuildContext context, FinalInspectionDetailFormController _) {
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

          if (_.checkVoucherItem.moCheckId.isNotEmpty || (_.checkVoucherItem.moInspectId != null && _.checkVoucherItem.moInspectId!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: numWidget(context, _),
            ),

          if (_.checkVoucherItem.moCheckId.isNotEmpty || (_.checkVoucherItem.moInspectId != null && _.checkVoucherItem.moInspectId!.isNotEmpty))
            Expanded(
              child: dataReport(context, _)
            ),

          if (_.checkVoucherItem.moCheckId.isNotEmpty || (_.checkVoucherItem.moInspectId != null && _.checkVoucherItem.moInspectId!.isNotEmpty))
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

  Widget detailWidget(BuildContext context, FinalInspectionDetailFormController _){
    return Container(
      height: 95,
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                '【${_.checkVoucherItem.invName ?? ''}】'
                    '${_.checkVoucherItem.deviceName ?? ''}'
                    ' ${_.checkVoucherItem.engineerFigNo ?? ''}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600
                ), maxLines: 1,
              ),
              SelectableText(
                ' ${SignColorUtil().getIPQCStatus(_.checkVoucherItem.sign ?? 0, _.checkVoucherItem.category ?? 0)}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: SignColorUtil().getIPQCSignColor(_.checkVoucherItem.sign ?? 0),
                ), maxLines: 1,
              ),
              const Expanded(child: SizedBox.shrink()),

              FilledButton(
                onPressed: () async{
                  await controller.getWagePiece();
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.symmetric(vertical: 16, horizontal: 14)
                          : const EdgeInsets.symmetric(vertical: 12, horizontal: 14)
                  ),
                ),
                child: Text(
                  '工序计划单',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ),
                ),
              ),
              const SizedBox(width: 8,),

              FilledButton(
                onPressed: () async{
                  await controller.getOpAttach();
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.symmetric(vertical: 16, horizontal: 14)
                          : const EdgeInsets.symmetric(vertical: 12, horizontal: 14)
                  ),
                ),
                child: Text(
                  '工序图纸',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ),
                ),
              ),
              const SizedBox(width: 8,),

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
  List<Widget> detailList(BuildContext context, FinalInspectionDetailFormController _) {
    List<Widget> list = [];
    list.add(
        detailItemWidget(title: '派工单号', content: _.checkVoucherItem.taskCode ?? '')
    );
    list.add(
        detailItemWidget(title: '产品规格', content: _.checkVoucherItem.invStd ?? '')
    );
    list.add(
        detailItemWidget(title: '当前工序', content: _.checkVoucherItem.opName ?? '')
    );
    list.add(
        detailItemWidget(title: '操作人员', content: _.checkVoucherItem.personName ?? '')
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
            content: NumFormatUtil.qtyFormatConverter((_.checkVoucherItem.inspectionQty ?? 0).toString())
        )
    );
    list.add(
        detailItemWidget(title: '工艺说明', content: _.checkVoucherItem.opDescription)
    );
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

  Widget numWidget(BuildContext context, FinalInspectionDetailFormController _){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ///抽检数据
              if (_.checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign)
                Wrap(
                  runSpacing: 6, spacing: 24,
                  children: [
                    numItemWidget(
                      context, _,
                      title: '抽检数量',
                      content: NumFormatUtil.qtyFormatConverter((_.checkVoucherItem.dTQuantity ?? 0).toString()),
                    ),
                    numItemWidget(
                      context, _,
                      title: '抽检合格数',
                      content: NumFormatUtil.qtyFormatConverter((_.checkVoucherItem.dTPassQty ?? 0).toString()),
                    ),
                    numItemWidget(
                      context, _,
                      title: '抽检不合格数',
                      content: NumFormatUtil.qtyFormatConverter((_.checkVoucherItem.dTDisableQty ?? 0).toString()),
                    ),
                  ],
                )
              else
                Wrap(
                  runSpacing: 6, spacing: 8,
                  children: [
                    numItemReport(
                        context, _,
                        title: '        抽检数量',
                        keyField: 'dTQuantity',
                        onChanged: (String str){
                          controller.calcQty('dTQuantity');
                        }
                    ),
                    numItemReport(
                        context, _,
                        title: '    抽检合格数',
                        keyField: 'dTPassQty',
                        onChanged: (String str){
                          controller.calcQty('dTPassQty');
                        }
                    ),
                    numItemReport(
                        context, _,
                        title: '抽检不合格数',
                        keyField: 'dTDisableQty',
                        onChanged: (String str){
                          controller.calcQty('dTDisableQty');
                        }
                    ),
                  ],
                ),

              const SizedBox(height: 6,),

              ///总数据
              if (_.checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign)
                Wrap(
                  runSpacing: 6, spacing: 24,
                  children: [
                    numItemWidget(
                      context, _,
                      title: '检验数量',
                      content: NumFormatUtil.qtyFormatConverter((_.checkVoucherItem.quantity ?? 0).toString()),
                    ),
                    numItemWidget(
                      context, _,
                      title: '合格数量',
                      content: NumFormatUtil.qtyFormatConverter((_.checkVoucherItem.passQty ?? 0).toString()),
                    ),
                    numItemWidget(
                      context, _,
                      title: '让步接收数',
                      content: NumFormatUtil.qtyFormatConverter((_.checkVoucherItem.concessionQty ?? 0).toString()),
                    ),
                    numItemWidget(
                      context, _,
                      title: '质废数量',
                      content: NumFormatUtil.qtyFormatConverter((_.checkVoucherItem.disabledQty ?? 0).toString()),
                    ),
                    numItemWidget(
                      context, _,
                      title: '料废数量',
                      content: NumFormatUtil.qtyFormatConverter((_.checkVoucherItem.materialQty ?? 0).toString()),
                    ),
                    numItemWidget(
                      context, _,
                      title: '遗失数量',
                      content: NumFormatUtil.qtyFormatConverter((_.checkVoucherItem.lostQty ?? 0).toString()),
                    ),
                  ],
                )
              else
                Wrap(
                  runSpacing: 6, spacing: 8,
                  children: [
                    numItemReport(
                      context, _,
                      title: '        检验数量',
                      keyField: 'quantity',
                      onChanged: (String str){
                        controller.calcQty('quantity');
                      }
                    ),
                    numItemReport(
                      context, _,
                      title: '        合格数量',
                      keyField: 'passQty',
                      onChanged: (String str){
                        controller.calcQty('passQty');
                      }
                    ),
                    numItemReport(
                      context, _,
                      title: '    让步接收数',
                      keyField: 'concessionQty',
                      onChanged: (String str){
                        controller.calcQty('concessionQty');
                      }
                    ),
                    numItemReport(
                      context, _,
                      title: '        质废数量',
                      keyField: 'disabledQty',
                      onChanged: (String str){
                        controller.calcQty('disabledQty');
                      }
                    ),
                    numItemReport(
                      context, _,
                      title: '        料废数量',
                      keyField: 'materialQty',
                      onChanged: (String str){
                        controller.calcQty('materialQty');
                      }
                    ),
                    numItemReport(
                        context, _,
                        title: '        遗失数量',
                        keyField: 'lostQty',
                        onChanged: (String str){
                          controller.calcQty('lostQty');
                        }
                    ),
                  ],
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
  Widget numItemReport(BuildContext context, FinalInspectionDetailFormController _, {required String title, required String keyField, ValueChanged<String>? onChanged}){
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
  Widget numItemWidget(BuildContext context, FinalInspectionDetailFormController _, {required String title, required String content}){
    return Text(
      '$title：$content',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w600
      ), maxLines: 1,
    );
  }

  //region dataReportList
  Widget dataReport(BuildContext context, FinalInspectionDetailFormController _){
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
  List<Widget> dataReportList(BuildContext context, FinalInspectionDetailFormController _){
    bool isLight = Theme.of(context).brightness == Brightness.light;
    List<Widget> list = [];
    _.checkVoucherItem.entryList.sort((left, right) => left.rowNo!.compareTo(right.rowNo!));
    int index = -1;
    for (var element in _.checkVoucherItem.entryList) {
      index ++;
      Widget trailing = const SizedBox.shrink();
      switch (element.verdictType){
        case 0: ///良次 标签选择
          trailing = verdictType0Edit(context, _, element);
          break;
        case 1: ///Picker选择
          trailing = verdictType1Edit(context, _, element);
          break;
        case 2: ///文字填报
        case 3: ///数字填报
          trailing = verdictType23Edit(context, _, element);
          break;
        default:
          if (_.checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){
            trailing = const SizedBox.shrink();
          }
          trailing = Text(
            '暂无数据填报方式',
            style: Theme.of(context).textTheme.bodyLarge,
          );
      }

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
                            child: defectQtyEdit(context, _, element, index),
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
                title: '检验方法', content: element.chkMethod ?? '',
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
                title: '检验数量',
                content: '${NumFormatUtil.qtyFormatConverter((element.dTQuantity ?? 0).toString())} 模/次',
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
                title: '备注', content: element.chkMethod ?? '', width: 2000,
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

              if (element.verdictType == 3)
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

              if (element.verdictType == 3)
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

              if (element.verdictType == 3)
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
          ),
        )
      );
    }
    list.add(const SizedBox(height: 12,));

    ///附件
    list.add(
      Wrap(
        runSpacing: 12, spacing: 12,
        children: [
          ///已经上传了的附件
          if (_.dMDocumentModel.initialPreview != null && _.dMDocumentModel.initialPreview!.isNotEmpty)
            ...List.generate(_.dMDocumentModel.initialPreview!.length, (index) {
              String url = _.dMDocumentModel.initialPreview![index];
              InitialPreviewConfigModel? item = _.dMDocumentModel.initialPreviewConfig?[index];
              if (item?.isDeviceImageError ?? false){
                return Container(
                    width: 40, height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      'ERROR',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                );
              }
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
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
                      item?.isDeviceImageError = true;
                      controller.update();
                    });
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
          ...List.generate(_.checkVoucherItem.images_tou.length, (index) {
            Map<String, dynamic> map = _.checkVoucherItem.images_tou[index];
            String key = map['key'] ?? '';
            String path = map['file'] ?? '';
            return imageItemWidget(
              context, _,
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
          if (_.checkVoucherItem.sign != MoCheckVoucherSign.ywg.sign)
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
    );

    return list;
  }
  ///良 次
  Widget verdictType0Edit(BuildContext context, FinalInspectionDetailFormController _, MoCheckVoucherEntryModel item){
    bool isLight = Theme.of(context).brightness == Brightness.light;
    if (_.checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.isUnqualifiedData ? '次' : '良',
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
            await controller.verdictType0OnChanged(item, 1);
          },
          side: item.isUnqualifiedData
              ? isLight
              ? BorderSide(color: Theme.of(context).colorScheme.onPrimary)
              : BorderSide(color: Theme.of(context).colorScheme.onSurface)
              : null,
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          label: Text(
            '良',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: item.verdict == 1 ? Theme.of(context).colorScheme.onPrimary : null
            ),
          ),
        ),
        FilterChip(
          selected: item.verdict == 2,
          selectedColor: AppColors.errorTextColor,
          onSelected: (bool bool) async{
            await controller.verdictType0OnChanged(item, 2);
          },
          side: item.isUnqualifiedData
              ? isLight
              ? BorderSide(color: Theme.of(context).colorScheme.onPrimary)
              : BorderSide(color: Theme.of(context).colorScheme.onSurface)
              : null,
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          label: Text(
            '次',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: item.verdict == 2 ? Theme.of(context).colorScheme.onPrimary : null
            ),
          ),
        )
      ],
    );
  }
  ///选项
  Widget verdictType1Edit(BuildContext context, FinalInspectionDetailFormController _, MoCheckVoucherEntryModel item) {
    AdapterKeyModel? adapterKeyModel = _.verdictOptionAdapterList.firstWhereOrNull((element) => element.keyName == '${item.rowNo}');
    if (_.checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.chkConclusion ?? '',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: item.isUnqualifiedData ? AppColors.errorBgColor : null,
            ),
          ),
        ],
      );
    }
    return PickerInputWidget(
      maxWidth: 130, height: 45,
      adapter: adapterKeyModel?.adapter,
      onTap: (List<PickerDataModel> selectList) async{
        if (selectList.isNotEmpty){
          await controller.verdictType1OnChanged(item, selectList[0]);
        }
        else {
          await controller.verdictType1OnChanged(item, PickerDataModel());
        }
      },
    );
  }
  ///数字、文字填报
  Widget verdictType23Edit(BuildContext context, FinalInspectionDetailFormController _, MoCheckVoucherEntryModel item){
    bool isLight = Theme.of(context).brightness == Brightness.light;
    if (_.checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.chkConclusion ?? '',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: item.isUnqualifiedData ? AppColors.errorBgColor : null,
            ),
          ),
        ],
      );
    }
    TextEditingControllerKeyModel? textEditingControllerKeyModel = _.tCList.firstWhereOrNull(
            (element) => element.keyName == '${item.rowNo}');
    return SizedBox(
        width: 130, height: 45,
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
          keyboardType: textEditingControllerKeyModel?.tCType == TCType.double ? const TextInputType.numberWithOptions(decimal: true) : null,
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
        )
    );
  }

  ///单个项目检验不合格数 填报
  Widget defectQtyEdit(BuildContext context, FinalInspectionDetailFormController _, MoCheckVoucherEntryModel item, int index){
    bool isLight = Theme.of(context).brightness == Brightness.light;
    TextEditingControllerKeyModel? textEditingControllerKeyModel = _.defectQtyTCList.firstWhereOrNull(
            (element) => element.keyName == '${item.rowNo}');
    return TitleTextBoxWidget(
      title: '不合格数',
      content: NumFormatUtil.qtyFormatConverter((item.defectQty ?? '').toString()),
      customizeContent: _.checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign ? null : SizedBox(
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
            keyboardType: textEditingControllerKeyModel?.tCType == TCType.double ? const TextInputType.numberWithOptions(decimal: true) : null,
            onChanged: (String string){
              item.defectQty = double.tryParse(string);
              controller.update();
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
                onPressed: () {
                  textEditingControllerKeyModel.tC.text = '';
                  item.defectQty = null;
                  _.getNum();
                  controller.update();
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
  Widget comDefectsAdapterEdit(BuildContext context, FinalInspectionDetailFormController _, MoCheckVoucherEntryModel item, int index){
    bool isLight = Theme.of(context).brightness == Brightness.light;
    AdapterKeyModel? adapterKeyModel = _.comDefectsAdapterList.firstWhereOrNull((element) => element.keyName == '${item.rowNo}');
    return TitleTextBoxWidget(
      title: '缺陷原因',
      content: item.comDefects ?? '',
      customizeContent: _.checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign ? null : Theme(
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

  Widget imageItemWidget(BuildContext context, FinalInspectionDetailFormController _, {AsyncCallback? onTap, required Widget child, Color? bkgdColor}){
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
  //endregion

  Widget verdictAndSaveWidget(BuildContext context, FinalInspectionDetailFormController _){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (_.checkVoucherItem.sign != MoCheckVoucherSign.ywg.sign)
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
                            selected: _.checkVoucherItem.verdict == 1,
                            selectedColor: AppColors.runColor,
                            onSelected: (bool bool) async{
                              await controller.overAllVerdictOnChanged(1);
                            },
                            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            label: Text(
                              '合格',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: _.checkVoucherItem.verdict == 1 ? Theme.of(context).colorScheme.onPrimary : null
                              ),
                            ),
                          ),
                          FilterChip(
                            selected: _.checkVoucherItem.verdict == 2,
                            selectedColor: AppColors.errorTextColor,
                            onSelected: (bool bool) async{
                              await controller.overAllVerdictOnChanged(2);
                            },
                            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            label: Text(
                              '不合格',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: _.checkVoucherItem.verdict == 2 ? Theme.of(context).colorScheme.onPrimary : null
                              ),
                            ),
                          ),
                          FilterChip(
                            selected: _.checkVoucherItem.verdict == 4,
                            selectedColor: AppColors.totalColor,
                            onSelected: (bool bool) async{
                              await controller.overAllVerdictOnChanged(4);
                            },
                            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            label: Text(
                              '让步',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: _.checkVoucherItem.verdict == 4 ? Theme.of(context).colorScheme.onPrimary : null
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
        else if (_.checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign) ///已检验
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
                _.checkVoucherItem.verdict == 1
                    ? '合格'
                    : _.checkVoucherItem.verdict == 2
                    ? '不合格'
                    : _.checkVoucherItem.verdict == 4
                    ? '让步'
                    : '',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _.checkVoucherItem.verdict == 1
                        ? AppColors.runColor
                        : _.checkVoucherItem.verdict == 2
                        ? AppColors.errorTextColor
                        : _.checkVoucherItem.verdict == 2
                        ? AppColors.totalColor
                        : AppColors.totalColor
                ), maxLines: 1,
              ),
              const SizedBox(width: 24,),


              Text(
                '扣款：${_.checkVoucherItem.description ?? ''}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600
                ), maxLines: 1,
              ),
            ],
          ),

        if (_.checkVoucherItem.sign != MoCheckVoucherSign.ywg.sign)
          FilledButton(
            onPressed: () async{
              await controller.draftSave();
            },
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size(200, 55)),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric()),
              backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
            ),
            child: Text(
              '保存',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              ),
            ),
          ),

        if (_.checkVoucherItem.sign != MoCheckVoucherSign.ywg.sign)
          const SizedBox(width: 8,),

        if (_.checkVoucherItem.sign != MoCheckVoucherSign.ywg.sign)
          FilledButton(
            onPressed: () async{
              await controller.save();
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

}