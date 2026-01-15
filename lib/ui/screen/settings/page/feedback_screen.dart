import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:readbox/injection_container.dart';
import 'package:readbox/ui/widget/widget.dart';


class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt.get<FeedbackCubit>(),
      child: const FeedbackBody(),
    );
  }
}

class FeedbackBody extends StatefulWidget {
  const FeedbackBody({super.key});

  @override
  State<FeedbackBody> createState() => _FeedbackBodyState();
}

class _FeedbackBodyState extends State<FeedbackBody> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  FeedbackType _selectedType = FeedbackType.general;
  FeedbackPriority _selectedPriority = FeedbackPriority.medium;
  bool _isAnonymous = false;
  String _deviceInfo = '';
  String _appVersion = '';
  String _osVersion = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = 'Android ${androidInfo.model}';
        _osVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = 'iOS ${iosInfo.model}';
        _osVersion = 'iOS ${iosInfo.systemVersion}';
      }

      _appVersion = packageInfo.version;
    } catch (e) {
      // print('Error loading device info: $e');
    }
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    _emailController.clear();
    _phoneController.clear();
    _nameController.clear();
    setState(() {
      _selectedType = FeedbackType.general;
      _selectedPriority = FeedbackPriority.medium;
      _isAnonymous = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final feedback = FeedbackModel(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: _selectedType,
      priority: _selectedPriority,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      deviceInfo: _deviceInfo.isNotEmpty ? _deviceInfo : null,
      appVersion: _appVersion.isNotEmpty ? _appVersion : null,
      osVersion: _osVersion.isNotEmpty ? _osVersion : null,
      isAnonymous: _isAnonymous,
    );

    context.read<FeedbackCubit>().createFeedback(feedback);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedbackCubit, BaseState>(
      bloc: context.read<FeedbackCubit>(),
      listener: (context, state) {
        if (state is ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomTextLabel(
                state.data?.toString() ?? AppLocalizations.current.error_common,
                fontSize: AppDimens.SIZE_16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              backgroundColor: AppColors.colorError,
            ),
          );
        }
        if (state is LoadedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomTextLabel(
                AppLocalizations.current.feedbackSuccess,
                fontSize: AppDimens.SIZE_16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              backgroundColor: AppColors.baseColor,
            ),
          );
          _clearForm();
        }
      },
      child: BlocBuilder<FeedbackCubit, BaseState>(
        bloc: context.read<FeedbackCubit>(),
        builder: (context, state) {
          final theme = Theme.of(context);
          return BaseScreen(
            title: AppLocalizations.current.sendFeedback,
            colorTitle: theme.colorScheme.surfaceContainerHighest,
            body: _buildBody(theme, state),
            colorBg: theme.colorScheme.surface,
          );
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme, BaseState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimens.SIZE_16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppDimens.SIZE_12),
            _buildFeedbackForm(),
            const SizedBox(height: AppDimens.SIZE_12),
            _buildSubmitButton(state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        CustomTextLabel(
          AppLocalizations.current.feedbackDescription,
          fontSize: AppDimens.SIZE_16,
          color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.colorTitle,
        ),
      ],
    );
  }

  Widget _buildFeedbackForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loại phản hồi
        _buildSectionTitle(AppLocalizations.current.feedbackType),
        const SizedBox(height: 8),
        _buildTypeSelector(),
        const SizedBox(height: 16),

        // Mức độ ưu tiên
        _buildSectionTitle(AppLocalizations.current.feedbackPriority),
        const SizedBox(height: 8),
        _buildPrioritySelector(),
        const SizedBox(height: 16),

        // Tiêu đề
        CustomTextInput(
          textController: _titleController,
          isRequired: true,
          title: AppLocalizations.current.feedbackTitle,
          hintText: AppLocalizations.current.feedbackTitle,
          prefixIcon: Icon(Icons.title_outlined),
          validator: (value) => value.isEmpty ? AppLocalizations.current.feedbackTitleRequired : null,
        ),
        const SizedBox(height: 16),

        // Nội dung
        CustomTextInput(
          textController: _contentController,
          isRequired: true,
          title: AppLocalizations.current.feedbackContent,
          hintText: AppLocalizations.current.feedbackContent,
          prefixIcon: Icon(Icons.description_outlined),
          maxLines: 5,
          minLines: 5,
          validator: (value) => value.isEmpty ? AppLocalizations.current.feedbackContentRequired : null,
        ),
        const SizedBox(height: 16),

        // Thông tin liên hệ
        Row(
          children: [
            Expanded(
              child: CustomTextInput(
                textController: _nameController,
                isRequired: true,
                title: AppLocalizations.current.feedbackName,
                hintText: AppLocalizations.current.feedbackName,
                prefixIcon: Icon(Icons.person_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextInput(
                textController: _emailController,
                keyboardType: TextInputType.emailAddress,
                title: 'Email',
                hintText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                validator: (value) => value.isEmpty ? AppLocalizations.current.feedbackEmailInvalid : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextInput(
          textController: _phoneController,
          title: AppLocalizations.current.feedbackPhone,
          hintText: AppLocalizations.current.feedbackPhone,
          prefixIcon: Icon(Icons.phone_outlined),
          keyboardType: TextInputType.phone,
          validator: (value) => value.isEmpty ? AppLocalizations.current.feedbackPhoneInvalid : null,
        ),
        const SizedBox(height: 16),
        // Tùy chọn
        _buildSectionTitle(AppLocalizations.current.feedbackOptions),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: Text(AppLocalizations.current.feedbackAnonymous),
          subtitle: Text(AppLocalizations.current.feedbackAnonymousDescription),
          value: _isAnonymous,
          onChanged: (value) {
            setState(() {
              _isAnonymous = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return CustomTextLabel(
      title,
      fontSize: AppDimens.SIZE_14,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.colorTitle,
    );
  }

  Widget _buildTypeSelector() {
    return CustomDropDown(
      hintText: AppLocalizations.current.feedbackType,
      listValues: FeedbackType.values.map((type) => type.displayName).toList(),
      selectedIndex: _selectedType.index,
      didSelected: (index) {
        setState(() {
          _selectedType = FeedbackType.values[index];
        });
      },
    );
  }

  Widget _buildPrioritySelector() {
    return CustomDropDown(
      hintText: AppLocalizations.current.feedbackPriority,
      listValues: FeedbackPriority.values.map((priority) => priority.displayName).toList(),
      selectedIndex: _selectedPriority.index,
      didSelected: (index) {
        setState(() {
          _selectedPriority = FeedbackPriority.values[index];
        });
      },
    );
  }

  Color _getPriorityColor(FeedbackPriority priority) {
    switch (priority) {
      case FeedbackPriority.low:
        return Colors.green;
      case FeedbackPriority.medium:
        return Colors.orange;
      case FeedbackPriority.high:
        return Colors.red;
      case FeedbackPriority.urgent:
        return Colors.purple;
    }
  }

  Widget _buildSubmitButton(BaseState state) {
    final theme = Theme.of(context);
    final isLoading = state is LoadingState;
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? SizedBox(
                width: AppDimens.SIZE_20,
                height: AppDimens.SIZE_20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                ),
              )
            : CustomTextLabel(
                AppLocalizations.current.feedbackSend,
                fontSize: AppDimens.SIZE_16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSecondary,
              ),
      ),
    );
  }
}
