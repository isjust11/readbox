import 'package:flutter/material.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class CustomDropDown extends StatefulWidget {
  final double? heightOfBox;
  final EdgeInsets margin;
  final String title;
  final String hintText;
  final List<String>? listValues;
  final int? selectedIndex;
  final Function? didSelected;
  final bool isRequired;
  final Color? titleColor;
  final Color? valueColor;
  final Color? bgColorDropdownSelect;
  final BoxBorder? border;
  final bool enabled;
  final String? errorRequired;

  const CustomDropDown(
      {this.heightOfBox,
      this.margin = EdgeInsets.zero,
      this.title = "",
      this.hintText = "",
      required this.listValues,
      this.selectedIndex,
      this.didSelected,
      this.isRequired = false,
      this.titleColor,
      this.valueColor,
      super.key,
      this.bgColorDropdownSelect,
      this.enabled = true,
      this.border,
      this.errorRequired});

  @override
  State<StatefulWidget> createState() {
    return CustomDropDownState();
  }
}

class CustomDropDownState extends State<CustomDropDown> {
  int? selectedIndex;
  String errorText = "";

  @override
  void initState() {
    super.initState();
    if (widget.selectedIndex != null && widget.selectedIndex! < (widget.listValues?.length ?? 0)) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  void didUpdateWidget(covariant CustomDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    selectedIndex = widget.selectedIndex;
  }

  bool get isValid => _validate();

  bool _validate() {
    String error = "";
    if (widget.isRequired == true && selectedIndex == null) {
      error = widget.errorRequired ?? "dropdown.error_required";
    }
    setState(() {
      errorText = error;
    });
    return error.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: widget.heightOfBox ?? 45,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: widget.border ?? Border.all(width: 1, color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                  items: createListDropdownMenuItem(),
                  value: selectedIndex,
                  onChanged: widget.enabled
                      ? (int? index) {
                          setState(() {
                            selectedIndex = index;
                            widget.didSelected?.call(index);
                            errorText = "";
                          });
                        }
                      : null,
                  style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w400),
                  hint: CustomTextLabel(
                    widget.hintText,
                    color: AppColors.hintTextColor,
                    fontSize: 14,
                  ),
                  icon: Container(
                    width: 15,
                    // height: 10,
                    margin: EdgeInsets.only(right: 4),
                    child: Icon(Icons.arrow_drop_down_sharp
                        // width: 10,
                        // height: 10,
                        // fit: BoxFit.contain,
                        ),
                  ),
                  isExpanded: true,
              ),
            ),
          ),
          errorText.isNotEmpty
              ? ErrorTextWidget(
                  errorText: errorText,
                )
              : Container()
        ],
      ),
    );
  }

  List<DropdownMenuItem<int>> createListDropdownMenuItem() {
    List<DropdownMenuItem<int>> list = [];
    for (int i = 0; i < (widget.listValues?.length ?? 0); i++) {
      DropdownMenuItem<int> item = DropdownMenuItem<int>(
        value: i,
        child: CustomTextLabel(
          widget.listValues![i],
          color: widget.valueColor ?? AppColors.colorTitle,
          maxLines: 1,
        ),
      );
      list.add(item);
    }
    return list;
  }
}
