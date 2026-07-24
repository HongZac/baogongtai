
import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/utils/icon_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'message_controller.dart';


///系统消息 —— 主页面
class MessagePage extends BaseFormWithPageDataPage<MessageController, MsgTypeModel> {

  Widget dataItem(BuildContext context, MessageController _, MsgTypeModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: InkWell(
          onTap: () async{
            Get.rootDelegate.toNamed(
                AppRoutes.MESSAGE_DETAIL_MAIN_PAGE,
                parameters: {
                  'typeId': (item.typeId ?? 0).toString(),
                }
            );
          },
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.unChecked != null && item.unChecked! > 0)
                  Badge(
                    label: Text(
                      (item.unChecked ?? '').toString(),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: Theme.of(context).colorScheme.surface
                      ),
                    ),
                    child: Icon(
                      IconUtil.getIconData(item.typeIcon ?? ''),
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  )
                else
                  Icon(
                    IconUtil.getIconData(item.typeIcon ?? ''),
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                const SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                                '${item.typeName ?? ''}',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              )
                          ),
                          SizedBox(width: 4),
                          Text(
                            DateUtil.getDateStrByDateTime(item.sendDate,
                                format: DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE, dateSeparate: '-', timeSeparate: ':') ?? '',
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12,),
                      Text(
                        '${item.senderName ?? ''}：${item.subject}',
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                )
              ],
            )
          ),
        ),
      ),
    );
  }

}