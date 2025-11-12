import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
        create: (_) => LoginCubit(repository: getIt.get<AuthRepository>()), child: LoginBody());
  }
}

class LoginBody extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginBody> {
  final _keyUsername = GlobalKey<TextFieldState>();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      loadingWidget: CustomLoading<LoginCubit>(),
      messageNotify: CustomSnackBar<LoginCubit>(),
      title: AppLocalizations.current.appName,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              child: CustomTextInput(
                key: _keyUsername,
                textController: TextEditingController(),
                hintText: AppLocalizations.of(context).inputUserName,
                title: AppLocalizations.of(context).userName,
                validator: (String value) {
                  if (value.isEmpty) {
                    return AppLocalizations.current.plsInputUserName;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            CustomDropDown(
              listValues: ["Value 1", "Value 2", "Value 3"],
            ),
            BlocListener<LoginCubit, BaseState>(
              listener: (_, state) {
                if (state is LoadedState) {
                  // can get user info in UserInfoCubit via GetIt without context
                  getIt.get<UserInfoCubit>().getUserInfo();
                  Navigator.pushNamed(context, Routes.mainScreen);
                }
              },
              child: Container(),
            ),
            BaseButton(
              onTap: () {
                if (_keyUsername.currentState?.isValid ?? false) {
                  BlocProvider.of<LoginCubit>(context)
                      .doLogin(userName: _keyUsername.currentState?.value, password: "password");
                }
              },
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              title: AppLocalizations.of(context).login,
            ),
            BaseButton(
              onTap: () {
                BlocProvider.of<LanguageCubit>(context).changeLanguage(AppLocalizations
                    .delegate
                    .supportedLocales[Random().nextInt(AppLocalizations.delegate.supportedLocales.length)]
                    .languageCode);
              },
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              title: AppLocalizations.of(context).changeLanguage,
            ),
            BaseButton(
              onTap: () {
                CustomDialogUtil.showDialogConfirm(context, title: "Thông báo", content: "Đây là nội dung thông báo");
              },
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              title: "Show dialog",
            )
          ],
        ),
      ),
    );
  }
}
