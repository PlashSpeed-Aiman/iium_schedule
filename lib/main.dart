import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'constants.dart';
import 'enums/subject_title_setting_enum.dart';
import 'hive_model/gh_responses.dart';
import 'hive_model/saved_daytime.dart';
import 'hive_model/saved_schedule.dart';
import 'hive_model/saved_subject.dart';
import 'providers/saved_subjects_provider.dart';
import 'providers/schedule_layout_setting_provider.dart';
import 'views/body.dart';

void main() async {
  await Hive.initFlutter('IIUM Schedule Data');
  Hive
    ..registerAdapter(SavedScheduleAdapter())
    ..registerAdapter(SavedSubjectAdapter())
    ..registerAdapter(SavedDaytimeAdapter())
    ..registerAdapter(GhResponsesAdapter())
    ..registerAdapter(SubjectTitleSettingAdapter());
  await Hive.openBox<SavedSchedule>(kHiveSavedSchedule);
  await Hive.openBox<GhResponses>(kHiveGhResponse);

  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ super.key });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleLayoutSettingProvider()),
        ChangeNotifierProvider(create: (_) => SavedSubjectsProvider()),
      ],
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) {
          return MaterialApp(
            title: 'IIUM Schedule',
            theme: ThemeData(
              colorScheme: lightColorScheme,
              useMaterial3: true,
              fontFamily: 'Inter'
            ),
            darkTheme: ThemeData.dark().copyWith(
              // cupertinoOverrideTheme:
              //     const CupertinoThemeData(primaryColor: Color(0xFF23682B)),
              // textButtonTheme: TextButtonThemeData(
              //   style:
              //       TextButton.styleFrom(foregroundColor: Colors.purple.shade200),
              // ),
              // outlinedButtonTheme: OutlinedButtonThemeData(
              //   style: OutlinedButton.styleFrom(
              //       foregroundColor: Colors.purple.shade200),
              // ),
              useMaterial3: true,
              textTheme: ThemeData.dark().textTheme.apply(
                fontFamily: 'Inter'
              ),
              primaryTextTheme: ThemeData.dark().textTheme.apply(
                fontFamily: 'Inter'
              ),
              colorScheme: darkColorScheme
            ),
            themeMode: ThemeMode.system,
            home: const MyBody(),
          );
        }
      ),
    );
  }
}

/// To avoid invalid Cert Error
/// https://github.com/iqfareez/iium_schedule/issues/10
/// https://stackoverflow.com/a/61312927/13617136
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (_, String host, __) => host == 'albiruni.iium.edu.my';
  }
}
