// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(
      _current != null,
      'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `VNPT flutter_template`
  String get appName {
    return Intl.message(
      'VNPT flutter_template',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Đã có lỗi xảy ra. Vui lòng thử lại sau`
  String get error_common {
    return Intl.message(
      'Đã có lỗi xảy ra. Vui lòng thử lại sau',
      name: 'error_common',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi kết nối mạng`
  String get error_connection {
    return Intl.message(
      'Lỗi kết nối mạng',
      name: 'error_connection',
      desc: '',
      args: [],
    );
  }

  /// `Đang lấy dữ liệu ...`
  String get dropdown_loading {
    return Intl.message(
      'Đang lấy dữ liệu ...',
      name: 'dropdown_loading',
      desc: '',
      args: [],
    );
  }

  /// `Nhập tên đăng nhập`
  String get inputUserName {
    return Intl.message(
      'Nhập tên đăng nhập',
      name: 'inputUserName',
      desc: '',
      args: [],
    );
  }

  /// `Tên đăng nhập`
  String get userName {
    return Intl.message('Tên đăng nhập', name: 'userName', desc: '', args: []);
  }

  /// `Vui lòng nhập tên đăng nhập`
  String get plsInputUserName {
    return Intl.message(
      'Vui lòng nhập tên đăng nhập',
      name: 'plsInputUserName',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập`
  String get login {
    return Intl.message('Đăng nhập', name: 'login', desc: '', args: []);
  }

  /// `Phiên làm việc đã hệt hạn. Vui lòng đăng nhập lại`
  String get tokenExpiredMessage {
    return Intl.message(
      'Phiên làm việc đã hệt hạn. Vui lòng đăng nhập lại',
      name: 'tokenExpiredMessage',
      desc: '',
      args: [],
    );
  }

  /// `Đổi ngôn ngữ`
  String get changeLanguage {
    return Intl.message(
      'Đổi ngôn ngữ',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Đồng ý`
  String get agree {
    return Intl.message('Đồng ý', name: 'agree', desc: '', args: []);
  }

  /// `Xong`
  String get done {
    return Intl.message('Xong', name: 'done', desc: '', args: []);
  }

  /// `Bỏ qua`
  String get skip {
    return Intl.message('Bỏ qua', name: 'skip', desc: '', args: []);
  }

  /// `Xác thực uy tín`
  String get authenticateTrust {
    return Intl.message(
      'Xác thực uy tín',
      name: 'authenticateTrust',
      desc: '',
      args: [],
    );
  }

  /// `Tin cậy toàn cầu`
  String get globalTrust {
    return Intl.message(
      'Tin cậy toàn cầu',
      name: 'globalTrust',
      desc: '',
      args: [],
    );
  }

  /// `Truy xuất chuỗi cung ứng`
  String get supplyChainTraceability {
    return Intl.message(
      'Truy xuất chuỗi cung ứng',
      name: 'supplyChainTraceability',
      desc: '',
      args: [],
    );
  }

  /// `Định danh hàng hóa`
  String get productIdentification {
    return Intl.message(
      'Định danh hàng hóa',
      name: 'productIdentification',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập bằng tài khoản Định danh điện tử cấp bởi Bộ Công an dành cho Công dân`
  String get loginWithPublicSecurityAccount {
    return Intl.message(
      'Đăng nhập bằng tài khoản Định danh điện tử cấp bởi Bộ Công an dành cho Công dân',
      name: 'loginWithPublicSecurityAccount',
      desc: '',
      args: [],
    );
  }

  /// `Xin chào`
  String get hello {
    return Intl.message('Xin chào', name: 'hello', desc: '', args: []);
  }

  /// `Trang chủ`
  String get home {
    return Intl.message('Trang chủ', name: 'home', desc: '', args: []);
  }

  /// `Lịch sử`
  String get history {
    return Intl.message('Lịch sử', name: 'history', desc: '', args: []);
  }

  /// `Bán hàng`
  String get sales {
    return Intl.message('Bán hàng', name: 'sales', desc: '', args: []);
  }

  /// `Khiếu nại`
  String get complaint {
    return Intl.message('Khiếu nại', name: 'complaint', desc: '', args: []);
  }

  /// `Cài đặt`
  String get settings {
    return Intl.message('Cài đặt', name: 'settings', desc: '', args: []);
  }

  /// `Cảnh báo hàng giả`
  String get fakeProductWarning {
    return Intl.message(
      'Cảnh báo hàng giả',
      name: 'fakeProductWarning',
      desc: '',
      args: [],
    );
  }

  /// `Tin tức`
  String get news {
    return Intl.message('Tin tức', name: 'news', desc: '', args: []);
  }

  /// `Thực phẩm bổ sung colos IQ`
  String get colosIQSupplement {
    return Intl.message(
      'Thực phẩm bổ sung colos IQ',
      name: 'colosIQSupplement',
      desc: '',
      args: [],
    );
  }

  /// `Xem thêm`
  String get viewMore {
    return Intl.message('Xem thêm', name: 'viewMore', desc: '', args: []);
  }

  /// `Ảnh`
  String get photo {
    return Intl.message('Ảnh', name: 'photo', desc: '', args: []);
  }

  /// `Quét mã`
  String get scanCode {
    return Intl.message('Quét mã', name: 'scanCode', desc: '', args: []);
  }

  /// `Danh sách nguyên liệu`
  String get ingredientsList {
    return Intl.message(
      'Danh sách nguyên liệu',
      name: 'ingredientsList',
      desc: '',
      args: [],
    );
  }

  /// `Được làm hoàn toàn từ sữa tươi trang trại, sạch, nguyên chất theo chuẩn của trang trại TH. Giảm 26,3% lượng đường bổ sung (so với Sữa Tươi Tiệt Trùng có đường) phù hợp xu hướng lành mạnh giảm đường, dễ uống phù hợp cả gia đình và trẻ nhỏ.`
  String get productDescription {
    return Intl.message(
      'Được làm hoàn toàn từ sữa tươi trang trại, sạch, nguyên chất theo chuẩn của trang trại TH. Giảm 26,3% lượng đường bổ sung (so với Sữa Tươi Tiệt Trùng có đường) phù hợp xu hướng lành mạnh giảm đường, dễ uống phù hợp cả gia đình và trẻ nhỏ.',
      name: 'productDescription',
      desc: '',
      args: [],
    );
  }

  /// `Hướng dẫn bảo quản: Bảo quản lạnh ở 2°C - 6°C.`
  String get storageInstructions {
    return Intl.message(
      'Hướng dẫn bảo quản: Bảo quản lạnh ở 2°C - 6°C.',
      name: 'storageInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Hạn sử dụng: 39 ngày kể từ ngày sản xuất.`
  String get shelfLife {
    return Intl.message(
      'Hạn sử dụng: 39 ngày kể từ ngày sản xuất.',
      name: 'shelfLife',
      desc: '',
      args: [],
    );
  }

  /// `Sản phẩm phù hợp cho cả gia đình.`
  String get suitableForFamily {
    return Intl.message(
      'Sản phẩm phù hợp cho cả gia đình.',
      name: 'suitableForFamily',
      desc: '',
      args: [],
    );
  }

  /// `Sử dụng hết trong 24 giờ sau khi mở.`
  String get useWithin24Hours {
    return Intl.message(
      'Sử dụng hết trong 24 giờ sau khi mở.',
      name: 'useWithin24Hours',
      desc: '',
      args: [],
    );
  }

  /// `Thành phần dinh dưỡng trung bình trong 100 ml (*)`
  String get averageNutritionInfo {
    return Intl.message(
      'Thành phần dinh dưỡng trung bình trong 100 ml (*)',
      name: 'averageNutritionInfo',
      desc: '',
      args: [],
    );
  }

  /// `Thông tin dinh dưỡng`
  String get nutritionInformation {
    return Intl.message(
      'Thông tin dinh dưỡng',
      name: 'nutritionInformation',
      desc: '',
      args: [],
    );
  }

  /// `Năng lượng74,8 kcal`
  String get energy {
    return Intl.message(
      'Năng lượng74,8 kcal',
      name: 'energy',
      desc: '',
      args: [],
    );
  }

  /// `Chất đạm3,1 g`
  String get protein {
    return Intl.message('Chất đạm3,1 g', name: 'protein', desc: '', args: []);
  }

  /// `Carbohydrat7,5 g`
  String get carbohydrates {
    return Intl.message(
      'Carbohydrat7,5 g',
      name: 'carbohydrates',
      desc: '',
      args: [],
    );
  }

  /// `Đường tổng số7,5 g`
  String get totalSugar {
    return Intl.message(
      'Đường tổng số7,5 g',
      name: 'totalSugar',
      desc: '',
      args: [],
    );
  }

  /// `Chất béo3,6 g`
  String get fat {
    return Intl.message('Chất béo3,6 g', name: 'fat', desc: '', args: []);
  }

  /// `Natri33 mg`
  String get sodium {
    return Intl.message('Natri33 mg', name: 'sodium', desc: '', args: []);
  }

  /// `Calci102 mg`
  String get calcium {
    return Intl.message('Calci102 mg', name: 'calcium', desc: '', args: []);
  }

  /// `Các vitamin và khoáng chất có sẵn trong sữa tươi`
  String get vitaminsAndMinerals {
    return Intl.message(
      'Các vitamin và khoáng chất có sẵn trong sữa tươi',
      name: 'vitaminsAndMinerals',
      desc: '',
      args: [],
    );
  }

  /// `(*) Hàm lượng dinh dưỡng không thấp hơn 80% giá trị ghi trên nhãn​​.`
  String get nutritionDisclaimer {
    return Intl.message(
      '(*) Hàm lượng dinh dưỡng không thấp hơn 80% giá trị ghi trên nhãn​​.',
      name: 'nutritionDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Công ty cổ phần sữa TH true milk`
  String get thTrueMilkCompany {
    return Intl.message(
      'Công ty cổ phần sữa TH true milk',
      name: 'thTrueMilkCompany',
      desc: '',
      args: [],
    );
  }

  /// `Nước sản xuất`
  String get countryOfManufacture {
    return Intl.message(
      'Nước sản xuất',
      name: 'countryOfManufacture',
      desc: '',
      args: [],
    );
  }

  /// `Việt Nam`
  String get vietnam {
    return Intl.message('Việt Nam', name: 'vietnam', desc: '', args: []);
  }

  /// `Loại hàng hóa`
  String get commodityType {
    return Intl.message(
      'Loại hàng hóa',
      name: 'commodityType',
      desc: '',
      args: [],
    );
  }

  /// `Sữa`
  String get milk {
    return Intl.message('Sữa', name: 'milk', desc: '', args: []);
  }

  /// `Loại`
  String get type {
    return Intl.message('Loại', name: 'type', desc: '', args: []);
  }

  /// `Dung dịch`
  String get liquid {
    return Intl.message('Dung dịch', name: 'liquid', desc: '', args: []);
  }

  /// `Cách đóng gói`
  String get packagingMethod {
    return Intl.message(
      'Cách đóng gói',
      name: 'packagingMethod',
      desc: '',
      args: [],
    );
  }

  /// `Hộp 1 lít`
  String get oneLiterBox {
    return Intl.message('Hộp 1 lít', name: 'oneLiterBox', desc: '', args: []);
  }

  /// `NSX - HSD`
  String get mfgExpDate {
    return Intl.message('NSX - HSD', name: 'mfgExpDate', desc: '', args: []);
  }

  /// `Sữa tươi nguyên chất TH không đường - dung tích 1L`
  String get thMilkNoSugar {
    return Intl.message(
      'Sữa tươi nguyên chất TH không đường - dung tích 1L',
      name: 'thMilkNoSugar',
      desc: '',
      args: [],
    );
  }

  /// `Sản phẩm đã định danh`
  String get productIdentified {
    return Intl.message(
      'Sản phẩm đã định danh',
      name: 'productIdentified',
      desc: '',
      args: [],
    );
  }

  /// `Sản phẩm đã được chứng thực`
  String get productAuthenticated {
    return Intl.message(
      'Sản phẩm đã được chứng thực',
      name: 'productAuthenticated',
      desc: '',
      args: [],
    );
  }

  /// `Thông tin do tổ chức sử dụng mã số, mã vạch tự kê khai và tự chịu trách nhiệm`
  String get infoSelfDeclaredByOrganization {
    return Intl.message(
      'Thông tin do tổ chức sử dụng mã số, mã vạch tự kê khai và tự chịu trách nhiệm',
      name: 'infoSelfDeclaredByOrganization',
      desc: '',
      args: [],
    );
  }

  /// `Nghi ngờ hàng giả hoặc lỗi in tem`
  String get suspectCounterfeitOrPrintError {
    return Intl.message(
      'Nghi ngờ hàng giả hoặc lỗi in tem',
      name: 'suspectCounterfeitOrPrintError',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng chụp ảnh để hệ thống xác minh!`
  String get pleaseTakePhotoForVerification {
    return Intl.message(
      'Vui lòng chụp ảnh để hệ thống xác minh!',
      name: 'pleaseTakePhotoForVerification',
      desc: '',
      args: [],
    );
  }

  /// `Không có thông tin nhà sản xuất`
  String get noManufacturerInfo {
    return Intl.message(
      'Không có thông tin nhà sản xuất',
      name: 'noManufacturerInfo',
      desc: '',
      args: [],
    );
  }

  /// `Không có thông tin sản phẩm`
  String get noProductInfo {
    return Intl.message(
      'Không có thông tin sản phẩm',
      name: 'noProductInfo',
      desc: '',
      args: [],
    );
  }

  /// `Phản ánh - Khiếu nại`
  String get complaintAndFeedback {
    return Intl.message(
      'Phản ánh - Khiếu nại',
      name: 'complaintAndFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Kết quả`
  String get result {
    return Intl.message('Kết quả', name: 'result', desc: '', args: []);
  }

  /// `Đóng`
  String get close {
    return Intl.message('Đóng', name: 'close', desc: '', args: []);
  }

  /// `Chia sẻ`
  String get share {
    return Intl.message('Chia sẻ', name: 'share', desc: '', args: []);
  }

  /// `Truy xuất nguồn gốc sản phầm`
  String get traceProductOrigin {
    return Intl.message(
      'Truy xuất nguồn gốc sản phầm',
      name: 'traceProductOrigin',
      desc: '',
      args: [],
    );
  }

  /// `Thông tin`
  String get information {
    return Intl.message('Thông tin', name: 'information', desc: '', args: []);
  }

  /// `Trang trại`
  String get farm {
    return Intl.message('Trang trại', name: 'farm', desc: '', args: []);
  }

  /// `Vận chuyển đến nhà máy`
  String get transportToFactory {
    return Intl.message(
      'Vận chuyển đến nhà máy',
      name: 'transportToFactory',
      desc: '',
      args: [],
    );
  }

  /// `Sản xuất`
  String get manufacture {
    return Intl.message('Sản xuất', name: 'manufacture', desc: '', args: []);
  }

  /// `Nhập kho`
  String get warehousing {
    return Intl.message('Nhập kho', name: 'warehousing', desc: '', args: []);
  }

  /// `Xuất bán`
  String get exportSales {
    return Intl.message('Xuất bán', name: 'exportSales', desc: '', args: []);
  }

  /// `Vận chuyển`
  String get transport {
    return Intl.message('Vận chuyển', name: 'transport', desc: '', args: []);
  }

  /// `Cửa hàng bán lẻ`
  String get retailStore {
    return Intl.message(
      'Cửa hàng bán lẻ',
      name: 'retailStore',
      desc: '',
      args: [],
    );
  }

  /// `Loại hình`
  String get farmType {
    return Intl.message('Loại hình', name: 'farmType', desc: '', args: []);
  }

  /// `Trang trại bò sữa`
  String get dairyFarm {
    return Intl.message(
      'Trang trại bò sữa',
      name: 'dairyFarm',
      desc: '',
      args: [],
    );
  }

  /// `Tên trang trại`
  String get farmName {
    return Intl.message('Tên trang trại', name: 'farmName', desc: '', args: []);
  }

  /// `Cụm trang trại bò sữa số 2 - TH true milk`
  String get thTrueMilkFarmCluster2 {
    return Intl.message(
      'Cụm trang trại bò sữa số 2 - TH true milk',
      name: 'thTrueMilkFarmCluster2',
      desc: '',
      args: [],
    );
  }

  /// `Địa chỉ`
  String get address {
    return Intl.message('Địa chỉ', name: 'address', desc: '', args: []);
  }

  /// `Nghĩa Sơn - Nghĩa Đàn - Nghệ An`
  String get nghiaSonNgheAnAddress {
    return Intl.message(
      'Nghĩa Sơn - Nghĩa Đàn - Nghệ An',
      name: 'nghiaSonNgheAnAddress',
      desc: '',
      args: [],
    );
  }

  /// `Số điện thoại`
  String get phoneNumber {
    return Intl.message(
      'Số điện thoại',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Diện tích`
  String get farmArea {
    return Intl.message('Diện tích', name: 'farmArea', desc: '', args: []);
  }

  /// `Ngày vắt sữa`
  String get milkingDate {
    return Intl.message(
      'Ngày vắt sữa',
      name: 'milkingDate',
      desc: '',
      args: [],
    );
  }

  /// `Đạt chuẩn`
  String get datChuan {
    return Intl.message('Đạt chuẩn', name: 'datChuan', desc: '', args: []);
  }

  /// `Tiêu chuẩn hữu cơ Châu Âu`
  String get europeanOrganicStandard {
    return Intl.message(
      'Tiêu chuẩn hữu cơ Châu Âu',
      name: 'europeanOrganicStandard',
      desc: '',
      args: [],
    );
  }

  /// `Tiêu chuẩn hữu cơ Mỹ`
  String get usOrganicStandard {
    return Intl.message(
      'Tiêu chuẩn hữu cơ Mỹ',
      name: 'usOrganicStandard',
      desc: '',
      args: [],
    );
  }

  /// `Tiêu chuẩn hữu cơ Việt Nam`
  String get vietnamOrganicStandard {
    return Intl.message(
      'Tiêu chuẩn hữu cơ Việt Nam',
      name: 'vietnamOrganicStandard',
      desc: '',
      args: [],
    );
  }

  /// `Nguồn gốc thông tin đã được chứng thực`
  String get infoAuthenticatedSource {
    return Intl.message(
      'Nguồn gốc thông tin đã được chứng thực',
      name: 'infoAuthenticatedSource',
      desc: '',
      args: [],
    );
  }

  /// `Loại hình`
  String get factoryTransportType {
    return Intl.message(
      'Loại hình',
      name: 'factoryTransportType',
      desc: '',
      args: [],
    );
  }

  /// `Vận chuyển nhà máy`
  String get factoryTransport {
    return Intl.message(
      'Vận chuyển nhà máy',
      name: 'factoryTransport',
      desc: '',
      args: [],
    );
  }

  /// `Tuyến đường`
  String get route {
    return Intl.message('Tuyến đường', name: 'route', desc: '', args: []);
  }

  /// `Địa chỉ A- Địa chỉ B`
  String get addressAtoAddressB {
    return Intl.message(
      'Địa chỉ A- Địa chỉ B',
      name: 'addressAtoAddressB',
      desc: '',
      args: [],
    );
  }

  /// `Loại xe`
  String get vehicleType {
    return Intl.message('Loại xe', name: 'vehicleType', desc: '', args: []);
  }

  /// `Xe bồn lạnh`
  String get refrigeratedTanker {
    return Intl.message(
      'Xe bồn lạnh',
      name: 'refrigeratedTanker',
      desc: '',
      args: [],
    );
  }

  /// `Biển số xe`
  String get licensePlate {
    return Intl.message('Biển số xe', name: 'licensePlate', desc: '', args: []);
  }

  /// `Tiêu chuẩn xe bồn lạnh 2-4 độ C`
  String get refrigeratedTruckStandard {
    return Intl.message(
      'Tiêu chuẩn xe bồn lạnh 2-4 độ C',
      name: 'refrigeratedTruckStandard',
      desc: '',
      args: [],
    );
  }

  /// `Ngày vận chuyển`
  String get shippingDate {
    return Intl.message(
      'Ngày vận chuyển',
      name: 'shippingDate',
      desc: '',
      args: [],
    );
  }

  /// `Tên nhà máy`
  String get factoryName {
    return Intl.message('Tên nhà máy', name: 'factoryName', desc: '', args: []);
  }

  /// `Nhà máy sữa sạch TH true milk`
  String get thCleanMilkFactory {
    return Intl.message(
      'Nhà máy sữa sạch TH true milk',
      name: 'thCleanMilkFactory',
      desc: '',
      args: [],
    );
  }

  /// `Địa chỉ A`
  String get factoryAddressA {
    return Intl.message(
      'Địa chỉ A',
      name: 'factoryAddressA',
      desc: '',
      args: [],
    );
  }

  /// `Lô sản xuất`
  String get productionBatch {
    return Intl.message(
      'Lô sản xuất',
      name: 'productionBatch',
      desc: '',
      args: [],
    );
  }

  /// `Ngày sản xuất`
  String get productionDate {
    return Intl.message(
      'Ngày sản xuất',
      name: 'productionDate',
      desc: '',
      args: [],
    );
  }

  /// `Sản phẩm không có định danh`
  String get productUnidentified {
    return Intl.message(
      'Sản phẩm không có định danh',
      name: 'productUnidentified',
      desc: '',
      args: [],
    );
  }

  /// `Xoá`
  String get delete {
    return Intl.message('Xoá', name: 'delete', desc: '', args: []);
  }

  /// `Báo cáo`
  String get report {
    return Intl.message('Báo cáo', name: 'report', desc: '', args: []);
  }

  /// `Nội dung:`
  String get content {
    return Intl.message('Nội dung:', name: 'content', desc: '', args: []);
  }

  /// `Hình ảnh:`
  String get images {
    return Intl.message('Hình ảnh:', name: 'images', desc: '', args: []);
  }

  /// `Thời gian quét:`
  String get scanTime {
    return Intl.message(
      'Thời gian quét:',
      name: 'scanTime',
      desc: '',
      args: [],
    );
  }

  /// `Quay lại`
  String get back {
    return Intl.message('Quay lại', name: 'back', desc: '', args: []);
  }

  /// `Nhập nội dung phản ánh`
  String get enterComplaintContent {
    return Intl.message(
      'Nhập nội dung phản ánh',
      name: 'enterComplaintContent',
      desc: '',
      args: [],
    );
  }

  /// `Thêm ít nhất 1 hình ảnh hoặc video về sản phẩm`
  String get addImagesOrVideos {
    return Intl.message(
      'Thêm ít nhất 1 hình ảnh hoặc video về sản phẩm',
      name: 'addImagesOrVideos',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Video`
  String get video {
    return Intl.message('Video', name: 'video', desc: '', args: []);
  }

  /// `Gửi`
  String get send {
    return Intl.message('Gửi', name: 'send', desc: '', args: []);
  }

  /// `Loại vi phạm`
  String get violationType {
    return Intl.message(
      'Loại vi phạm',
      name: 'violationType',
      desc: '',
      args: [],
    );
  }

  /// `Chọn loại vi phạm`
  String get selectViolationType {
    return Intl.message(
      'Chọn loại vi phạm',
      name: 'selectViolationType',
      desc: '',
      args: [],
    );
  }

  /// `Lý do phản ánh`
  String get reasonForComplaint {
    return Intl.message(
      'Lý do phản ánh',
      name: 'reasonForComplaint',
      desc: '',
      args: [],
    );
  }

  /// `Chọn lý do phản ánh`
  String get selectReasonForComplaint {
    return Intl.message(
      'Chọn lý do phản ánh',
      name: 'selectReasonForComplaint',
      desc: '',
      args: [],
    );
  }

  /// `Nguồn gốc`
  String get origin {
    return Intl.message('Nguồn gốc', name: 'origin', desc: '', args: []);
  }

  /// `Lọc`
  String get filter {
    return Intl.message('Lọc', name: 'filter', desc: '', args: []);
  }

  /// `Danh sách khiếu nại của tôi`
  String get myComplaintList {
    return Intl.message(
      'Danh sách khiếu nại của tôi',
      name: 'myComplaintList',
      desc: '',
      args: [],
    );
  }

  /// `chất lượng sản phẩm có vấn đề`
  String get productQualityIssue {
    return Intl.message(
      'chất lượng sản phẩm có vấn đề',
      name: 'productQualityIssue',
      desc: '',
      args: [],
    );
  }

  /// `Sản phẩm này là hàng giả`
  String get productIsCounterfeit {
    return Intl.message(
      'Sản phẩm này là hàng giả',
      name: 'productIsCounterfeit',
      desc: '',
      args: [],
    );
  }

  /// `Phản ánh đã xử lý`
  String get handledComplaint {
    return Intl.message(
      'Phản ánh đã xử lý',
      name: 'handledComplaint',
      desc: '',
      args: [],
    );
  }

  /// `Phản hồi: Nhà sản xuất đã phản hồi về điều kiện bảo quản sản phẩm`
  String get manufacturerResponseStorage {
    return Intl.message(
      'Phản hồi: Nhà sản xuất đã phản hồi về điều kiện bảo quản sản phẩm',
      name: 'manufacturerResponseStorage',
      desc: '',
      args: [],
    );
  }

  /// `Phản hồi: Cảm ơn bạn đã phản ánh, chúng tôi đã thu hồi lô sản phẩm này!`
  String get manufacturerResponseRecall {
    return Intl.message(
      'Phản hồi: Cảm ơn bạn đã phản ánh, chúng tôi đã thu hồi lô sản phẩm này!',
      name: 'manufacturerResponseRecall',
      desc: '',
      args: [],
    );
  }

  /// `Chi tiết phản ánh - khiếu nại`
  String get complaintDetails {
    return Intl.message(
      'Chi tiết phản ánh - khiếu nại',
      name: 'complaintDetails',
      desc: '',
      args: [],
    );
  }

  /// `Loại vi phạm: hàng kém chất lượng`
  String get violationTypePoorQuality {
    return Intl.message(
      'Loại vi phạm: hàng kém chất lượng',
      name: 'violationTypePoorQuality',
      desc: '',
      args: [],
    );
  }

  /// `Lý do phản ánh: hàng kém chất lượng`
  String get reasonComplaintPoorQuality {
    return Intl.message(
      'Lý do phản ánh: hàng kém chất lượng',
      name: 'reasonComplaintPoorQuality',
      desc: '',
      args: [],
    );
  }

  /// `Đã xử lý`
  String get handled {
    return Intl.message('Đã xử lý', name: 'handled', desc: '', args: []);
  }

  /// `Chờ xử lý`
  String get pendingProcessing {
    return Intl.message(
      'Chờ xử lý',
      name: 'pendingProcessing',
      desc: '',
      args: [],
    );
  }

  /// `Thêm`
  String get add {
    return Intl.message('Thêm', name: 'add', desc: '', args: []);
  }

  /// `Nếu bạn có thêm thắc mắc gì, vui lòng liên hệ:`
  String get furtherInquiries {
    return Intl.message(
      'Nếu bạn có thêm thắc mắc gì, vui lòng liên hệ:',
      name: 'furtherInquiries',
      desc: '',
      args: [],
    );
  }

  /// `Hotline: 024 324562 2255`
  String get hotline {
    return Intl.message(
      'Hotline: 024 324562 2255',
      name: 'hotline',
      desc: '',
      args: [],
    );
  }

  /// `Email: bocongan@bca.com`
  String get email {
    return Intl.message(
      'Email: bocongan@bca.com',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Địa chỉ: Tòa nhà bộ công an - xxx đường xxx`
  String get publicSecurityAddress {
    return Intl.message(
      'Địa chỉ: Tòa nhà bộ công an - xxx đường xxx',
      name: 'publicSecurityAddress',
      desc: '',
      args: [],
    );
  }

  /// `Danh sách hàng giả được cảnh báo bởi Bộ công an`
  String get counterfeitProductsList {
    return Intl.message(
      'Danh sách hàng giả được cảnh báo bởi Bộ công an',
      name: 'counterfeitProductsList',
      desc: '',
      args: [],
    );
  }

  /// `Danh sách hàng nghi ngờ`
  String get suspectedProductsList {
    return Intl.message(
      'Danh sách hàng nghi ngờ',
      name: 'suspectedProductsList',
      desc: '',
      args: [],
    );
  }

  /// `Công ty cổ phần sữa 3 tốt`
  String get threeGoodMilkCompany {
    return Intl.message(
      'Công ty cổ phần sữa 3 tốt',
      name: 'threeGoodMilkCompany',
      desc: '',
      args: [],
    );
  }

  /// `Ngành hàng`
  String get industry {
    return Intl.message('Ngành hàng', name: 'industry', desc: '', args: []);
  }

  /// `Danh sách sản phẩm đang được điều tra bởi Bộ công an`
  String get productsUnderInvestigation {
    return Intl.message(
      'Danh sách sản phẩm đang được điều tra bởi Bộ công an',
      name: 'productsUnderInvestigation',
      desc: '',
      args: [],
    );
  }

  /// `Sản phẩm dinh dưỡng Kasumi grow`
  String get kasumiGrowNutrition {
    return Intl.message(
      'Sản phẩm dinh dưỡng Kasumi grow',
      name: 'kasumiGrowNutrition',
      desc: '',
      args: [],
    );
  }

  /// `Thông tin cá nhân`
  String get personalInformation {
    return Intl.message(
      'Thông tin cá nhân',
      name: 'personalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Điều khoản sử dụng`
  String get termsOfUse {
    return Intl.message(
      'Điều khoản sử dụng',
      name: 'termsOfUse',
      desc: '',
      args: [],
    );
  }

  /// `Chính sách quyền riêng tư`
  String get privacyPolicy {
    return Intl.message(
      'Chính sách quyền riêng tư',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Hướng dẫn trợ giúp`
  String get helpGuide {
    return Intl.message(
      'Hướng dẫn trợ giúp',
      name: 'helpGuide',
      desc: '',
      args: [],
    );
  }

  /// `Liên hệ với chúng tôi`
  String get contactUs {
    return Intl.message(
      'Liên hệ với chúng tôi',
      name: 'contactUs',
      desc: '',
      args: [],
    );
  }

  /// `Đăng xuất`
  String get logout {
    return Intl.message('Đăng xuất', name: 'logout', desc: '', args: []);
  }

  /// `Họ và tên`
  String get fullName {
    return Intl.message('Họ và tên', name: 'fullName', desc: '', args: []);
  }

  /// `Ngày sinh`
  String get dateOfBirth {
    return Intl.message('Ngày sinh', name: 'dateOfBirth', desc: '', args: []);
  }

  /// `Số DDCN`
  String get idNumber {
    return Intl.message('Số DDCN', name: 'idNumber', desc: '', args: []);
  }

  /// `Mức TK`
  String get accountLevel {
    return Intl.message('Mức TK', name: 'accountLevel', desc: '', args: []);
  }

  /// `Thông tin này được chia sẻ từ VNeID`
  String get infoSharedFromVneID {
    return Intl.message(
      'Thông tin này được chia sẻ từ VNeID',
      name: 'infoSharedFromVneID',
      desc: '',
      args: [],
    );
  }

  /// `Các Điều khoản dịch vụ này phản ánh cách thức kinh doanh của Google, những điều luật mà công ty chúng tôi phải tuân theo và một số điều mà chúng tôi vẫn luôn tin là đúng. Do đó, các Điều khoản dịch vụ này giúp xác định mối quan hệ giữa Google với bạn khi bạn tương tác với các dịch vụ của chúng tôi. Ví dụ: Các điều khoản này trình bày các chủ đề sau: Trách nhiệm của chúng tôi: Đây là phần mô tả cách chúng tôi cung cấp và phát triển các dịch vụ của mình Trách nhiệm của bạn: Phần này nêu ra một số quy tắc mà bạn phải tuân theo khi sử dụng các dịch vụ của chúng tôi Nội dung trong các dịch vụ của Google: Phần này mô tả quyền sở hữu trí tuệ đối với nội dung mà bạn thấy trong các dịch vụ của chúng tôi, bất kể nội dung đó thuộc về bạn, Google hay người khác Trong trường hợp xảy ra vấn đề hoặc bất đồng: Phần này mô tả các quyền hợp pháp khác mà bạn có và những điều bạn nên biết trong trường hợp có người vi phạm các điều khoản này Việc hiểu rõ các điều khoản này rất quan trọng, vì khi truy cập hoặc sử dụng các dịch vụ của chúng tôi, nghĩa là bạn đồng ý với các điều khoản này.`
  String get googleTermsDescription {
    return Intl.message(
      'Các Điều khoản dịch vụ này phản ánh cách thức kinh doanh của Google, những điều luật mà công ty chúng tôi phải tuân theo và một số điều mà chúng tôi vẫn luôn tin là đúng. Do đó, các Điều khoản dịch vụ này giúp xác định mối quan hệ giữa Google với bạn khi bạn tương tác với các dịch vụ của chúng tôi. Ví dụ: Các điều khoản này trình bày các chủ đề sau: Trách nhiệm của chúng tôi: Đây là phần mô tả cách chúng tôi cung cấp và phát triển các dịch vụ của mình Trách nhiệm của bạn: Phần này nêu ra một số quy tắc mà bạn phải tuân theo khi sử dụng các dịch vụ của chúng tôi Nội dung trong các dịch vụ của Google: Phần này mô tả quyền sở hữu trí tuệ đối với nội dung mà bạn thấy trong các dịch vụ của chúng tôi, bất kể nội dung đó thuộc về bạn, Google hay người khác Trong trường hợp xảy ra vấn đề hoặc bất đồng: Phần này mô tả các quyền hợp pháp khác mà bạn có và những điều bạn nên biết trong trường hợp có người vi phạm các điều khoản này Việc hiểu rõ các điều khoản này rất quan trọng, vì khi truy cập hoặc sử dụng các dịch vụ của chúng tôi, nghĩa là bạn đồng ý với các điều khoản này.',
      name: 'googleTermsDescription',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'vi'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
