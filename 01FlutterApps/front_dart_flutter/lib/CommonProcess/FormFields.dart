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
    bool blnReadOnly = false,
  }) {
    return TextFormField(
      focusNode: inputFocusNode,
      controller: inputController,
      decoration: InputDecoration(
        labelText: inputLabelText,
        labelStyle: TextStyle(color: inputLabelColor),
        enabledBorder:  UnderlineInputBorder(
          borderSide: BorderSide(
            color: themeColor,
            width: enabledBorderSideWidth,
          ),
        ),
        focusedBorder:  UnderlineInputBorder(
          borderSide: BorderSide(
            color: themeColor,
            width: enabledBorderSideWidth,
          ),
        ),
      ),
      readOnly: blnReadOnly,
      onTap: onTap,
      onSaved: (value) => onSave(value),
      validator: validator,
    );
  }
}
