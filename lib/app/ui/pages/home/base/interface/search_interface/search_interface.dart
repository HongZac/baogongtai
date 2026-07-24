
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/root/root_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///关键字搜索接口
mixin SearchInterface on GetxController {
  
  final _rootController = Get.find<RootController>();

  ///是否显示关键字搜索输入框
  bool isShowSearchInputBox = AppConfig.isShowSearchInputBox;

  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();
  bool isSearchWidgetOpen = false;

  ///列表搜索方式，该值是[searchTypeList]中对应项的索引
  int searchTypeIndex = AppConfig.searchTypeIndex;
  ///搜索方式列表
  List<ChoiceChipModel> get searchTypeList => List.unmodifiable([]);
  ///搜索时对应的关键字段名称
  List<String> get searchQueryDataList => List.unmodifiable([]);


  @override
  Future<void> onReady() async{
    super.onReady();
    _searchFNOnListen();
  }


  ///搜索输入框的焦点监听
  void _searchFNOnListen() {
    searchFN.addListener(() async {
      if (_rootController.isKeyboardOpenAfterClickTC && searchFN.hasFocus && !kIsWeb && GetPlatform.isWindows){
        await _rootController.openKeyboard();
      }
      //update();
    });
  }


  Widget searchInputWidget(BuildContext context, {
    bool needOpenBtn = true, double? width,
  }){
    List<Widget> searchTypeMenuList = List.generate(searchTypeList.length, (index) {
      ChoiceChipModel e = searchTypeList[index];
      return MenuItemButton(
        onPressed: () {
          searchTypeOnChanged(e, index);
        },
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
              const EdgeInsets.only(top: 22, bottom: 22, left: 12, right: 44)
          ),
          textStyle: WidgetStateProperty.all(
            Theme.of(context).textTheme.bodyLarge!
          )
        ),
        child: MenuAcceleratorLabel(e.title),
      );
    }).toList();
    Widget textField = TextField(
      controller: searchTC,
      focusNode: searchFN,
      style: Theme.of(context).textTheme.bodyLarge,
      onChanged: (String? string) async{
        searchTCOnChanged();
      },
      onTap: needOpenBtn ? (){
        if (!isSearchWidgetOpen){
          isSearchWidgetOpen = true;
          update();
        }
      } : null,
      decoration: InputDecoration(
        hintText: searchTypeList[searchTypeIndex].title,
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(
          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
        ),
        contentPadding: kIsWeb || GetPlatform.isWindows
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        prefixIcon: needOpenBtn ?
        MineIconButton(
          icon: Icons.search,
          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
          iconColor: Theme.of(context).inputDecorationTheme.iconColor,
          tooltip: isSearchWidgetOpen ? '收起' : '展开',
          onPressed: () async {
            isSearchWidgetOpen = !isSearchWidgetOpen;
            if (isSearchWidgetOpen){
              FocusScope.of(Get.context!).requestFocus(searchFN);
            }
            else {
              searchFN.unfocus();
            }
            update();
          },
        ) :
        Icon(
          Icons.search,
          size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
          color: Theme.of(context).inputDecorationTheme.iconColor,
        ),
        suffixIcon: (needOpenBtn
            ? (!isSearchWidgetOpen || searchTC.text.isEmpty)
            : (searchTC.text.isEmpty)) ?
        null :
        MineIconButton(
          icon: Icons.cancel,
          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
          tooltip: '清空',
          onPressed: () async{
            await searchTCOnClear();
          },
        ),
        enabledBorder: needOpenBtn ?
        (isSearchWidgetOpen
            ? null
            : const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent))) :
        null,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (needOpenBtn)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            width: isSearchWidgetOpen ? (width ?? 230) : 50,
            child: textField,
          )
        else
          Container(
            width: width ?? 480, height: 50,
            child: textField,
          ),

        if (needOpenBtn ? isSearchWidgetOpen : true)
          const SizedBox(width: 4,),
        if (needOpenBtn ? isSearchWidgetOpen : true)
          if (searchTypeList.length == 1)
            FilledButton(
              onPressed: () async{
                await onSearch();
              },
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(const Size(80, 54)),
              ),
              child: Text(
                '查询',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                ),
              ),
            )
          else
            MenuBar(
              style: MenuStyle(
                  backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                  padding: WidgetStateProperty.all(EdgeInsets.zero)
              ),
              children: [
                SubmenuButton(
                  menuChildren: searchTypeMenuList,
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.all(0))
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () async{
                          await onSearch();
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                              kIsWeb || GetPlatform.isWindows
                                ? const EdgeInsets.only(top: 20, bottom: 20, left: 12)
                                : const EdgeInsets.only(top: 13, bottom: 13, left: 12)
                          ),
                        ),
                        child: Text(
                          searchTypeList[searchTypeIndex].title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

        if (needOpenBtn ? isSearchWidgetOpen : false)
          const SizedBox(width: 4,),
        if (needOpenBtn ? isSearchWidgetOpen : false)
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primaryContainer
              ),
              padding: WidgetStateProperty.all(
                  kIsWeb || GetPlatform.isWindows
                    ? const EdgeInsets.symmetric(vertical: 20, horizontal: 22)
                    : const EdgeInsets.symmetric(vertical: 13, horizontal: 22)
              ),
            ),
            child: Text(
              '收起',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
              ),
            ),
            onPressed: () async {
              if (isSearchWidgetOpen){
                isSearchWidgetOpen = false;
                searchFN.unfocus();
                update();
              }
            },
          ),
      ],
    );
  }


  ///搜索类型列表 选择回调
  Future<void> searchTypeOnChanged(ChoiceChipModel item, int index) async {  }

  ///搜索框输入变化
  void searchTCOnChanged() {  }

  ///搜索按钮点击回调
  Future<void> onSearch() async {  }

  ///搜索框清空按钮点击回调
  Future<void> searchTCOnClear() async {  }



  //region 设置

  ///是否显示关键字搜索框 选择变化
  void _isShowSearchInputBoxOnChanged(){
    isShowSearchInputBox = !isShowSearchInputBox;
    update();
  }


  Widget isShowSearchInputBoxWidget(BuildContext context){
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      value: isShowSearchInputBox,
      onChanged: (bool? bool) {
        _isShowSearchInputBoxOnChanged();
      },
      title: Text(
        '显示关键字搜索框',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  //endregion


  @override
  void onClose() {
    searchTC.dispose();
    searchFN.dispose();
    super.onClose();
  }

}