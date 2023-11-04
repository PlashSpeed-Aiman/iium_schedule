import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/link.dart';
import 'package:version/version.dart';

import '../isar_models/gh_responses.dart';
import '../model/gh_error.dart';
import '../model/gh_releases_latest.dart';
import '../services/isar_service.dart';

/// Check for update for Android & Windows
/// Currently the is an known issue for Windows
/// version is not tally with pubspec.yaml
class CheckUpdatePage extends StatefulWidget {
  const CheckUpdatePage({super.key});

  @override
  State<CheckUpdatePage> createState() => _CheckUpdatePageState();
}

class _CheckUpdatePageState extends State<CheckUpdatePage> {
  late Version currentVersion;
  final IsarService isarService = IsarService();

  /// Since this method is importing dart:io, it cannot be used on the web
  /// Also, the web seems like unsuitable to have a check for updates feature
  /// Despite that there have bene multiple issuew with web pwa caching
  Future<Version> _checkLatestVersion() async {
    GhReleasesLatest latest;
    GhResponses? cachedResponses = await isarService.getGhResponse();

    // API endpoint pointed to latest stable release
    const latestRelease =
        'https://api.github.com/repos/iqfareez/iium_schedule/releases/latest';
    final response = await http.get(Uri.parse(latestRelease),
        headers: cachedResponses != null
            ? {
                'If-None-Match': cachedResponses.etag,
              }
            : null);
    // If the response is not modified, return the cached version
    // https://docs.github.com/en/rest/overview/resources-in-the-rest-api#conditional-requests

    if (response.statusCode == HttpStatus.ok) {
      final ghReleasesLatest =
          GhReleasesLatest.fromJson(json.decode(response.body));
      // store the etag and the body of the response
      isarService.addGhResponse(
          GhResponses(etag: response.headers['etag']!, body: response.body));
      latest = ghReleasesLatest;
    } else if (response.statusCode == HttpStatus.notModified) {
      // return the cached version
      var body = jsonDecode(cachedResponses!.body);
      latest = GhReleasesLatest.fromJson(body);
    } else {
      final data = json.decode(response.body);
      final ghError = GhError.fromJson(data);
      throw Exception('(${response.statusCode}) ${ghError.message})');
    }
    return Version.parse(latest.tagName!);
  }

  @override
  void initState() {
    super.initState();
    // determine current version
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      currentVersion = Version.parse(packageInfo.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update'),
        systemOverlayStyle: SystemUiOverlayStyle.light
            .copyWith(statusBarColor: Colors.transparent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: FutureBuilder(
              future: _checkLatestVersion(),
              builder: (context, AsyncSnapshot<Version> snapshot) {
                if (snapshot.hasData) {
                  if (currentVersion.compareTo(snapshot.data) < 0) {
                    var version = snapshot.data!.toString().split('+').first;
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'New version available! ($version)',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Link(
                              uri: Uri.parse(
                                  'https://iiumschedule.iqfareez.com/downloads#upgrading'),
                              builder: ((context, followLink) => TextButton(
                                  onPressed: followLink,
                                  child: const Text(
                                      'Learn how to update the app'))))
                        ],
                      ),
                    );
                  } else {
                    return const Text(
                      'You are up to date!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text(
                    'Sorry. Check update requets has failed.\n${snapshot.error}',
                    style: Theme.of(context).textTheme.titleLarge,
                  );
                } else {
                  return const Text('Checking update...');
                }
              }),
        ),
      ),
    );
  }
}
