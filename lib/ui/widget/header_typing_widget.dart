import 'dart:async';

import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';

class HeaderTypingWidget extends StatefulWidget {
  const HeaderTypingWidget({super.key});

  @override
  State<HeaderTypingWidget> createState() => _HeaderTypingWidgetState();
}

class _HeaderTypingWidgetState extends State<HeaderTypingWidget> {
  final String _typewriterFullText = "Tìm kiếm";
  final String _typewriterDescription = "Tìm kiếm";
  late final List<String> _typewriterMessages = [
    _typewriterFullText,
    _typewriterDescription,
  ];
  int _currentMessage = 0;
  int _typewriterIndex = 0;
  bool _typewriterDeleting = false;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  void _startTypewriter([
    Duration interval = const Duration(milliseconds: 100),
  ]) {
    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(interval, (timer) {
      if (!mounted) return;
      if (!_typewriterDeleting) {
        if (_typewriterIndex < _typewriterMessages[_currentMessage].length) {
          setState(() {
            _typewriterIndex++;
          });
        } else {
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 900), () {
            if (!mounted) return;
            setState(() {
              _typewriterDeleting = true;
            });
            _startTypewriter(const Duration(milliseconds: 40));
          });
        }
      } else {
        if (_typewriterIndex > 0) {
          setState(() {
            _typewriterIndex--;
          });
        } else {
          timer.cancel();
          setState(() {
            _typewriterDeleting = false;
            _currentMessage =
                (_currentMessage + 1) % _typewriterMessages.length;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            _startTypewriter();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, Routes.search);
          },
          child: Container(
            width: double.infinity,
            height: AppDimens.SIZE_48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.SIZE_12,
                vertical: AppDimens.SIZE_8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.SIZE_12,
                        vertical: AppDimens.SIZE_10,
                      ),
                      child: CustomTextLabel(
                        _typewriterIndex == 0
                            ? ' '
                            : _typewriterMessages[_currentMessage].substring(
                                0,
                                _typewriterIndex,
                              ),
                        color: AppColors.primaryBlue,
                        fontSize: AppDimens.SIZE_12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color: AppColors.primaryBlue,
                    size: AppDimens.SIZE_18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
