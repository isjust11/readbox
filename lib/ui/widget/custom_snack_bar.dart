import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class CustomSnackBar<T extends Cubit<BaseState>> extends StatelessWidget {
  final double? fontSize;
  final Color? textColor;

  const CustomSnackBar({Key? key, this.fontSize, this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<T, BaseState>(
        child: Container(),
        listener: (context, state) {
          String? mess;
          if (state is LoadedState && state.msgError.isNotEmpty) {
            mess = state.msgError;
          } else if (state is ErrorState) {
            mess = state.data;
          }
          if (mess?.isNotEmpty ?? false) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: CustomTextLabel(
                mess,
                fontSize: fontSize ?? 14,
                color: textColor ?? AppColors.gray,
                fontWeight: FontWeight.w400,
              ),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(20),
              backgroundColor: AppColors.white,
              duration: Duration(milliseconds: 1400),
            ));
          }
        });
  }
}
