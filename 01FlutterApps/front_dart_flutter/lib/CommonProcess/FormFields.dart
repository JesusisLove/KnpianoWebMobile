import 'package:flutter/material.dart';

class FormFields {
  static TextFormField createTextFormField({
    required FocusNode inputFocusNode,
    required String inputLabelText,
    required Color inputLabelColor,
    required Function(String?) onSave,
    String? initialValue,
    TextEditingController? inputController,
    required Color themeColor,
    required double enabledBorderSideWidth,
    required double focusedBorderSideWidth,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool? blnReadOnly ,
    bool? blnEnabled
  }) {
    // 检查控制器是否传入，如果没有则创建一个新的，并设置初始值
    final TextEditingController controller = inputController ?? TextEditingController(text: initialValue);
  
return TextFormField(
      focusNode: inputFocusNode,
      controller: controller, // 使用上面定义的控制器
      decoration: InputDecoration(
        enabled: blnEnabled?? true,
        labelText: inputLabelText,
        labelStyle: TextStyle(color: inputLabelColor),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: themeColor,
            width: enabledBorderSideWidth,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: themeColor,
            width: focusedBorderSideWidth,
          ),
        ),
      ),
      readOnly: blnReadOnly?? false,
      onTap: onTap,
      onSaved: (value) => onSave(value),
      validator: validator,
    );
  }
}
