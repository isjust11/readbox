import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/language_cubit.dart';

class LocaleWidget extends StatelessWidget {
  final Widget Function(String) builder;

  const LocaleWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, String>(
      builder: (context, state) {
        // This will rebuild whenever LanguageCubit emits a new state
        return builder(state);
      },
    );
  }
}
