// import 'package:android_package_installer/android_package_installer.dart';
import 'package:candle_dash/ota/updater.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AppUpdater extends Updater {
  late final String _preferredAbi;
  String? _apkFilePath;

  AppUpdater(AppSettings appSettings) : super(
    appSettings,
    RepositorySlug('djh20', 'candle-dash'),
  );

  @override
  Future<void> init() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    _preferredAbi = androidInfo.supportedAbis[0];
    return super.init();
  }

  @override
  Future<Version> fetchCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return Version.parse(packageInfo.version);
  }

  @override
  List<UpdaterTask> getTasks() => [
    UpdaterTask(description: 'Downloading', run: _downloadApk),
    UpdaterTask(description: 'Installing', run: _installApk),
  ];

  Future<void> _downloadApk(UpdaterTaskContext ctx) async {
    debugPrint('Download task started!');

    debugPrint('Performing update from $currentVersion to $latestVersion');
    debugPrint('Preferred ABI: $_preferredAbi');
    
    final compatibleAsset = ctx.release.assets?.firstWhereOrNull(
      (a) => a.browserDownloadUrl?.contains('-$_preferredAbi-') == true,
    );

    final url = compatibleAsset?.browserDownloadUrl;

    if (url != null) {
      debugPrint('Compatible APK: ${compatibleAsset?.browserDownloadUrl}');
      _apkFilePath = await downloadFile(url, onProgress: ctx.setProgress);
    }
  }

  Future<void> _installApk(UpdaterTaskContext ctx) async {
    if (_apkFilePath == null) return;

    debugPrint('Attempting to install APK: $_apkFilePath');
    await OpenFile.open(_apkFilePath!);
    
    // int? statusCode = await AndroidPackageInstaller.installApk(apkFilePath: _apkFilePath!);
    // if (statusCode != null) {
    //   PackageInstallerStatus installationStatus = PackageInstallerStatus.byCode(statusCode);
    //   debugPrint(installationStatus.name);
    // }
  }
}