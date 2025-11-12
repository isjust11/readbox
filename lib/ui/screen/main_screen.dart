import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/ui/widget/base_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: MainBody());
  }
}

class MainBody extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibraryCubit>(
      create: (_) => getIt.get<LibraryCubit>()..getBooks(),
      child: MainBody(),
    );
  }
}
