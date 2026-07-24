import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditFieldView extends BaseDialogPage<EditFieldController> {

  Widget contentWidget(BuildContext context, EditFieldController _) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          child: TextField(
            focusNode: _.fn,
            controller: _.tc,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: _.hintContent,
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
              ),
              contentPadding: kIsWeb || GetPlatform.isWindows
                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                  : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),

              suffixIcon: _.tc.text.isEmpty ? null : MineIconButton(
                icon: Icons.cancel,
                iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                tooltip: '清空',
                onPressed: () {
                  _.tc.clear();
                },
              ),
            ),
          ),
        ),
        if (_.infoContent.isNotEmpty)
          const SizedBox(height: 8,),
        if (_.infoContent.isNotEmpty)
          Text(
            _.infoContent,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.outline
            ),
          ),
      ],
    );
  }


}