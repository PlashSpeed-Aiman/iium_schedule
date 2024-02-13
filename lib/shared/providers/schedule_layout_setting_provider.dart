import 'package:flutter/material.dart';

import '../../isar_models/saved_schedule.dart';
import '../../features/schedule_viewer/saved/utils/lane_events_util.dart';

class ScheduleLayoutSettingProvider extends ChangeNotifier {
  late SubjectTitleSetting _subjectTitleSetting;
  late ExtraInfo _extraInfo;

  SubjectTitleSetting get subjectTitleSetting => _subjectTitleSetting;

  /// Update provider value from Isar settings
  /// Used in [ScheduleLayout] & [SavedScheduleLayout]
  /// Set the value without call setState() or markNeedsBuild() called during build.
  void initializeSetting(
      {SubjectTitleSetting titleSetting = SubjectTitleSetting.title,
      ExtraInfo extraInfo = ExtraInfo.none}) {
    _subjectTitleSetting = titleSetting;
    _extraInfo = extraInfo;
  }

  set subjectTitleSetting(SubjectTitleSetting value) {
    _subjectTitleSetting = value;
    notifyListeners();
  }

  ExtraInfo get extraInfo => _extraInfo;

  set extraInfo(ExtraInfo value) {
    _extraInfo = value;
    notifyListeners();
  }
}
