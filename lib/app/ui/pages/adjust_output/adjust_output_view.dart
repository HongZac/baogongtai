import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/adjust_output/adjust_output_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/ui/widget/touch_spin.dart';
import 'package:flutter/material.dart';


///调整模穴
class AdjustOutputView extends BaseDialogPage<AdjustOutputController> {

  @override
  Widget contentWidget(BuildContext context, AdjustOutputController _) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemWidget(
          context, _,
          title: '可用模穴数',
          content: TouchSpin(
            width: 60,
            numValue: _.output,
            numMin: 0,
            textStyle: Theme.of(context).textTheme.titleLarge,
            iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
            addIcon: const Icon(Icons.add_circle_outline),
            subtractIcon: const Icon(Icons.remove_circle_outline),
            canInput: false,
            numOnChanged: (value){
              _.output = value;
            },
          ),
          isNeedMargin: true,
          width: 500,
        ),
        itemWidget(
          context, _,
          title: '调模原因',
          content: TextField(
            focusNode: _.descFN,
            controller: _.descTC,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyLarge,
            onChanged: (String? string) async{
              //_.debounce((){
              //  if (_.adjustOutputReasonSelectedItem?.text != _.descTC.text){
              //  }
              //  controller.update();
              //});
              controller.update();

            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
              suffixIcon: _.descTC.text.isNotEmpty ?
              MineIconButton(
                icon: Icons.cancel,
                iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                tooltip: '清空',
                onPressed: () {
                  _.descTC.clear();
                  controller.update();
                },
              ) :
              null,
            ),
          ),
          isNeedMargin: true,
          width: 500,
        ),
        Expanded(
          child: itemWidget(
            context, _,
            title: '调模原因选择',
            titleAlignment: Alignment.topRight,
            crossAxisAlignment: CrossAxisAlignment.start,
            titleMargin: const EdgeInsets.only(top: 18),
            content: Padding(
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                child: Wrap(
                  runSpacing: 12, spacing: 12,
                  children: List.generate(_.adjustOutputReasonList.length, (index){
                    TreeModel item = _.adjustOutputReasonList[index];
                    return FilterChip(
                      selected: item.id == _.adjustOutputReasonSelectedItem?.id,
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      onSelected: (bool bool) {
                        controller.adjustOutputReasonOnChanged(item);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                      label: Text(
                        item.name.isNotEmpty ? item.name : ' ',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget itemWidget(BuildContext context, AdjustOutputController _, {
    required String title,
    required Widget content,
    bool isNeedMargin = false,
    double? width,
    CrossAxisAlignment? crossAxisAlignment,
    Alignment? titleAlignment,
    EdgeInsetsGeometry? titleMargin,
  }){
    return TitleTextBoxWidget(
      title: title,
      customizeContent: content,
      titleWidth: 120, width: width,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      titleAlignment: titleAlignment,
      margin: isNeedMargin ? const EdgeInsets.only(bottom: 24) : null,
      titleMargin: titleMargin,
    );
  }

}