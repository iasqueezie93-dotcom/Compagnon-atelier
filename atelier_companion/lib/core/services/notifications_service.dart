import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notification locale (modèle de démo).
@immutable
class LocalNotice {
  final String title;
  final String body;
  final DateTime at;
  const LocalNotice({required this.title, required this.body, required this.at});
}

/// Service de notifications locales — stub en mémoire.
/// Production : brancher `flutter_local_notifications` (zonedSchedule) ici.
class NotificationsService extends ChangeNotifier {
  final List<LocalNotice> _notices = [];
  List<LocalNotice> get notices => List.unmodifiable(_notices);

  void push(String title, String body) {
    _notices.insert(0, LocalNotice(title: title, body: body, at: DateTime.now()));
    // TODO(jalon 4): FlutterLocalNotificationsPlugin().show(...)
    notifyListeners();
  }

  void clear() {
    _notices.clear();
    notifyListeners();
  }
}

final notificationsProvider =
    ChangeNotifierProvider<NotificationsService>((_) => NotificationsService());
