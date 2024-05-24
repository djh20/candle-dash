import 'package:flutter/material.dart';
import 'package:candle_dash/bluetooth/bluetooth_manager.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:github/github.dart';

enum UpdateAvailability {
  unknown,
  checking,
  upToDate,
  newVersionAvailable,
}

class UpdateManager with ChangeNotifier {
  bool get isCheckingForUpdates => 
    appUpdateAvailability == UpdateAvailability.checking;

  UpdateAvailability appUpdateAvailability = UpdateAvailability.unknown;
  Version? currentAppVersion;
  Version? latestAppVersion;

  final GitHub _gitHub = GitHub();
  final AppSettings _appSettings;
  final BluetoothManager _bluetoothManager;

  final _appRepoSlug = RepositorySlug('djh20', 'candle-dash');

  UpdateManager(AppSettings appSettings, BluetoothManager bluetoothManager) :
    _appSettings = appSettings,
    _bluetoothManager = bluetoothManager;

  Future<void> init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentAppVersion = Version.parse(packageInfo.version);
    notifyListeners();
  }

  Future<void> checkForUpdates() async {
    appUpdateAvailability = UpdateAvailability.checking;
    latestAppVersion = null;
    notifyListeners();
    
    // await Future.wait([
    //   _getRepoLatestReleaseVersion(_appRepoSlug)
    //     .then((v) => latestAppVersion = v)
    //     .whenComplete(() => isCheckingForAppUpdate = false),
        
    // ]).catchError((err) {
    //   debugPrint(err.toString());
    //   return List<Version>.empty();
    // });

    try {
      latestAppVersion = await _getRepoLatestReleaseVersion(_appRepoSlug);

    } catch (err) {
      debugPrint(err.toString());
    }

    debugPrint('Latest App Version: ${latestAppVersion.toString()}');

    if (currentAppVersion != null && latestAppVersion != null) {
      if (latestAppVersion! > currentAppVersion!) {
        appUpdateAvailability = UpdateAvailability.newVersionAvailable;
      } else {
        appUpdateAvailability = UpdateAvailability.upToDate;
      }
    } else {
      appUpdateAvailability = UpdateAvailability.unknown;
    }

    notifyListeners();
  }

  Future<Version> _getRepoLatestReleaseVersion(RepositorySlug slug) async {
    final Release latestRelease = 
      _appSettings.experimentalMode == true ? 
      await _gitHub.repositories.listReleases(slug).take(1).first :
      await _gitHub.repositories.getLatestRelease(slug);

    if (latestRelease.tagName == null) throw Exception("Release doesn't have a tag");
    
    return Version.parse(latestRelease.tagName!);
  }
}