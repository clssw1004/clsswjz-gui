import 'package:flutter/material.dart';

import '../manager/app_config_manager.dart';
import '../manager/database_manager.dart';
import '../models/vo/book_meta.dart';
import '../models/vo/user_book_vo.dart' show UserBookVO;
import '../models/vo/user_debt_vo.dart';
import '../models/vo/user_item_vo.dart';
import '../pages/book/book_list_page.dart';
import '../pages/book/item_add_page.dart';
import '../pages/book/item_add_page_v2.dart';
import '../pages/book/item_edit_page.dart';
import '../pages/book/item_edit_page_v2.dart';
import '../pages/book/book_form_page.dart';
import '../pages/book/merchants_page.dart';
import '../pages/book/refund_form_page.dart';
import '../pages/home_page.dart';
import '../pages/import/import_page.dart';
import '../pages/settings/language_settings_page.dart';
import '../pages/settings/server_config_page.dart';
import '../pages/settings/theme_settings_page.dart';
import '../pages/user_info_page.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import '../pages/book/tags_page.dart';
import '../pages/book/projects_page.dart';
import '../pages/book/categories_page.dart';
import '../pages/book/fund_list_page.dart';
import '../pages/settings/about_page.dart';
import '../pages/settings/sync_settings_page.dart';
import '../pages/book/note_form_page.dart';
import '../models/vo/user_note_vo.dart';
import '../pages/settings/reset_auth_page.dart';
import '../pages/settings/ui_config_page.dart';
import '../pages/settings/share_settings_page.dart';
import '../pages/book/debt_add_page.dart';
import '../pages/book/item_list_page.dart';
import '../pages/book/items.page.dart';
import '../models/dto/item_filter_dto.dart';
import '../pages/book/debt_list_page.dart';
import '../pages/book/debt_edit_page.dart';
import '../pages/book/debt_payment_page.dart';
import '../pages/attachment/attachment_list_page.dart';
import '../pages/gift_card/gift_card_list_page.dart';
import '../pages/gift_card/gift_card_form_page.dart';
import '../pages/gift_card/gift_card_detail_page.dart';
import '../models/vo/gift_card_vo.dart';
import '../pages/activity/activity_checkin_page.dart';
import '../pages/fuel/vehicle_list_page.dart' show FuelHubPage;
import '../pages/fuel/vehicle_form_page.dart';
import '../pages/fuel/fuel_record_list_page.dart';
import '../pages/fuel/fuel_record_form_page.dart';
import '../pages/fuel/fuel_record_detail_page.dart';
import '../pages/fuel/fuel_statistics_page.dart';

/// 应用路由配置
class AppRoutes {
  static const String home = '/home';

  /// 用户信息页面
  static const String userInfo = '/user_info';

  /// 主题设置页面
  static const String themeSettings = '/theme_settings';

  /// 语言设置页面
  static const String languageSettings = '/language_settings';

  /// 数据库查看器页面
  static const String databaseViewer = '/database_viewer';

  /// UI布局设置页面
  static const String uiLayoutSettings = '/ui_layout_settings';

  /// 账本列表页面
  static const String accountBooks = '/books';

  /// 账目详情表单页面
  static const String itemAdd = '/item_add';

  /// 账目编辑页面
  static const String itemEdit = '/item_edit';

  /// 账目退款页面
  static const String itemRefund = '/item_refund';

  /// 账目列表页面
  static const String itemsList = '/items_list';

  /// 通用账目列表页面（可接收筛选条件）
  static const String items = '/items';

  /// 账本创建页面
  static const String bookForm = '/book_form';

  static const String serverConfig = '/server_config';

  static const String merchants = '/merchants';

  static const String tags = '/tags';

  static const String projects = '/projects';

  static const String categories = '/categories';

  /// 资金账户列表页面
  static const String funds = '/funds';

  static const String about = '/about';

  static const String syncSettings = '/sync_settings';

