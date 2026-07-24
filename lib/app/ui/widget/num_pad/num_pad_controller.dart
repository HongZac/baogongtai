import 'package:flutter/material.dart';
import 'package:textfield_state/textfield_state.dart';

///函数定义，焦点切换事件
typedef OnFocusChanged = void Function(String key, bool focused);

///NumPad 数据键盘关联的TextEditForm 关联对象
class NumPadController{
  final String key;
  ///中文
  final String zhName;
  late final TextEditingController controller;
  late final FocusNode focusNode;
  final String? value;

  ///是否可输入
  bool enabled;

  ///状态控制 把TextEditingController、FocusNode、onFocusChange包装起来
  ///
  ///当焦点切换时，可以由此得知该焦点的 key 值
  late final TextFieldState state;

  ///焦点切换事件 在 NumPad 中赋值
  late OnFocusChanged? onFocusChange;

  ///当前输入框中的数据是否来自称重消息
  bool isDataByWeightMsg = false;

  ///输入框额外要求的样式
  Map<String, dynamic> styleMap = {};

  ///默认不显示键盘
  TextInputType keyboardType;


  NumPadController({
    required this.key,
    this.zhName = '',
    this.value,
    TextEditingController? controller,
    FocusNode? focusNode,
    this.enabled = true,
    this.onFocusChange,
    this.keyboardType = TextInputType.none,
  }) {
    this.controller = controller ?? TextEditingController(text: value);
    this.focusNode = focusNode ?? FocusNode(debugLabel: key);
    state = TextFieldState(
      controller: this.controller,
      focusNode: this.focusNode,
      focusChanged: _onFocusChange,
      //primaryFocusChanged: _onFocusChange,
      textChanged: _onChanged,
    );
  }

  void _onFocusChange(bool focused){
    if(onFocusChange != null){
      onFocusChange!(key, focused);
    }
  }

  void _onChanged(String value){  }

  void dispose() async {
    focusNode.unfocus();
    state.dispose();
    controller.dispose();
  }
}