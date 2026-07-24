import 'package:auto_size_text/auto_size_text.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:easy_refresh/easy_refresh.dart' as easy;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const double kPickerHeaderLandscapeWidth = 250.0;
const double kDialogActionBarHeight = 68.0;


class PickerDialog<T extends PickerDataModel> extends StatefulWidget {

  ///数据接口，提供数据源
  final IPickerAdapter<T> adapter;
  final PickerChoiceType pickerChoiceType;
  ///查看工序的技术指导书 函数回调
  final ProcessItemAttachBuilder? processItemAttach;
  ///工序选单页面的岗位筛选 函数回调
  final AsyncValueSetter<List<PickerDataModel>>? processPostOnChanged;


  const PickerDialog({
    super.key,
    required this.adapter,
    required this.pickerChoiceType,
    this.processItemAttach,
    this.processPostOnChanged,
  });


  @override
  PickerDialogState<T> createState() => PickerDialogState<T>();
}

class PickerDialogState<T extends PickerDataModel>
    extends State<PickerDialog<T>>
    with InterfaceUtil {

  IPickerAdapter<T> get adapter => widget.adapter;
  List<T> get selectedList => adapter.dataList.where((element) => element.isSelected).toList();
  ///选单窗体刚打开时的选中项列表
  final initSelectedList = [];

  ///搜索输入框用
  final TextEditingController textEditingController = TextEditingController();
  ///搜索输入框用
  final FocusNode focusNode = FocusNode();
  ///搜索方式，该值是[searchTypeList]中对应项的索引
  late int searchTypeIndex = 0;

  ///搜索时启用时间防抖，超过一定时间不输入才正式搜索数据
  final Debounce debounce = Debounce(const Duration(milliseconds: 1500));

  ///搜索输入框用（日期）
  final TextEditingController dateTextEditingController = TextEditingController();

  ///单据状态标签选中对象的 sign（可多选，取二进制的和）
  int selectedSignBinary = 0;
  List<MoSignModel> get signList => adapter is TaskAdapter
      ? List.unmodifiable(AppConfig.taskSignList)
      : [];

  final easy.EasyRefreshController refreshController = easy.EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);
  final ScrollController scrollController = ScrollController();

  //region 单页行数
  late final List<Widget> pageSizeMenuList = BaseAppConfig.pageSizeList.map((e) {
    return MenuItemButton(
      onPressed: () async{ await pageSizeOnChanged(e); },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.only(top: 32, bottom: 32, left: 16, right: 48)
        ),
      ),
      child: MenuAcceleratorLabel(e),
    );
  }).toList();
  //endregion

  double dialogWidth = Get.width * 0.95 > 1024 ? 1024 : Get.width * 0.95;
  double dialogHeight = Get.height * 0.95 > 768 ? 768 : Get.height * 0.95;

  ///是否正在加载数据中
  bool isLoading = false;

  //region 工艺工序
  ///工序说明查看
  String opDescription = '';
  //endregion

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> dataListInfoFormListMap = {};


  @override
  void initState() {
    super.initState();
    searchTypeIndex = ShareStorageUtil.instance?.read('${BaseSharedPreferencesKeys.PICKER_SEARCH_TYPE_INDEX_KEY}-${adapter.tag}') ?? AppConfig.searchTypeIndex;
    selectedSignBinary = ShareStorageUtil.instance?.read('${BaseSharedPreferencesKeys.PICKER_SIGN_SELECTED_KEY}-${adapter.tag}') ?? AppConfig.selectedSignBinaryNull;
    adapter.dataList.forEach((element) {
      if (element.isSelected){
        initSelectedList.add(element);
        if (adapter.visibleItems.firstWhereOrNull((element1) => element1.id == element.id) == null){
          adapter.visibleItems.add(element);
        }
      }
    });
    textEditingController.text = adapter.lastSearchValue;
    textEditingController.addListener(_textEditingControllerListener);
    dateTextEditingController.text = adapter.lastDateSearchValue;

    //region 数据字段列表参数获取
    switch (widget.pickerChoiceType){
      case PickerChoiceType.pmesTask:
        //region 注塑派工单选单样式
        List<dynamic> dataListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_TASK_LIST_INFO_FORM_LIST_KEY) ?? [];
        dataListInfoFormListMap.clear();
        dataListInfoFormListMap.addAll(
            getInfoFormListMap(
                getInfoFormListByStorage(
                    dataListInfoFormMapList,
                    AppConfig.pMesTaskListInfoFormList
                )
            )
        );
        //endregion
        break;
      case PickerChoiceType.mesTask:
        //region 生产派工单选单样式
        List<dynamic> dataListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_INFO_FORM_LIST_KEY) ?? [];
        dataListInfoFormListMap.clear();
        dataListInfoFormListMap.addAll(
            getInfoFormListMap(
                getInfoFormListByStorage(
                    dataListInfoFormMapList,
                    AppConfig.mesTaskListInfoFormList
                )
            )
        );
        //endregion
        break;
      default:
        break;
    }
    //endregion
  }


  ///“单页显示记录数” 选择变化
  Future<void> pageSizeOnChanged(String pageSize) async{
    adapter.pageSizeOnChanged(int.tryParse(pageSize)!);
    //region 刷新列表数据
    adapter.pageConfig.rows = adapter.pageSize;
    await handleRefresh();
    //endregion
    setState(() { });
  }


  //region 搜索

  void searchTypeOnChanged(SumModel item, int index) {
    if (index == searchTypeIndex){ return; }
    searchTypeIndex = index;
    ShareStorageUtil.instance?.write('${BaseSharedPreferencesKeys.PICKER_SEARCH_TYPE_INDEX_KEY}-${adapter.tag}', searchTypeIndex);
    searchQueryDataOnChanged();
    setState(() { });
  }

  void searchQueryDataOnChanged(){
    adapter.pageConfig.queryData!.remove(adapter.searchKeyWordForPageConfig);
    adapter.pageConfig.queryData!.removeWhere((key, value) => adapter.extraSearchQueryDataList.contains(key));
    if (textEditingController.text.isNotEmpty){
      onSearch();
    }
  }


  Future<void> _textEditingControllerListener() async {
    await debounce(() async{
      onSearch();
    });
  }

  void onSearch() {
    String? keyWord;
    if (searchTypeIndex != 0) {
      keyWord = adapter.extraSearchQueryDataList[searchTypeIndex - 1];
    }
    adapter.onSearch(textEditingController.text, keyWord: keyWord,).then((value) {
      if (mounted){
        setState(() { });
      }
    });
  }

  //endregion


  //region EasyRefreshController 刷新 + 加载更多

  Future<void> handleRefresh() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    await adapter.handleRefresh();
    refreshController.finishRefresh(
      easy.IndicatorResult.success,
    );
    refreshController.finishLoad(
      adapter.pageConfig.page < adapter.totalPage
          ? easy.IndicatorResult.success
          : easy.IndicatorResult.noMore,
    );
    isLoading = false;
    setState(() { });
  }

  Future<void> handleLoadMore() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    if (!adapter.isUsedPageConfig){
      refreshController.finishLoad(easy.IndicatorResult.noMore);
      isLoading = false;
      return;
    }
    await adapter.handleLoadMore();
    isLoading = false;
    refreshController.finishLoad(
        adapter.pageConfig.page < adapter.totalPage
            ? easy.IndicatorResult.success
            : easy.IndicatorResult.noMore
    );
    setState(() { });
  }

  //endregion


  ///选择项目后处理过程
  void onSelected(T item) {
    adapter.onSelected(item);
    setState(() { });
  }


  ///根据条件搜索，value 搜索值，field指定搜索字段（日期）
  Future<void> dateOnChanged(String value, {String? field}) async {
    if (adapter.isUsedPageConfig){
      adapter.lastDateSearchValue = value;
      List<String> dateSearchKeyWordList = adapter.dateSearchKeyWordForPageConfig.split(',');
      if (dateSearchKeyWordList.length == 1){
        adapter.pageConfig.queryData![adapter.dateSearchKeyWordForPageConfig] = value;
      }
      else if (dateSearchKeyWordList.length == 2){
        List<String> valueList = value.split('到');
        if (valueList.length == 2){
          adapter.pageConfig.queryData![dateSearchKeyWordList[0]] = valueList[0];
          adapter.pageConfig.queryData![dateSearchKeyWordList[1]] = valueList[1];
        }
        else if (valueList.length == 1 && valueList[0].isEmpty){
          adapter.pageConfig.queryData!.remove(dateSearchKeyWordList[0]);
          adapter.pageConfig.queryData!.remove(dateSearchKeyWordList[1]);
        }
      }
      await handleRefresh();
    }
    setState(() { });
  }

  ///状态选择变化
  Future<void> signOnChanged(int sign) async{
    if (selectedSignBinary & sign == sign){
      selectedSignBinary = selectedSignBinary - sign;
    }
    else {
      selectedSignBinary = selectedSignBinary + sign;
    }
    ShareStorageUtil.instance?.write('${BaseSharedPreferencesKeys.PICKER_SIGN_SELECTED_KEY}-${adapter.tag}', selectedSignBinary);


    if (adapter.isUsedPageConfig){
      Map<String, dynamic> queryData = AdapterHelper.getQueryData(adapter);
      adapter.pageConfig.queryData!.addAll(queryData);

      await handleRefresh();
    }
    setState(() { });
  }

  ///“是否显示选中记录”按钮选择变化
  void onlySelectedVisibleOnChanged(){
    adapter.onlySelectedVisible = !adapter.onlySelectedVisible;
    setState(() { });
  }


  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        color: theme.scaffoldBackgroundColor,
        child: Row(
          children: [
            leftHeader(context),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: dataRefreshWidget(context),
                  ),
                  Divider(
                    indent: 0, endIndent: 0,
                    color: Theme.of(context).disabledColor,
                  ),
                  actionBar(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget leftHeader(BuildContext context){
    ThemeData theme = Theme.of(context);
    return Container(
      width: kPickerHeaderLandscapeWidth,
      color: theme.navigationRailTheme.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///标题
          Center(
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: AutoSizeText(
                adapter.title ?? '',
                style: theme.textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          Divider(
            color: Colors.white,
            thickness: 1,
            endIndent: 8, indent: 8,
          ),

          const SizedBox(height: 8,),

          ///总记录数
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AutoSizeText(
              '总记录数：${adapter.totalRecords}',
              style: theme.textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4,),

          ///选中记录
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AutoSizeText(
              '选中记录：${selectedList.length}',
              style: theme.textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis
            ),
          ),
          const SizedBox(height: 4,),

          ///只显示选单记录
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AutoSizeText(
                  '只显示选中记录',
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis
                ),
                const SizedBox(width: 8,),
                Switch(
                  value: adapter.onlySelectedVisible,
                  onChanged: (bool boolValue){
                    onlySelectedVisibleOnChanged();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12,),

          ///单页显示记录数
          if (adapter.isUsedPageConfig)
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '单页显示记录数',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(width: 8,),
                  MenuBar(
                    style: MenuStyle(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      shadowColor: WidgetStateProperty.all(Colors.transparent),
                      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    children: [
                      SubmenuButton(
                        style: ButtonStyle(
                          alignment: Alignment.center,
                          visualDensity: VisualDensity(horizontal: -4),
                          padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
                        ),
                        menuChildren: pageSizeMenuList,
                        child: Container(
                          width: 80, height: 40,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withAlpha(153),
                              width: 1
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  adapter.pageSize.toString(),
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: Colors.white,
                                  ),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 3,),
                              Icon(
                                Icons.arrow_drop_down,
                                size: theme.textTheme.bodyLarge!.fontSize! * 1.43,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          if (adapter.isUsedPageConfig)
            const SizedBox(height: 12,),

          ///岗位过滤器
          if (adapter is ProcessAdapter
              && (adapter as ProcessAdapter).isNeedGetPostFilter)
            PickerButtonWidget(
              adapter: (adapter as ProcessAdapter).postAdapter,
              pickerChoiceType: PickerChoiceType.checkboxListTile,
              pickerButtonType: PickerButtonType.text,
              onTap: (List<PickerDataModel> selectList) async {
                await widget.processPostOnChanged?.call(selectList);
                initSelectedList.clear();
                adapter.dataList.forEach((element) {
                  if (element.isSelected){
                    initSelectedList.add(element);
                  }
                });
                setState(() {  });
              },
              buttonStyle: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                    horizontal: 8
                )),
                minimumSize: WidgetStateProperty.all(const Size(110, 48))
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_note_outlined,
                    size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.3,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      '岗位筛选：${(adapter as ProcessAdapter).postAdapter?.dataList.where(
                              (element) => element.isSelected).map(
                              (e) => e.code).join(',')}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          if (adapter is ProcessAdapter
              && (adapter as ProcessAdapter).isNeedGetPostFilter)
            const SizedBox(height: 4,),


          ///工艺工序选单-工艺说明
          if (adapter is ProcessAdapter)
            SizedBox(
              height: 100,
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  interactive: false,
                  thumbVisibility: WidgetStateProperty.all(false),
                  trackVisibility: WidgetStateProperty.all(false),
                  thumbColor: WidgetStateProperty.all(Colors.transparent),
                  trackColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    '工序说明：${opDescription}',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                )
              ),
            ),

          const Expanded(child: SizedBox.shrink()),

          ///单据状态筛选
          if (adapter.isNeedSignFilter)
            Container(
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(signList.length, (index){
                  MoSignModel item = signList[index];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < signList.length - 1 ? 4 : 0
                      ),
                      child: FilterChip(
                        selected: selectedSignBinary & item.sign == item.sign,
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        onSelected: (bool bool) async{
                          await signOnChanged(item.sign);
                        },
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 12,
                        ),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            item.title.isNotEmpty ? item.title : ' ',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (adapter.isNeedSignFilter)
            const SizedBox(height: 4,),

          ///日期筛选
          if (adapter.isNeedDateSearch)
            Container(
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: dateTextEditingController,
                readOnly: true,
                minLines: 1, maxLines: 1,
                keyboardType: TextInputType.none,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: '请选择日期',
                  hintStyle: theme.textTheme.bodyLarge!.copyWith(
                    color: Colors.white.withAlpha(179),
                  ),
                  prefixIcon: dateIconButton(context),
                  suffixIcon: dateTextEditingController.text.isEmpty ? null : MineIconButton(
                    icon: Icons.cancel,
                    iconSize: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43,
                    tooltip: '清空',
                    onPressed: () async {
                      dateTextEditingController.clear();
                      await dateOnChanged(dateTextEditingController.text);
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:Colors.white.withAlpha(179),
                      width: 1
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                )
              ),
            ),
          if (adapter.isNeedDateSearch)
            const SizedBox(height: 4,),

          ///关键字搜索
          Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              focusNode: focusNode,
              controller: textEditingController,
              minLines: 1, maxLines: 1,
              keyboardType: TextInputType.none,
              style: theme.textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: adapter.extraSearchKeyWordList.isEmpty
                    ? '搜索...'
                    : (searchTypeIndex == 0
                    ? '搜索...'
                    : adapter.extraSearchKeyWordList[searchTypeIndex - 1].title),
                hintStyle: theme.textTheme.bodyLarge!.copyWith(
                  color: Colors.white.withAlpha(179),
                ),
                prefixIcon: adapter.extraSearchKeyWordList.isEmpty ?
                Icon(
                  Icons.search,
                  size: theme.textTheme.bodyLarge!.fontSize! * 1.43,
                  color: Colors.white,
                ) :
                MenuBar(
                  style: MenuStyle(
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(Colors.transparent),
                    shadowColor: WidgetStateProperty.all(Colors.transparent),
                    surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  children: [
                    SubmenuButton(
                      style: ButtonStyle(
                        alignment: Alignment.center,
                        visualDensity: VisualDensity(horizontal: -4),
                        padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
                      ),
                      menuChildren: List.generate(adapter.extraSearchKeyWordList.length + 1, (index) {
                        SumModel item;
                        if (index == 0){
                          item = SumModel(
                            title: '关键字搜索',
                            keyName: adapter.searchKeyWordForPageConfig,
                            content: adapter.searchKeyWordForPageConfig,
                          );
                        }
                        else {
                          item = adapter.extraSearchKeyWordList[index - 1];
                        }
                        return MenuItemButton(
                          onPressed: () {
                            searchTypeOnChanged(item, index);
                          },
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.only(top: 32, bottom: 32, left: 16, right: 48)
                            ),
                          ),
                          child: Text(
                            item.title!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          trailingIcon: searchTypeIndex == index ?
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.check,
                              size: theme.textTheme.bodyLarge!.fontSize! * 1.43,
                            ),
                          ) :
                          null,
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.search,
                          size: theme.textTheme.bodyLarge!.fontSize! * 1.43,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:Colors.white.withAlpha(179),
                    width: 1
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              )
            ),
          ),
          const SizedBox(height: 4,),

          ///数字软键盘
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: AspectRatio(
              aspectRatio: 3/4,
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  interactive: false,
                  thumbVisibility: WidgetStateProperty.all(false),
                  trackVisibility: WidgetStateProperty.all(false),
                  thumbColor: WidgetStateProperty.all(Colors.transparent),
                  trackColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1,
                  children: [
                    numButton(context, '1'),
                    numButton(context, '2'),
                    numButton(context, '3'),
                    numButton(context, '4'),
                    numButton(context, '5'),
                    numButton(context, '6'),
                    numButton(context, '7'),
                    numButton(context, '8'),
                    numButton(context, '9'),
                    iconButton(context, FluentIcons.delete_24_filled),
                    numButton(context, '0'),
                    iconButton(context, FluentIcons.backspace_24_filled, isBackSpace: true),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12,),

        ],
      ),
    );
  }

  Widget dataRefreshWidget(BuildContext context){
    ThemeData theme = Theme.of(context);
    List<T> dataList = [];
    if (adapter.onlySelectedVisible){
      dataList.addAll(selectedList);
    }
    else {
      dataList.addAll(adapter.visibleItems);
    }
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(8),
      child: easy.EasyRefresh(
        controller: refreshController,
        onRefresh: handleRefresh,
        onLoad: handleLoadMore,
        child: dataList.isNotEmpty ?
        ScrollbarTheme(
          data: ScrollbarThemeData(
            interactive: false,
            thumbVisibility: WidgetStateProperty.all(false),
            trackVisibility: WidgetStateProperty.all(false),
            thumbColor: WidgetStateProperty.all(Colors.transparent),
            trackColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: dataView(context, dataList),
        ) :
        ListView(
          children: [
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(8),
              child: Text(
                adapter.errorMessage.isNotEmpty ? adapter.errorMessage : '未查询到内容',
                style: theme.textTheme.bodyLarge,
              ),
            )
          ],
        )
      ),
    );
  }

  Widget actionBar(BuildContext context){
    return Container(
      height: kDialogActionBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ///当在多选条件下，显示【全选】【重置】【反选】三个附加按钮
          if (adapter.multipleSelection)
            ...[
              const SizedBox(width: 8),
              outlineButton(
                context,
                title: '全选',
                onPressed: () async {
                  adapter.dataList.forEach((element) {
                    element.isSelected = true;
                  });
                  setState(() { });
                },
              ),
              const SizedBox(width: 10),
              outlineButton(
                context,
                title: '重置',
                onPressed: () async {
                  adapter.dataList.forEach((element) {
                    element.isSelected = false;
                  });
                  setState(() { });
                },
              ),
              const SizedBox(width: 10,),
              outlineButton(
                context,
                title: '反选',
                onPressed: () async {
                  adapter.dataList.forEach((element) {
                    element.isSelected = !element.isSelected;
                  });
                  setState(() { });
                },
              ),
            ],
          const Expanded(child: SizedBox.shrink()),
          outlineButton(
            context,
            title: '取消',
            onPressed: () async {
              adapter.dataList.forEach((element) {
                element.isSelected = false;
                if (initSelectedList.firstWhereOrNull((element1) => element1.id == element.id) != null){
                  element.isSelected = true;
                }
              });
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 10,),
          filledButton(
            context,
            title: '确定',
            onPressed: () async {
              Navigator.of(context).pop(selectedList);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget? dateIconButton(BuildContext context){
    ThemeData theme = Theme.of(context);
    switch (adapter.dateSearchType){
      case 1: /// 日期 + 时间
        return IconButton(
          icon: Icon(
            Icons.calendar_month_outlined,
            color: Colors.white,
            size: theme.textTheme.bodyLarge!.fontSize! * 1.43,
          ),
          tooltip: '日期时间选择',
          onPressed: () async{
            DateTime dateTime = DateTime.tryParse(dateTextEditingController.text) ?? DateTime.now();
            DateTime? date;
            TimeOfDay? time;
            //region 日期
            date = await showDatePicker(
              locale: Get.locale!,
              context: Get.context!,
              initialDate: dateTime,
              firstDate: DateTime(1900),
              lastDate: DateTime(2200),
              builder: (context, child){
                return TextButtonTheme(
                  data: TextButtonThemeData(
                    style: ButtonStyle(
                      textStyle: WidgetStateProperty.all(
                        theme.textTheme.titleLarge
                      )
                    )
                  ),
                  child: Localizations(
                    locale: Get.locale!,
                    delegates: const <LocalizationsDelegate>[
                      DefaultMaterialLocalizations.delegate,
                      DefaultCupertinoLocalizations.delegate,
                      DefaultWidgetsLocalizations.delegate,
                      //GlobalMaterialLocalizations.delegate,
                      //GlobalWidgetsLocalizations.delegate,
                    ],
                    child: child
                  ),
                );
              }
            );
            if (date == null){
              return;
            }
            //endregion
            //region 时间
            if (context.mounted){
              time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context,child){
                  return TimePickerTheme(
                    data: TimePickerThemeData(
                      dayPeriodTextStyle: theme.textTheme.titleLarge,
                      helpTextStyle: theme.textTheme.titleLarge,
                      hourMinuteTextStyle: theme.textTheme.titleLarge,
                    ),
                    child: TextButtonTheme(
                      data: TextButtonThemeData(
                        style: ButtonStyle(
                          textStyle: WidgetStateProperty.all(theme.textTheme.titleLarge)
                        )
                      ),
                      child: Localizations(
                        locale: Get.locale!,
                        delegates: const <LocalizationsDelegate>[
                          DefaultMaterialLocalizations.delegate,
                          DefaultCupertinoLocalizations.delegate,
                          DefaultWidgetsLocalizations.delegate,
                          //GlobalMaterialLocalizations.delegate,
                          //GlobalWidgetsLocalizations.delegate,
                        ],
                        child: child
                      )
                    ),
                  );
                }
              );
            }
            if (time == null){
              return;
            }
            //endregion
            DateTime? dateWithTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            dateTextEditingController.text = DateUtil.formatDateTime(
              dateWithTime.toString(),
              DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE
            );
            await dateOnChanged(dateTextEditingController.text);
          },
        );
      case 2: ///日期范围
        return IconButton(
          icon: Icon(
            Icons.calendar_month_outlined,
            color: Colors.white,
            size: theme.textTheme.bodyLarge!.fontSize! * 1.43,
          ),
          tooltip: '日期范围选择',
          onPressed: () async{
            DateTime startDate = DateTime.now();
            DateTime endDate = DateTime.now();
            List<String> dateList = dateTextEditingController.text.split('到');
            if (dateList.length == 2){
              startDate = DateTime.tryParse(dateList[0]) ?? DateTime.now();
              endDate = DateTime.tryParse(dateList[1]) ?? DateTime.now();
            }
            //region dateTimeRange
            DateTimeRange? dateTimeRange = await showDateRangePicker(
              locale: Get.locale!,
              context: Get.context!,
              firstDate: DateTime(1900),
              lastDate: DateTime(2200),
              initialDateRange: DateTimeRange(start: startDate, end: endDate),
              builder: (context, child){
                return TextButtonTheme(
                  data: TextButtonThemeData(
                    style: ButtonStyle(
                      textStyle: WidgetStateProperty.all(theme.textTheme.titleLarge)
                    )
                  ),
                  child: Localizations(
                    locale: Get.locale!,
                    delegates: const <LocalizationsDelegate>[
                      DefaultMaterialLocalizations.delegate,
                      DefaultCupertinoLocalizations.delegate,
                      DefaultWidgetsLocalizations.delegate,
                      //GlobalMaterialLocalizations.delegate,
                      //GlobalWidgetsLocalizations.delegate,
                    ],
                    child: child
                  ),
                );
              }
            );
            //endregion
            if (dateTimeRange == null){
              return;
            }
            startDate = dateTimeRange.start;
            endDate = dateTimeRange.end;
            dateTextEditingController.text =
            '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
                '到'
                '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
            await dateOnChanged(dateTextEditingController.text);
          },
        );
      case 3: ///下拉列表：今天、昨天、近七天、近一个月、近三个月、自定义（日期范围）
        return MenuBar(
          style: MenuStyle(
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          ),
          children: [
            SubmenuButton(
              style: ButtonStyle(
                alignment: Alignment.center,
                visualDensity: const VisualDensity(horizontal: -4),
                padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
              ),
              menuChildren: dateChoiceList,
              child: Icon(
                Icons.calendar_month_outlined,
                size: theme.textTheme.bodyLarge!.fontSize! * 1.43,
                color: Colors.white,
                semanticLabel: '日期范围选择',
              )
            )
          ],
        );
      case 4: ///1 日期
        return IconButton(
          icon: Icon(
            Icons.calendar_month_outlined,
            color: Colors.white,
            size: theme.textTheme.bodyLarge!.fontSize! * 1.43,
          ),
          tooltip: '日期时间选择',
          onPressed: () async{
            DateTime dateTime = DateTime.tryParse(dateTextEditingController.text) ?? DateTime.now();
            DateTime? date;
            //region 日期
            date = await showDatePicker(
              locale: Get.locale!,
              context: Get.context!,
              initialDate: dateTime,
              firstDate: DateTime(1900),
              lastDate: DateTime(2200),
              //locale: Get.locale,
              builder: (context, child){
                return TextButtonTheme(
                  data: TextButtonThemeData(
                    style: ButtonStyle(
                      textStyle: WidgetStateProperty.all(theme.textTheme.titleLarge)
                    )
                  ),
                  child: Localizations(
                    locale: Get.locale!,
                    delegates: const <LocalizationsDelegate>[
                      DefaultMaterialLocalizations.delegate,
                      DefaultCupertinoLocalizations.delegate,
                      DefaultWidgetsLocalizations.delegate,
                      //GlobalMaterialLocalizations.delegate,
                      //GlobalWidgetsLocalizations.delegate,
                    ],
                    child: child
                  ),
                );
              }
            );
            if (date == null){
              return;
            }
            //endregion
            DateTime? dateWithTime = DateTime(date.year, date.month, date.day);
            dateTextEditingController.text = DateUtil.formatDateTime(
              dateWithTime.toString(),
              DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE
            );
            await dateOnChanged(dateTextEditingController.text);
          },
        );
      default:
        return null;
    }
  }

  Widget dateChoiceWidget({required String title, VoidCallback? onTap}){
    return MenuItemButton(
      onPressed: () { onTap?.call(); },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.only(top: 32, bottom: 32, left: 16, right: 48)
        ),
      ),
      child: MenuAcceleratorLabel(title),
    );
  }
  late final List<Widget> dateChoiceList = [
    dateChoiceWidget(
        title: '今天',
        onTap: () async {
          DateTime startDate = DateTime.now();
          DateTime endDate = DateTime.now();
          dateTextEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          await dateOnChanged(dateTextEditingController.text);
        }
    ),
    dateChoiceWidget(
        title: '昨天',
        onTap: () async {
          DateTime startDate = DateTime.now().add(const Duration(days: -1));
          DateTime endDate = DateTime.now().add(const Duration(days: -1));
          dateTextEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          await dateOnChanged(dateTextEditingController.text);
        }
    ),
    dateChoiceWidget(
        title: '近七天',
        onTap: () async {
          DateTime startDate = DateTime.now().add(const Duration(days: -6));
          DateTime endDate = DateTime.now();
          dateTextEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          await dateOnChanged(dateTextEditingController.text);
        }
    ),
    dateChoiceWidget(
        title: '近一个月',
        onTap: () async {
          DateTime startDate = DateTime.now().add(const Duration(days: -29));
          DateTime endDate = DateTime.now();
          dateTextEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          await dateOnChanged(dateTextEditingController.text);
        }
    ),
    dateChoiceWidget(
        title: '近三个月',
        onTap: () async {
          DateTime startDate = DateTime.now().add(const Duration(days: -89));
          DateTime endDate = DateTime.now();
          dateTextEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          await dateOnChanged(dateTextEditingController.text);
        }
    ),
    dateChoiceWidget(
        title: '自定义',
        onTap: () async {
          DateTime startDate = DateTime.now();
          DateTime endDate = DateTime.now();
          List<String> dateList = dateTextEditingController.text.split('到');
          if (dateList.length == 2){
            startDate = DateTime.tryParse(dateList[0]) ?? DateTime.now();
            endDate = DateTime.tryParse(dateList[1]) ?? DateTime.now();
          }
          //region dateTimeRange
          DateTimeRange? dateTimeRange = await showDateRangePicker(
            locale: Get.locale!,
            context: Get.context!,
            firstDate: DateTime(1900),
            lastDate: DateTime(2200),
            initialDateRange: DateTimeRange(start: startDate, end: endDate),
            builder: (context, child){
              return TextButtonTheme(
                data: TextButtonThemeData(
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.all(
                      Theme.of(context).textTheme.titleLarge
                    )
                  )
                ),
                child: Localizations(
                  locale: Get.locale!,
                  delegates: const <LocalizationsDelegate>[
                    DefaultMaterialLocalizations.delegate,
                    DefaultCupertinoLocalizations.delegate,
                    DefaultWidgetsLocalizations.delegate,
                    //GlobalMaterialLocalizations.delegate,
                    //GlobalWidgetsLocalizations.delegate,
                  ],
                  child: child
                ),
              );
            }
          );
          //endregion
          if (dateTimeRange == null){
            return;
          }
          startDate = dateTimeRange.start;
          endDate = dateTimeRange.end;
          dateTextEditingController.text = '${DateUtil.formatDateTime(startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
              '到'
              '${DateUtil.formatDateTime(endDate.toString(), DateFormat.YEAR_MONTH_DAY)}';
          await dateOnChanged(dateTextEditingController.text);
        }
    ),
  ];

  Widget numButton(BuildContext context, String text){
    ThemeData theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          textEditingController.text += text;
        },
        child: Container(
          alignment: Alignment.center,
          child: AutoSizeText(
            text,
            style: theme.textTheme.titleLarge!.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget iconButton(BuildContext context, IconData icon, {bool isBackSpace = false}){
    ThemeData theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          if(isBackSpace && textEditingController.text.isNotEmpty){
            textEditingController.text = textEditingController.text.substring(
              0,
              textEditingController.text.length - 1
            );
          }
          else {
            textEditingController.text = '';
          }
        },
        child: Container(
         alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
            size: theme.textTheme.titleLarge!.fontSize,
          )
        )
      ),
    );
  }

  Widget outlineButton(BuildContext context, {required String title, AsyncCallback? onPressed}){
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      style: kIsWeb || GetPlatform.isWindows ?
      ButtonStyle(
          padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(horizontal: 24, vertical: 18)
          )
      ) :
      ButtonStyle(
        padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(horizontal: 28, vertical: 12)
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: theme.textTheme.bodyLarge!.fontSize,
        ),
      ),
      onPressed: () async {
        await onPressed?.call();
      },
    );
  }

  Widget filledButton(BuildContext context, {required String title, AsyncCallback? onPressed}){
    ThemeData theme = Theme.of(context);
    return FilledButton(
      style: kIsWeb || GetPlatform.isWindows ?
      ButtonStyle(
          padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(horizontal: 24, vertical: 18)
          )
      ) :
      ButtonStyle(
        padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(horizontal: 28, vertical: 12)
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: theme.textTheme.bodyLarge!.fontSize,
        ),
      ),
      onPressed: () async {
        await onPressed?.call();
      },
    );
  }

  Widget dataView(BuildContext context, List<T> dataList){
    Widget child;
    ThemeData theme = Theme.of(context);
    switch (widget.pickerChoiceType){
      case PickerChoiceType.checkboxListTile:
        child = ListView.builder(
          controller: scrollController,
          itemCount: dataList.length,
          itemBuilder: (BuildContext context, int index){
            final T item = dataList[index];
            return Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                title: Text(
                  '${item.code} ${item.name}',
                  style: theme.textTheme.bodyLarge,
                ),
                value: item.isSelected,
                onChanged: (bool? value) async {
                  onSelected(item);
                },
              )
            );
          },
        );
        break;
      case PickerChoiceType.chip:
        child = GridView.builder(
          controller: scrollController,
          shrinkWrap: false,
          semanticChildCount: 0,
          addAutomaticKeepAlives: true,
          padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 2),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 170,
            childAspectRatio: 1.8,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: dataList.length,
          itemBuilder: (BuildContext context, int index){
            final T item = dataList[index];
            return Material(
              elevation: 4,
              color: theme.cardColor,
              shadowColor: Theme.of(context).colorScheme.shadow,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: InkWell(
                onTap: (){
                  onSelected(item);
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: item.isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          item.code.isNotEmpty ? item.code : ' ',
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1, overflow: TextOverflow.ellipsis
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          item.name.isNotEmpty ? item.name : ' ',
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1, overflow: TextOverflow.ellipsis
                        ),
                      ),
                    ],
                  )
                ),
              ),
            );
          },
        );
        break;
      case PickerChoiceType.pmesTask:
      case PickerChoiceType.mesTask:
        //region 注塑派工单选单样式 生产派工单选单样式
        assert(adapter is TaskAdapter);
        child = ListView.builder(
          itemCount: dataList.length,
          itemBuilder: (BuildContext context, int index){
            final MoTaskModel item = dataList[index] as MoTaskModel;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                elevation: 4,
                color: theme.cardColor,
                shadowColor: Theme.of(context).colorScheme.shadow,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: (){
                    onSelected(item as T);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: item.isSelected,
                              onChanged: (bool? bool) async{
                                onSelected(item as T);
                              },
                            ),
                            const SizedBox(width: 8,),
                            Expanded(
                              child: Text(
                                '${item.invName}',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                            const SizedBox(width: 8,),

                            Text(
                              item.status ?? '制单',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: getTaskSignColor(item.sign ?? 0),
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            const SizedBox(width: 16,),
                            TextButton(
                              onPressed: (){
                                item.isExpanded = !item.isExpanded;
                                setState(() { });
                              },
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(
                                    kIsWeb || GetPlatform.isWindows
                                        ? const EdgeInsets.symmetric(vertical: 14, horizontal: 8)
                                        : const EdgeInsets.symmetric(vertical: 8, horizontal: 8)
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.isExpanded ? '收起' : '展开',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(width: 2,),
                                  AnimatedRotation(
                                      turns: item.isExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 100),
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                        size:  Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 4),
                          constraints: BoxConstraints(
                            minHeight: 40,
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            runAlignment: WrapAlignment.end,
                            runSpacing: 4, spacing: 6,
                            children: getFieldList(
                              context,
                              infoFormList: dataListInfoFormListMap[0] ?? [],
                              item: item,
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: !item.isExpanded ?
                          const SizedBox.shrink() :
                          Wrap(
                            runSpacing: 4, spacing: 6,
                            children: getFieldList(
                              context,
                              infoFormList: dataListInfoFormListMap[1] ?? [],
                              item: item,
                            ),
                          ),
                          crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 250),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            );
          },
        );
        //endregion
        break;
        case PickerChoiceType.process:
          //region 工序选单样式
          assert(adapter is ProcessAdapter);
          child = GridView.builder(
            shrinkWrap: false,
            semanticChildCount: 0,
            addAutomaticKeepAlives: true,
            padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 2),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 2.4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: dataList.length,
            itemBuilder: (BuildContext context, int index){
              MoWorkBillEntryModel item = dataList[index] as MoWorkBillEntryModel;
              MoRoutingEntryModel? routingEntryModel = (adapter as ProcessAdapter).routingEntryList.firstWhereOrNull(
                      (element) => element.opId == item.opId);
              return Material(
                elevation: 4,
                color: theme.cardColor,
                shadowColor: Theme.of(context).colorScheme.shadow,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: InkWell(
                  onTap: () {
                    onSelected(item as T);
                    opDescription = '[${item.opName ?? ''}]${item.opDescription ?? ' '}';
                    setState(() { });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MineIconButton(
                          onPressed: () async{
                            await widget.processItemAttach?.call(item, routingEntryModel);
                          },
                          tooltip: '工序图纸',
                          isNeedBadges: routingEntryModel != null && routingEntryModel.sop != null && routingEntryModel.sop != 0,
                          badgesWidget: Text(
                            (routingEntryModel?.sop ?? '').toString(),
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                color: Theme.of(context).colorScheme.surface
                            ),
                          ),
                          icon: Icons.attach_file_outlined,
                          iconSize: 22,
                          iconColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
                        ),
                        const SizedBox(width: 4,),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${(item.opName ?? '').isNotEmpty ? item.opName : ' '}',
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600
                                  ),
                                  maxLines: 1, overflow: TextOverflow.ellipsis
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '检 ${NumFormatUtil.qtyFormatConverter((item.acceptQty ?? 0).toStringAsFixed(0))}'
                                      ' / '
                                      '次 ${NumFormatUtil.qtyFormatConverter((item.disabledQty ?? 0).toStringAsFixed(0))}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  maxLines: 1, overflow: TextOverflow.ellipsis
                                ),
                              ),
                            ],
                          )
                        ),
                      ],
                    ),
                  )
                )
              );
            },
          );
          //endregion
          break;
      default:
        child = const SizedBox.shrink();
        break;
    }
    return child;
  }



  //region

  final _dataService = Get.find<DataService>();

  Color getTaskSignColor(int sign){
    if (sign > MoTaskSign.zd.sign && sign < MoTaskSign.scz.sign){
      return AppColors.totalColor;
    }
    else if (sign >= MoTaskSign.scz.sign && sign < MoTaskSign.ysc.sign){
      return AppColors.runColor;
    }
    else if (sign >= MoTaskSign.ysc.sign){
      return AppColors.stopColor;
    }
    else {
      return AppColors.totalColor;
    }
  }

  Future<void> infoItemOnTap(ICloneable item) async{
    onSelected(item as T);
  }

  Widget infoItem(BuildContext context, {
    required String title,
    required String content,
    Color? contentColor,
    int? width,
    double titleWidth = 100,
    bool isBold = false,
    AsyncValueSetter<ICloneable>? widgetInfoItemOnTap,
    ICloneable? item,
  }) {
    width ??= 320;
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: width.toDouble(),
      titleWidth: titleWidth,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: contentColor,
          fontWeight: isBold ? FontWeight.w600 : null
      ),
      onPress: () async {
        if (item != null){
          if (widgetInfoItemOnTap != null){
            await widgetInfoItemOnTap.call(item);
          }
          else {
            await infoItemOnTap.call(item);
          }
        }
      },
    );
  }


  List<Widget> getFieldList(BuildContext context, {
    required List<InfoFormModel> infoFormList,
    required ICloneable item,
    CustomBuilder? customBuilder,
    AsyncValueSetter<ICloneable>? widgetInfoItemOnTap,
  }){
    List<Widget> list = [];

    infoFormList.forEach((element) {
      Map<String, dynamic> jsonData = item.toJson();
      bool isShow = element.isShow;
      String title = element.title;
      if (element.title.contains('@')){
        ///是自定义项
        if (element.keyName.startsWith('Free')){
          /// Free 自由项要用 IsFree 来控制
          isShow = isShow && jsonData['Is${element.keyName}'] == 1;
          title = _dataService.userDefMap[element.keyName]?.defCaption ?? '';
        }
        else if (element.keyName.startsWith('OrderDefine')){
          /// OrderDefine 自定义项对应任务单的 Define
          String keyName = element.keyName.replaceAll('Order', '');
          isShow = isShow && _dataService.userDefMap[keyName] != null;
          title = _dataService.userDefMap[keyName]?.defCaption ?? '';
        }
        else {
          isShow = isShow && _dataService.userDefMap[element.keyName] != null;
          title = _dataService.userDefMap[element.keyName]?.defCaption ?? '';
        }
      }
      if (isShow){
        String content = _getInfoFormContent(jsonData[element.keyName]);
        Color? color = element.isHighlight ? AppColors.errorColor : null;
        bool isBold = element.isHighlight;
        Map<String, dynamic>? customMap = customBuilder?.call(element.keyName, item);
        if (customMap != null){
          content = customMap['content'] ?? content;
          if (customMap.containsKey('color')){
            color = customMap['color'];
          }
          if (customMap.containsKey('isBold')){
            isBold = customMap['isBold'];
          }
        }
        list.add(
            infoItem(
              context,
              title: title,
              content: content,
              contentColor: color,
              width: element.width,
              isBold: isBold,
              widgetInfoItemOnTap: widgetInfoItemOnTap,
              item: item,
            )
        );
      }
    });

    return list;
  }

  ///获取显示在前台的数据
  String _getInfoFormContent(dynamic data) {
    String content = '';
    if (data is DateTime){
      content = DateUtil.getDateStrByDateTime(
          data,
          format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':'
      ) ?? '';
    }
    else if (data is num){
      int decimal = 0;
      if (data != data.toInt()){
        String str = data.toString();
        decimal = str.split('.')[1].length;
      }
      content = NumFormatUtil.qtyFormatConverter(data.toString(), decimal: decimal);
    }
    else {
      content = data?.toString() ?? '';
    }
    return content;
  }
  ///获取显示在前台的数据
  String Function(dynamic data) get getInfoFormContent => _getInfoFormContent;

  //endregion



  @override
  void dispose(){
    super.dispose();
    Future.delayed(debounce.delay, (){
      debounce.dispose();
      textEditingController.removeListener(_textEditingControllerListener);
    });
  }
}