  static const String import = '/import';

  static const String noteAdd = '/note_add';

  static const String noteEdit = '/note_edit';

  static const String resetAuth = '/reset_auth';

  static const String debtAdd = '/debt/add';

  static const String debtList = '/debt/list';

  static const String debtEdit = '/debt/edit';

  static const String debtPayment = '/debt/payment';

  static const String attachments = '/attachments';

  static const String todoAdd = '/todo/add';

  /// 礼物卡列表页面
  static const String giftCardList = '/gift_card/list';

  /// 礼物卡表单页面
  static const String giftCardForm = '/gift_card/form';

  /// 礼物卡详情页面
  static const String giftCardDetail = '/gift_card/detail';

  /// 车辆列表页面
  static const String fuelVehicles = '/fuel/vehicles';

  /// 车辆表单页面
  static const String fuelVehicleForm = '/fuel/vehicle/form';

  /// 加油记录列表页面
  static const String fuelRecords = '/fuel/records';

  /// 加油记录表单页面
  static const String fuelRecordForm = '/fuel/record/form';

  /// 加油记录详情页面
  static const String fuelRecordDetail = '/fuel/record/detail';

  /// 油耗统计页面
  static const String fuelStatistics = '/fuel/statistics';

  /// 数据共享设置页面
  static const String shareSettings = '/share_settings';

  /// 活动打卡页面
  static const String activityCheckin = '/activity/checkin';

