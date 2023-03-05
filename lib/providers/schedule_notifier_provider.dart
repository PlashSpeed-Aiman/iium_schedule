import 'package:flutter/widgets.dart';

/// To notify [SavedScheduleLayout] about changes in other places
/// so it could 'refresh' the schedule
class ScheduleNotifierProvider extends ChangeNotifier {
  // just to notify the listeners when something changes, nothing else
  void notify() {
    notifyListeners();
  }
}
