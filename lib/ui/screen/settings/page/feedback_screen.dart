import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/ui/widget/base_appbar.dart';
import 'package:readbox/ui/widget/base_screen.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:readbox/ui/widget/custom_text_label.dart';
import 'package:readbox/injection_container.dart';


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
          return BaseScreen(
            customAppBar: _buildAppBar(context),
            title: AppLocalizations.current.sendFeedback,
            colorTitle: AppColors.white,
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  BaseAppBar _buildAppBar(BuildContext context) {
    return BaseAppBar(
      title: AppLocalizations.current.feedbackContact,
      showBackButton: true,
      onBackTap: () => Navigator.pop(context),
    );
  }

  Widget _buildBody(BuildContext context, BaseState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
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
          color: AppColors.gray,
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
        _buildSectionTitle(AppLocalizations.current.feedbackTitle),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: AppLocalizations.current.feedbackTitle,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.current.feedbackTitleRequired;
            }
            if (value.trim().length < 5) {
              return AppLocalizations.current.feedbackTitleMinLength;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Nội dung
        _buildSectionTitle(AppLocalizations.current.feedbackContent),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: AppLocalizations.current.feedbackContent,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.description),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.current.feedbackContentRequired;
            }
            if (value.trim().length < 10) {
              return AppLocalizations.current.feedbackContentMinLength;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Thông tin liên hệ
        _buildSectionTitle(AppLocalizations.current.feedbackContact),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.current.feedbackName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return AppLocalizations.current.feedbackEmailInvalid;
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: AppLocalizations.current.feedbackPhone,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.phone),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (value.length < 10) {
                return AppLocalizations.current.feedbackPhoneInvalid;
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 8),

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
      color: AppColors.gray,
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FeedbackType>(
          value: _selectedType,
          isExpanded: true,
          items: FeedbackType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: CustomTextLabel(
                type.displayName,
                fontSize: AppDimens.SIZE_14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FeedbackPriority>(
          value: _selectedPriority,
          isExpanded: true,
          items: FeedbackPriority.values.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(priority.displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPriority = value;
              });
            }
          },
        ),
      ),
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
    final isLoading = state is LoadingState;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? SizedBox(
                width: AppDimens.SIZE_20,
                height: AppDimens.SIZE_20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : CustomTextLabel(
                AppLocalizations.current.feedbackSend,
                fontSize: AppDimens.SIZE_16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
      ),
    );
  }
}