  /// 统一页面过渡动画构建
  static Route<dynamic> _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // 根据路由名称查找页面
    final page = _resolvePage(settings);
    if (page != null) {
      return _buildPageRoute(page);
    }
    return null;
  }

  /// 根据路由设置解析页面
  static Widget? _resolvePage(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case home:
        return const HomePage();
      case serverConfig:
        return const ServerConfigPage();
      case userInfo:
        return const UserInfoPage();
      case themeSettings:
        return const ThemeSettingsPage();
      case languageSettings:
        return const LanguageSettingsPage();
      case databaseViewer:
        return DriftDbViewer(DatabaseManager.db);
      case uiLayoutSettings:
        return const UiConfigPage();
      case accountBooks:
        return const BookListPage();
      case bookForm:
        return const BookFormPage();
      case itemAdd: {
        final list = args as List<dynamic>;
        final accountBook = list[0] as BookMetaVO;
        final preFilledItem = list.length > 1 ? list[1] as UserItemVO? : null;
        if (AppConfigManager.instance.uiConfig.useNewItemForm) {
          return ItemAddPageV2(bookMeta: accountBook, item: preFilledItem);
        }
        return ItemAddPage(bookMeta: accountBook, item: preFilledItem);
      }
      case itemEdit: {
        final list = args as List<dynamic>;
        final accountBook = list[0] as BookMetaVO;
        final item = list[1] as UserItemVO;
        if (AppConfigManager.instance.uiConfig.useNewItemForm) {
          return ItemEditPageV2(bookMeta: accountBook, item: item);
        }
        return ItemEditPage(bookMeta: accountBook, item: item);
      }
      case itemRefund: {
        final list = args as List<dynamic>;
        final accountBook = list[0] as BookMetaVO;
        final item = list[1] as UserItemVO;
        return RefundFormPage(bookMeta: accountBook, originalItem: item);
      }
      case itemsList: {
        final bookMeta = args as BookMetaVO;
        return ItemListPage(accountBook: bookMeta);
      }
      case items: {
        final list = args as List<dynamic>;
        final bookMeta = list[0] as BookMetaVO;
        final filter = list.length > 1 ? list[1] as ItemFilterDTO? : null;
        final title = list.length > 2 ? list[2] as String? : null;
        return ItemsPage(bookMeta: bookMeta, initialFilter: filter, title: title);
      }
      case merchants: {
        final bookMeta = args as BookMetaVO;
        return MerchantsPage(accountBook: bookMeta);
      }
      case tags: {
        final bookMeta = args as BookMetaVO;
        return TagsPage(accountBook: bookMeta);
      }
      case projects: {
        final bookMeta = args as BookMetaVO;
        return ProjectsPage(accountBook: bookMeta);
      }
      case categories: {
        final bookMeta = args as BookMetaVO;
        return AccountCategoriesPage(accountBook: bookMeta);
      }
      case funds: {
        final bookMeta = args as BookMetaVO;
        return FundListPage(accountBook: bookMeta);
      }
      case about:
        return const AboutPage();
      case syncSettings:
        return const SyncSettingsPage();
      case import:
        return const ImportPage();
      case resetAuth: {
        final serverUrl = args as String;
        return ResetAuthPage(serverUrl: serverUrl);
      }
      case noteAdd: {
        final list = args as List<dynamic>;
        final accountBook = list[0] as UserBookVO;
        return NoteFormPage(book: accountBook);
      }
      case noteEdit: {
        final list = args as List<dynamic>;
        final note = list[0] as UserNoteVO;
        final accountBook = list[1] as UserBookVO;
        return NoteFormPage(note: note, book: accountBook);
      }
      case debtAdd: {
        final list = args as List<dynamic>;
        final accountBook = list[0] as BookMetaVO;
        final debtor = list.length > 1 ? list[1] as String? : null;
        return DebtAddPage(book: accountBook, debtor: debtor);
      }
      case debtList: {
        final bookMeta = args as BookMetaVO;
        return DebtListPage(bookMeta: bookMeta);
      }
      case debtEdit: {
        final list = args as List<dynamic>;
        final accountBook = list[0] as BookMetaVO;
        final debt = list[1] as UserDebtVO;
        return DebtEditPage(book: accountBook, debt: debt);
      }
      case debtPayment: {
        final list = args as List<dynamic>;
        final title = list[0] as String;
        final accountBook = list[1] as BookMetaVO;
        final debt = list[2] as UserDebtVO;
        final categoryCode = list[3] as String;
        return DebtPaymentPage(
          title: title, book: accountBook, debt: debt, categoryCode: categoryCode,
        );
      }
      case attachments:
        return const AttachmentListPage();
      case giftCardList: {
        final tabIndex = args is int ? args : 0;
        return GiftCardListPage(initialTabIndex: tabIndex);
      }
      case giftCardForm: {
        final giftCard = args as GiftCardVO?;
        return GiftCardFormPage(giftCard: giftCard);
      }
      case giftCardDetail: {
        final giftCard = args as GiftCardVO;
        return GiftCardDetailPage(giftCard: giftCard);
      }
      case fuelVehicles:
        return const FuelHubPage();
      case fuelVehicleForm: {
        final vehicleId = args as String?;
        return VehicleFormPage(vehicleId: vehicleId);
      }
      case fuelRecords: {
        final map = args as Map?;
        return FuelRecordListPage(
          initialVehicleId: map?['vehicleId'] as String?,
          initialPlateNumber: map?['plateNumber'] as String?,
        );
      }
      case fuelRecordForm: {
        final map = args as Map;
        return FuelRecordFormPage(
          vehicleId: map['vehicleId'],
          recordId: map['recordId'],
        );
      }
      case fuelRecordDetail: {
        final recordId = args as String;
        return FuelRecordDetailPage(recordId: recordId);
      }
      case fuelStatistics: {
        final map = args as Map;
        return FuelStatisticsPage(
          vehicleId: map['vehicleId'],
          plateNumber: map['plateNumber'],
        );
      }
      case shareSettings:
        return const ShareSettingsPage();
      case activityCheckin:
        return const ActivityCheckinPage();
      default:
        return null;
    }
  }

  /// 路由表（兼容 MaterialApp.routes 参数，现在由 _resolvePage 统一处理）
  static Map<String, WidgetBuilder> routes = {};
}
