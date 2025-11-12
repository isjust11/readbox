import 'package:flutter/material.dart';

/// A collection of application-specific colors used throughout the app.
/// These colors are derived from the Figma design and converted to Flutter's Color format.
class AppColors {
  // define all your color
  static const Color baseColor = Color(0xFF0085FF);
  static const Color baseColorBorderTextField = Color(0xFFD6DCE2);
  static const Color gray = Color(0xFF75818F);
  static const Color focusBorder = Color(0xFF71ADE7);
  static const Color border = Color(0xFFD4CFCF);
  static const Color hintTextColor = Color(0xFFBDBDBD);
  static const Color ff828282 = Color(0xFF828282);
  static const Color disable = Color(0xffF0F4F9);
  static const Color colorTitle = Color(0xFF49494A);
  static const Color colorError = Color(0xFFE94235);

  static const LinearGradient baseColorGradient = LinearGradient(colors: [
    Color(0xFF258EFF),
    Color(0xFF0D49FF),
  ], begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, tileMode: TileMode.mirror);// define all your color

  // --- Primary / Accent Colors ---
  static const Color primaryBrand = Color(0xFFCD7957); // Thường dùng cho các nút, định danh sản phẩm (CD7957FF)
  static const Color secondaryBrand = Color(0xFF990500); // Thường dùng cho Bottom menu, text báo lỗi, thông tin quan trọng (990500FF)
  static const Color brandButtonVariant = Color(0xFFC67A58); // Biến thể của Brand Button (C67A58FF)
  static const Color successGreen = Color(0xFF0E631D); // Màu xanh lá cây cho trạng thái thành công/đã xác thực (0E631DFF)
  static const Color errorRed = Color(0xFFE21B14); // Màu đỏ cho lỗi (E21B14FF)

  // --- Grayscale / Neutral Colors ---
  static const Color white = Color(0xFFFFFFFF); // Màu trắng, rất phổ biến (FFFFFFFF)
  static const Color black = Color(0xFF000000); // Màu đen (000000FF)
  static const Color textDark = Color(0xFF333333); // Màu văn bản tối (333333FF)
  static const Color textLightGrey = Color(0xFF696969); // Màu văn bản xám nhạt (696969FF)
  static const Color textMediumGrey = Color(0xFF49525A); // Màu văn bản xám trung bình (49525AFF)
  static const Color textSubtleGrey = Color(0xFF576480); // Màu văn bản xám tinh tế (576480FF)
  static const Color textHintGrey = Color(0xFF6C757D); // Màu gợi ý/placeholder (6C757DFF)
  static const Color lightBackground = Color(0xFFF1F2F3); // Nền sáng (F1F2F3FF)
  static const Color lightBackgroundAlt = Color(0xFFE4E7EC); // Nền sáng thay thế (E4E7ECFF)
  static const Color cardBackground = Color(0xFFFAF1ED); // Nền thẻ (FAF1EDFF)
  static const Color dividerGrey = Color(0xFF979797); // Màu đường phân cách (979797FF)
  static const Color disabledGrey = Color(0xFFA5ABB1); // Màu xám cho trạng thái vô hiệu hóa (A5ABB1FF)
  static const Color darkGreyBackground = Color(0xFF404040); // Nền xám đậm (404040FF)
  static const Color lightGreyBackground = Color(0xFFE8E8E8); // Nền xám nhạt (E8E8E8FF)
  static const Color statusBarDark = Color(0xFF1E1E1E); // Màu thanh trạng thái tối (1E1E1EFF)
  static const Color statusBarLightText = Color(0xFFF0F1F5); // Màu chữ thanh trạng thái sáng (F0F1F5FF)
  static const Color darkBlueText = Color(0xFF222B45); // Màu chữ xanh đậm (222B45FF)
  static const Color secondaryTextDark = Color(0xFF2F2F2F); // Màu chữ phụ tối (2F2F2FFF)
  static const Color primaryBlue = Color(0xFF1967D2); // Màu xanh dương chính (1967D2FF)
  static const Color statusIndicatorBackground = Color(0xFFFDF5E8); // Màu nền cho chỉ báo trạng thái (FDF5E8FF)
  static const Color textVeryDark = Color(0xFF0A0C0F); // Màu chữ rất tối (0A0C0FFF)
  static const Color statusTextLight = Color(0xFF70809E); // Màu chữ trạng thái sáng (70809EFF)
  static const Color transparentBlackOverlay = Color(0x80000000); // Lớp phủ đen trong suốt (00000080)
  static const Color lightDividingLine = Color(0xFFD9D9D9); // Đường phân chia nhạt (D9D9D9FF)
  static const Color inputBorderLight = Color(0xFFC8CEDA); // Viền input nhạt (C8CEDAFF)
  static const Color inputBorderLight2 = Color(0xFFC3C7CB); // Viền input nhạt thứ 2 (C3C7CBFF)
  static const Color orangeDot = Color(0xFFF69000); // Chấm tròn màu cam (F69000FF)
  static const Color lightOrangeDot = Color(0xFFFFD294); // Chấm tròn màu cam nhạt (FFD294FF)
  static const Color transparentOrangeOverlay = Color(0x24DA9B81); // Lớp phủ cam trong suốt (DA9B8124)
  static const Color veryDarkBlue = Color(0xFF14132A); // Màu xanh dương rất tối (14132AFF)

  // --- Text Colors (specific to content) ---
  static const Color copyrightText = Color(0xFF000000); // Màu đen cho nội dung bản quyền

// Add more specific colors if needed, based on their contextual usage in Figma.
}
