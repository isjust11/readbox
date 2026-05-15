import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IconMapper {
  static IconData getIcon(String? iconName, String? iconType) {
    if (iconType?.toLowerCase() == 'lucide') {
      return _getLucideIcon(iconName);
    }

    // Default to Material Icons if type is material or not specified
    return _getMaterialIcon(iconName);
  }

  static IconData _getLucideIcon(String? iconName) {
    if (iconName == null) return LucideIcons.book;

    // Map common icon names.
    // Note: LucideIcons names in flutter are camelCase (e.g. bookOpen)
    switch (iconName) {
      case 'bookOpen':
        return LucideIcons.bookOpen;
      case 'library':
        return LucideIcons.library;
      case 'book':
        return LucideIcons.book;
      case 'bookmark':
        return LucideIcons.bookmark;
      case 'search':
        return LucideIcons.search;
      case 'settings':
        return LucideIcons.settings;
      case 'user':
        return LucideIcons.user;
      case 'home':
        return LucideIcons.house;
      case 'history':
        return LucideIcons.history;
      case 'star':
        return LucideIcons.star;
      case 'heart':
        return LucideIcons.heart;
      case 'info':
        return LucideIcons.info;
      case 'helpCircle':
        return LucideIcons.info;
      case 'flaskConical':
        return LucideIcons.flaskConical;
      case 'graduationCap':
        return LucideIcons.graduationCap;
      case 'palette':
        return LucideIcons.palette;
      case 'briefcase':
        return LucideIcons.briefcase;
      case 'cpu':
        return LucideIcons.cpu;
      case 'activity':
        return LucideIcons.activity;
      case 'utensils':
        return LucideIcons.utensils;
      case 'plane':
        return LucideIcons.plane;
      case 'baby':
        return LucideIcons.baby;
      default:
        // Try to handle case-insensitive or common variations if needed
        // but for now return default
        return LucideIcons.book;
    }
  }

  static IconData _getMaterialIcon(String? iconName) {
    if (iconName == null) return Icons.book_rounded;

    // Try to parse as hex code point if it starts with 0x
    if (iconName.startsWith('0x')) {
      try {
        final codePoint = int.parse(iconName.substring(2), radix: 16);
        return IconData(codePoint, fontFamily: 'MaterialIcons');
      } catch (_) {}
    }

    // Try to parse as integer
    final codePoint = int.tryParse(iconName);
    if (codePoint != null) {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }

    // Default Material icons mapping
    switch (iconName) {
      case 'book':
        return Icons.book_rounded;
      case 'person':
        return Icons.person_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}
