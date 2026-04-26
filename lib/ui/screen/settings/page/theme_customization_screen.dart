import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/theme_cubit.dart';
import 'package:readbox/blocs/theme_state.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';

import 'package:readbox/ui/widget/base_screen.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class ThemeCustomizationScreen extends StatelessWidget {
  const ThemeCustomizationScreen({super.key});

  final List<Color> _availableColors = const [
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.pink,
  ];

  final List<String> _backgroundTypes = const [
    'default',
    'pattern_1',
    'pattern_2',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseScreen(
      title: AppLocalizations.current.theme, // Hoặc "Tuỳ chỉnh giao diện"
      body: BlocBuilder<ThemeCubit, AppThemeState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.SIZE_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  context,
                  AppLocalizations.current.primaryColor,
                ),
                const SizedBox(height: AppDimens.SIZE_16),
                _buildColorPalette(context, state),
                const SizedBox(height: AppDimens.SIZE_32),

                _buildSectionTitle(
                  context,
                  AppLocalizations.current.textFontSize,
                ),
                const SizedBox(height: AppDimens.SIZE_8),
                _buildFontSizeSlider(context, state),
                const SizedBox(height: AppDimens.SIZE_32),

                _buildSectionTitle(
                  context,
                  AppLocalizations.current.background,
                ),
                const SizedBox(height: AppDimens.SIZE_16),
                _buildBackgroundSelector(context, state),

                const SizedBox(height: AppDimens.SIZE_40),

                // Nút reset
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      context.read<ThemeCubit>().updateThemeState(
                        const AppThemeState(),
                      );
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Khôi phục mặc định'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return CustomTextLabel(
      title,
      fontSize: AppDimens.SIZE_18,
      fontWeight: FontWeight.bold,
      color:
          Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.colorTitle,
    );
  }

  Widget _buildColorPalette(BuildContext context, AppThemeState state) {
    return Wrap(
      spacing: AppDimens.SIZE_16,
      runSpacing: AppDimens.SIZE_16,
      children:
          _availableColors.map((color) {
            final isSelected = state.primaryColorValue == color.value;
            return GestureDetector(
              onTap: () {
                context.read<ThemeCubit>().updateThemeState(
                  state.copyWith(primaryColorValue: color.value),
                );
              },
              child: Container(
                width: AppDimens.SIZE_48,
                height: AppDimens.SIZE_48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildFontSizeSlider(BuildContext context, AppThemeState state) {
    return Column(
      children: [
        Row(
          children: [
            const CustomTextLabel('A-', fontSize: 14),
            Expanded(
              child: Slider(
                value: state.textScaleFactor,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                label: state.textScaleFactor.toStringAsFixed(1),
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  context.read<ThemeCubit>().updateThemeState(
                    state.copyWith(textScaleFactor: value),
                  );
                },
              ),
            ),
            const CustomTextLabel(
              'A+',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackgroundSelector(BuildContext context, AppThemeState state) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _backgroundTypes.length,
        itemBuilder: (context, index) {
          final bgType = _backgroundTypes[index];
          final isSelected = state.backgroundType == bgType;
          return GestureDetector(
            onTap: () {
              context.read<ThemeCubit>().updateThemeState(
                state.copyWith(backgroundType: bgType),
              );
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: AppDimens.SIZE_16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withValues(alpha: 0.3),
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.SIZE_10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Placeholder for actual background representation
                    Container(
                      decoration: BoxDecoration(
                        color:
                            bgType == 'default'
                                ? Colors.white
                                : Colors.transparent,
                        image:
                            bgType == 'default'
                                ? null
                                : DecorationImage(
                                  image: AssetImage(
                                    bgType == 'pattern_1'
                                        ? Assets.images.mainbgLight.path
                                        : Assets.images.mainbgStyle2.path,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                      ),
                      child: Center(
                        child: CustomTextLabel(
                          bgType == 'default'
                              ? AppLocalizations.current.default_bg
                              : bgType == 'pattern_1'
                              ? AppLocalizations.current.pattern_1_bg
                              : AppLocalizations.current.pattern_2_bg,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
