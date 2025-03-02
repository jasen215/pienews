// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(days) => "${days} 天前";

  static String m1(hours) => "${hours} 小时前";

  static String m2(minutes) => "${minutes} 分钟前";

  static String m3(title) => "正在同步 ${title}...";

  static String m4(year, month, day) => "${year}-${month}-${day}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("关于"),
        "account": MessageLookupByLibrary.simpleMessage("账户"),
        "accountInfo": MessageLookupByLibrary.simpleMessage("账户信息"),
        "accountSettings": MessageLookupByLibrary.simpleMessage("账户设置"),
        "add": MessageLookupByLibrary.simpleMessage("添加"),
        "addFailed": MessageLookupByLibrary.simpleMessage("添加失败"),
        "addFeed": MessageLookupByLibrary.simpleMessage("添加订阅源"),
        "addSuccess": MessageLookupByLibrary.simpleMessage("添加成功"),
        "addingFeed": MessageLookupByLibrary.simpleMessage("正在添加订阅源"),
        "allFilter": MessageLookupByLibrary.simpleMessage("全部"),
        "autoSyncFrequency": MessageLookupByLibrary.simpleMessage("自动同步频率"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "clearCache": MessageLookupByLibrary.simpleMessage("清除缓存"),
        "confirm": MessageLookupByLibrary.simpleMessage("确定"),
        "confirmLogout": MessageLookupByLibrary.simpleMessage("确定退出登录"),
        "currentService": MessageLookupByLibrary.simpleMessage("当前服务"),
        "dark": MessageLookupByLibrary.simpleMessage("深色模式"),
        "dataManagement": MessageLookupByLibrary.simpleMessage("数据管理"),
        "daysAgo": m0,
        "displaySettings": MessageLookupByLibrary.simpleMessage("显示设置"),
        "email": MessageLookupByLibrary.simpleMessage("邮箱"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "enterFeedUrl": MessageLookupByLibrary.simpleMessage("请输入订阅源 URL"),
        "error": MessageLookupByLibrary.simpleMessage("错误"),
        "everyHour": MessageLookupByLibrary.simpleMessage("每小时"),
        "exportData": MessageLookupByLibrary.simpleMessage("导出数据"),
        "feedAdded": MessageLookupByLibrary.simpleMessage("订阅源已添加"),
        "feedUrl": MessageLookupByLibrary.simpleMessage("订阅源 URL"),
        "feeds": MessageLookupByLibrary.simpleMessage("订阅源"),
        "followSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
        "fontSize": MessageLookupByLibrary.simpleMessage("字体大小"),
        "hourly": MessageLookupByLibrary.simpleMessage("每小时"),
        "hoursAgo": m1,
        "importData": MessageLookupByLibrary.simpleMessage("导入数据"),
        "language": MessageLookupByLibrary.simpleMessage("语言"),
        "large": MessageLookupByLibrary.simpleMessage("大"),
        "light": MessageLookupByLibrary.simpleMessage("浅色模式"),
        "loadingImageError": MessageLookupByLibrary.simpleMessage("加载图片失败"),
        "login": MessageLookupByLibrary.simpleMessage("登录"),
        "logout": MessageLookupByLibrary.simpleMessage("退出登录"),
        "medium": MessageLookupByLibrary.simpleMessage("中"),
        "minutesAgo": m2,
        "noArticles": MessageLookupByLibrary.simpleMessage("暂无文章"),
        "noFeedsAvailable": MessageLookupByLibrary.simpleMessage("暂无订阅源"),
        "notifications": MessageLookupByLibrary.simpleMessage("通知"),
        "ok": MessageLookupByLibrary.simpleMessage("确定"),
        "password": MessageLookupByLibrary.simpleMessage("密码"),
        "passwordMustBeAtLeast6Characters":
            MessageLookupByLibrary.simpleMessage(
          "密码必须至少 6 个字符",
        ),
        "pleaseEnterAValidEmailAddress": MessageLookupByLibrary.simpleMessage(
          "请输入有效的邮箱地址",
        ),
        "pleaseEnterYourEmail": MessageLookupByLibrary.simpleMessage("请输入您的邮箱"),
        "pleaseEnterYourPassword":
            MessageLookupByLibrary.simpleMessage("请输入您的密码"),
        "pushNotifications": MessageLookupByLibrary.simpleMessage("推送通知"),
        "readingPreferences": MessageLookupByLibrary.simpleMessage("阅读偏好"),
        "retry": MessageLookupByLibrary.simpleMessage("重试"),
        "selectFeedService": MessageLookupByLibrary.simpleMessage("选择订阅源服务"),
        "settings": MessageLookupByLibrary.simpleMessage("设置"),
        "showUncategorized": MessageLookupByLibrary.simpleMessage("显示未分组"),
        "simplifiedChinese": MessageLookupByLibrary.simpleMessage("简体中文"),
        "small": MessageLookupByLibrary.simpleMessage("小"),
        "starredFilter": MessageLookupByLibrary.simpleMessage("已加星标"),
        "sync": MessageLookupByLibrary.simpleMessage("同步"),
        "syncCompleted": MessageLookupByLibrary.simpleMessage("同步完成"),
        "syncFailed": MessageLookupByLibrary.simpleMessage("同步失败"),
        "syncFrequency": MessageLookupByLibrary.simpleMessage("自动同步频率"),
        "syncOnlyOnWifi": MessageLookupByLibrary.simpleMessage("仅在 Wi-Fi 下同步"),
        "syncingFeed": m3,
        "syncingFeeds": MessageLookupByLibrary.simpleMessage("正在同步订阅源..."),
        "theme": MessageLookupByLibrary.simpleMessage("主题"),
        "themeMode": MessageLookupByLibrary.simpleMessage("主题模式"),
        "themeSettings": MessageLookupByLibrary.simpleMessage("主题设置"),
        "uncategorized": MessageLookupByLibrary.simpleMessage("未分组"),
        "unreadFilter": MessageLookupByLibrary.simpleMessage("未读"),
        "username": MessageLookupByLibrary.simpleMessage("用户名"),
        "version": MessageLookupByLibrary.simpleMessage("版本"),
        "welcomeBack": MessageLookupByLibrary.simpleMessage("欢迎回来"),
        "wifiOnly": MessageLookupByLibrary.simpleMessage("仅在 Wi-Fi 下同步"),
        "yearMonthDay": m4,
      };
}
