import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';

class DropdownChoice<T> extends StatefulWidget {
  DropdownChoice({
    this.height,
    required this.onChange,
    required this.items,
    this.selectedValue,
    required this.helperText,
  });

  final double? height;
  final void Function(T?)? onChange;
  final List<DropdownMenuItem<T>>? items;
  final T? selectedValue;
  final String helperText;

  @override
  _DropdownState createState() => _DropdownState<T>();
}

class _DropdownState<T> extends State<DropdownChoice<T>> {
  final _dropdownFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _dropdownFormKey,
      child: Container(
        height: widget.height ?? 60,
        decoration: BoxDecoration(
          border: Border.all(
            color: kLoginRegisterBtnColour,
            width: 2.0,
          ),
          color: kFillInText.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
          child: DropdownButtonFormField<T>(
            iconSize: 30.0,
            iconEnabledColor: kLoginRegisterBtnColour,
            style: kSubSubTitlePurple,
            borderRadius: BorderRadius.circular(10.0),
            decoration: InputDecoration(
              hintText: widget.helperText,
              hintStyle: kSubSubTitlePurple,
              border: UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
            ),
            dropdownColor: kSimpleBtnColour,
            value: widget.selectedValue,
            onChanged: (T? newValue) {
              setState(() {
                widget.onChange!(newValue);
              });
            },
            items: widget.items,
          ),
        ),
      ),
    );
  }
}
