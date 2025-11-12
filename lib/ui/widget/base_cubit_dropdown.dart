import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/ui/widget/base_dropdown.dart';

typedef ValueChanged<T> = void Function(int index, T value);

class BaseCubitDropDown<T extends BaseDropdownModel, C extends Cubit<BaseState>> extends StatelessWidget {
  final C cubit;
  final EdgeInsets margin;
  final String title;
  final String hintText;
  final ValueChanged<T>? didSelected;
  final bool isRequired;
  final T? initData;
  final Key? baseCubitDropDownKey;
  final String? errorRequired;

  const BaseCubitDropDown({
    this.baseCubitDropDownKey,
    required this.cubit,
    this.margin = EdgeInsets.zero,
    this.title = "",
    this.hintText = "",
    this.didSelected,
    this.isRequired = false,
    this.initData,
    this.errorRequired,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<C>(
        create: (_) => cubit,
        child: BlocBuilder<C, BaseState>(builder: (_, state) {
          List<T>? listData;
          String hintText = this.hintText;
          if (state is LoadedState<List<T>>) {
            listData = state.data;
          }
          if (state is LoadingState) {
            hintText = "dropdown.loading";
          }
          if (state is ErrorState) {
            hintText = this.hintText;
          }
          int? selectedIndex;
          try {
            selectedIndex = listData?.indexOf(initData!);
          } catch (e) {
          }
          return CustomDropDown(
              key: baseCubitDropDownKey,
              errorRequired: errorRequired,
              selectedIndex: selectedIndex,
              isRequired: isRequired,
              didSelected: (int index) {
                try {
                  didSelected?.call(index, listData![index]);
                } catch (e) {
                  print("===build =====${e}");
                }
              },
              hintText: hintText,
              title: title,
              margin: margin,
              listValues: listData?.map((e) => e.name?.toString() ?? "").toList());
        }));
  }
}
