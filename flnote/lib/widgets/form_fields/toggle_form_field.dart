import 'package:flutter/material.dart';

class ToggleFormField extends FormField<bool> {
  ToggleFormField({
    String hint,
    FormFieldSetter<bool> onSaved,
    bool initialValue = false,
    Color color,
  }) : super(
          onSaved: onSaved,
          initialValue: initialValue,
          builder: (FormFieldState<bool> state) {
            return Container(
              height: 60.0,
              // child: Text(hint),
              child: FlatButton(
                color: color,
                child: state.value
                    ? Icon(Icons.check)
                    : Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  state.didChange(!state.value);
                },
              ),
            );
          },
        );
}
