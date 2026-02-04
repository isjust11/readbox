import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/injection_container.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => getIt.get<AuthCubit>()),
        BlocProvider<MediaCubit>(create: (_) => getIt.get<MediaCubit>()),
      ],
      child: const UpdateProfileBody(),
    );
  }
}

class UpdateProfileBody extends StatefulWidget {
  const UpdateProfileBody({super.key});

  @override
  State<UpdateProfileBody> createState() => _UpdateProfileBodyState();
}

class _UpdateProfileBodyState extends State<UpdateProfileBody> {
  @override
  void didUpdateWidget(UpdateProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _formKey.currentState?.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _facebookLinkController = TextEditingController();
  final _instagramLinkController = TextEditingController();
  final _twitterLinkController = TextEditingController();
  final _linkedinLinkController = TextEditingController();
  // validator
  final GlobalKey<TextFieldState> _fullNameFieldKey =
      GlobalKey<TextFieldState>();
  final GlobalKey<TextFieldState> _emailFieldKey = GlobalKey<TextFieldState>();
  final GlobalKey<TextFieldState> _phoneNumberFieldKey =
      GlobalKey<TextFieldState>();
  final GlobalKey<TextFieldState> _addressFieldKey =
      GlobalKey<TextFieldState>();
  final GlobalKey<TextFieldState> _birthDateFieldKey =
      GlobalKey<TextFieldState>();
  final GlobalKey<TextFieldState> _facebookLinkFieldKey =
      GlobalKey<TextFieldState>();
  final GlobalKey<TextFieldState> _instagramLinkFieldKey =
      GlobalKey<TextFieldState>();
  final GlobalKey<TextFieldState> _twitterLinkFieldKey =
      GlobalKey<TextFieldState>();
  final GlobalKey<TextFieldState> _linkedinLinkFieldKey =
      GlobalKey<TextFieldState>();
  File? _selectedImage;
  String? _currentAvatarUrl;
  String? _pathRelativeAvatar;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final authCubit = context.read<AuthCubit>();
    authCubit.getProfile();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _fullNameFieldKey.currentState?.dispose();
    _emailFieldKey.currentState?.dispose();
    _phoneNumberController.dispose();
    _phoneNumberFieldKey.currentState?.dispose();
    _addressFieldKey.currentState?.dispose();
    _birthDateFieldKey.currentState?.dispose();
    _facebookLinkFieldKey.currentState?.dispose();
    _instagramLinkFieldKey.currentState?.dispose();
    _twitterLinkFieldKey.currentState?.dispose();
    _linkedinLinkFieldKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseScreen(
      title: AppLocalizations.current.updateYourInfo,
      colorBg: theme.colorScheme.surface,
      messageNotify: CustomSnackBar<AuthCubit>(),
      body: BlocListener<AuthCubit, BaseState>(
        listener: (context, state) {
          if (state is LoadedState) {
            if (state.data is UserModel) {
              final userModel = state.data as UserModel;
              _fullNameController.text = userModel.fullName ?? '';
              _emailController.text = userModel.email ?? '';
              _currentAvatarUrl =
                  userModel.isSocialPlatform
                      ? userModel.picture
                      : userModel.picture != null
                      ? ApiConstant.storageHost + (userModel.picture ?? '')
                      : null;
              _pathRelativeAvatar = userModel.picture ?? '';
              _phoneNumberController.text = userModel.phoneNumber ?? '';
              _addressController.text = userModel.address ?? '';
              _birthDateController.text = userModel.birthDate ?? '';
              _facebookLinkController.text = userModel.facebookLink ?? '';
              _instagramLinkController.text = userModel.instagramLink ?? '';
              _twitterLinkController.text = userModel.twitterLink ?? '';
              _linkedinLinkController.text = userModel.linkedinLink ?? '';
              setState(() {
                _isLoading = false;
              });
            }
          } else if (state is ErrorState) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.SIZE_16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: AppDimens.SIZE_16),
            _buildFormFields(),
            const SizedBox(height: AppDimens.SIZE_32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
      ),
      padding: const EdgeInsets.all(AppDimens.SIZE_16),
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              Assets.images.checkeredPattern,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _showImagePicker,
                      child: Container(
                        width: AppDimens.SIZE_100,
                        height: AppDimens.SIZE_100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.primaryColor,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              _selectedImage != null
                                  ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                  : _currentAvatarUrl != null &&
                                      _currentAvatarUrl!.isNotEmpty ?
                                  CachedNetworkImage(
                                    imageUrl: _currentAvatarUrl!,
                                    fit: BoxFit.cover,
                                  )
                                  : _buildDefaultAvatar(),
                        ),
                      ),
                    ),
                    Positioned(
                      right: AppDimens.SIZE_16,
                      bottom: 0,
                      child: Container(
                        width: AppDimens.SIZE_20,
                        height: AppDimens.SIZE_20,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            AppDimens.SIZE_10,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: theme.primaryColor,
                          size: AppDimens.SIZE_16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
      child: Container(
        margin: const EdgeInsets.all(AppDimens.SIZE_4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person,
          size: AppDimens.SIZE_60,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextLabel.renderBaseTitle(
          context,
          title: AppLocalizations.current.full_name,
          isRequired: true,
        ),
        CustomTextInput(
          key: _fullNameFieldKey,
          textController: _fullNameController,
          hintText: AppLocalizations.current.please_enter_full_name,
          prefixIcon: Icon(
            Icons.person_outline,
            color: AppColors.textMediumGrey,
          ),
          validator: (value) {
            if (value.trim().isEmpty) {
              return AppLocalizations.current.please_enter_full_name;
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimens.SIZE_16),
        CustomTextLabel.renderBaseTitle(
          context,
          title: AppLocalizations.current.email,
          isRequired: false,
        ),
        CustomTextInput(
          key: _emailFieldKey,
          textController: _emailController,
          hintText: AppLocalizations.current.please_enter_email,
          keyboardType: TextInputType.emailAddress,
          borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
          enabled: false,
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppColors.textMediumGrey,
          ),
          validator: (value) {
            if (value.trim().isEmpty) {
              return AppLocalizations.current.please_enter_email;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return AppLocalizations.current.please_enter_valid_email;
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimens.SIZE_16),
        CustomTextLabel.renderBaseTitle(
          context,
          title: AppLocalizations.current.phone_number,
          isRequired: false,
        ),
        CustomTextInput(
          key: _phoneNumberFieldKey,
          textController: _phoneNumberController,
          hintText: AppLocalizations.current.please_enter_phone_number,
          isRequired: false,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value.trim().isNotEmpty) {
              if (!RegExp(r'^[0-9-+]{10}$').hasMatch(value)) {
                return AppLocalizations.current.please_enter_valid_phone_number;
              }
            }
            return null;
          },
          prefixIcon: Icon(
            Icons.phone_outlined,
            color: AppColors.textMediumGrey,
          ),
        ),
        const SizedBox(height: AppDimens.SIZE_16),
        CustomTextLabel.renderBaseTitle(
          context,
          title: AppLocalizations.current.address,
          isRequired: false,
        ),
        CustomTextInput(
          key: _addressFieldKey,
          textController: _addressController,
          hintText: AppLocalizations.current.please_enter_valid_address,
          isRequired: false,
          keyboardType: TextInputType.streetAddress,
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: AppColors.textMediumGrey,
          ),
        ),
        const SizedBox(height: AppDimens.SIZE_16),
        CustomTextLabel.renderBaseTitle(
          context,
          title: AppLocalizations.current.birth_date,
          isRequired: false,
        ),
        CustomTextInput(
          key: _birthDateFieldKey,
          textController: _birthDateController,
          hintText: AppLocalizations.current.please_enter_valid_birth_date,
          isRequired: false,
          keyboardType: TextInputType.datetime,
          validator: (value) {
            if (value.trim().isNotEmpty &&
                DateFormat('dd/MM/yyyy').tryParse(value.trim()) == null) {
              return AppLocalizations.current.please_enter_valid_birth_date;
            }
            return null;
          },
          prefixIcon: Icon(
            Icons.date_range_outlined,
            color: AppColors.textMediumGrey,
          ),
        ),
        const SizedBox(height: AppDimens.SIZE_16),
        CustomTextLabel.renderBaseTitle(
          context,
          title: AppLocalizations.current.facebook_link,
          isRequired: false,
        ),
        CustomTextInput(
          key: _facebookLinkFieldKey,
          textController: _facebookLinkController,
          hintText: AppLocalizations.current.please_enter_facebook_link,
          isRequired: false,
          keyboardType: TextInputType.url,
          prefixIcon: Icon(
            Icons.facebook_rounded,
            color: AppColors.textMediumGrey,
          ),
        ),
        const SizedBox(height: AppDimens.SIZE_16),
        CustomTextLabel.renderBaseTitle(
          context,
          title: AppLocalizations.current.instagram_link,
          isRequired: false,
        ),
        CustomTextInput(
          key: _instagramLinkFieldKey,
          textController: _instagramLinkController,
          hintText: AppLocalizations.current.please_enter_instagram_link,
          isRequired: false,
          keyboardType: TextInputType.url,
          prefixIcon: Icon(
            Icons.ac_unit_outlined,
            color: AppColors.textMediumGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    return BaseButton(
      title:
          _isLoading
              ? AppLocalizations.current.saving
              : AppLocalizations.current.save,
      onTap: _isLoading ? null : _saveProfile,
      backgroundColor:
          _isLoading
              ? theme.colorScheme.outline.withValues(alpha: 0.5)
              : theme.primaryColor,
      width: double.infinity,
    );
  }

  bool _validateForm() {
    if (_fullNameFieldKey.currentState!.isValid) {
      return _fullNameFieldKey.currentState!.isValid;
    }
    if (_emailFieldKey.currentState!.isValid) {
      return _emailFieldKey.currentState!.isValid;
    }
    if (_phoneNumberFieldKey.currentState!.isValid) {
      return _phoneNumberFieldKey.currentState!.isValid;
    }
    if (_addressFieldKey.currentState!.isValid) {
      return _addressFieldKey.currentState!.isValid;
    }
    if (_birthDateFieldKey.currentState!.isValid) {
      return _birthDateFieldKey.currentState!.isValid;
    }
    if (_facebookLinkFieldKey.currentState!.isValid) {
      return _facebookLinkFieldKey.currentState!.isValid;
    }
    if (_instagramLinkFieldKey.currentState!.isValid) {
      return _instagramLinkFieldKey.currentState!.isValid;
    }
    if (_twitterLinkFieldKey.currentState!.isValid) {
      return _twitterLinkFieldKey.currentState!.isValid;
    }
    if (_linkedinLinkFieldKey.currentState!.isValid) {
      return _linkedinLinkFieldKey.currentState!.isValid;
    }
    return true;
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: CustomTextLabel(AppLocalizations.current.camera),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: CustomTextLabel(AppLocalizations.current.gallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: CustomTextLabel(AppLocalizations.current.cancel),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      // Handle permission denied or other errors
      String errorMessage =
          AppLocalizations.current.cannot_select_image_message;
      if (e.toString().contains('permission')) {
        errorMessage =
            AppLocalizations
                .current
                .please_grant_permission_to_access_camera_or_gallery_in_settings;
      } else if (e.toString().contains('camera')) {
        errorMessage = AppLocalizations.current.cannot_access_camera;
      } else if (e.toString().contains('no_available_camera')) {
        errorMessage = AppLocalizations.current.no_available_camera;
      }

      if (mounted) {
        AppSnackBar.show(
          context,
          message: errorMessage,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    final authCubit = context.read<AuthCubit>();
    final mediaCubit = context.read<MediaCubit>();
    // Convert image to base64 if selected
    String? urlPicture;
    if (_selectedImage != null) {
      urlPicture = null;
    } else {
      urlPicture = _pathRelativeAvatar;
    }

    // upload image to server
    if (_selectedImage != null) {
      final media = await mediaCubit.uploadMedia(_selectedImage!);
      urlPicture = media.publicRelativePath;
    }
    final userModel = UserModel.simpleFromJson({
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'picture': urlPicture,
      'address': _addressController.text.trim(),
      'birthDate': _birthDateController.text.trim(),
      'facebookLink': _facebookLinkController.text.trim(),
      'instagramLink': _instagramLinkController.text.trim(),
      'twitterLink': _twitterLinkController.text.trim(),
      'linkedinLink': _linkedinLinkController.text.trim(),
    });
    await authCubit.updateProfile(userModel: userModel);
    // Listen for success
    Navigator.of(context).pop();
  }
}
