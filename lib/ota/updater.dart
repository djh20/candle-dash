import 'dart:io';

import 'package:candle_dash/settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:version/version.dart';

enum UpdateAvailability {
  unknown,
  checking,
  upToDate,
  newVersionAvailable,
}

abstract class Updater with ChangeNotifier {
  static final GitHub _gitHub = GitHub();
  static final Dio _dio = Dio();
  
  Version? currentVersion;
  Version? latestVersion;
  UpdateAvailability updateAvailability = UpdateAvailability.unknown;

  bool isUpdating = false;
  UpdaterTask? currentTask;
  double? currentTaskProgress;

  final AppSettings _appSettings;
  final RepositorySlug _repoSlug;
  late final List<UpdaterTask> _tasks;
  Release? _latestRelease;
  late final int _sdkVersion;

  Updater(AppSettings appSettings, RepositorySlug repoSlug) :
    _appSettings = appSettings,
    _repoSlug = repoSlug;

  Future<void> init() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    _sdkVersion = androidInfo.version.sdkInt;

    currentVersion = await fetchCurrentVersion();
    _tasks = getTasks();
    notifyListeners();
    await checkForUpdates();
  }

  Future<Version> fetchCurrentVersion();
  List<UpdaterTask> getTasks();
  
  Future<void> performUpdate() async {
    if (_latestRelease == null) return;

    isUpdating = true;
    notifyListeners();

    await _runTasks().catchError((err) => debugPrint(err.toString()));

    isUpdating = false;
    currentTask = null;
    currentTaskProgress = null;
    notifyListeners();
  }

  Future<void> _runTasks() async {
    final context = UpdaterTaskContext(
      release: _latestRelease!,
      setProgress: setProgress,
    );

    for (final task in _tasks) {
      currentTask = task;
      currentTaskProgress = null;
      notifyListeners();

      await task.run(context);
    }
  }

  void setProgress(double progress) {
    currentTaskProgress = progress;
    notifyListeners();
  }

  Future<void> checkForUpdates() async {
    if (isUpdating) return;
    
    updateAvailability = UpdateAvailability.checking;
    latestVersion = null;
    _latestRelease = null;
    notifyListeners();

    try {
      _latestRelease = await _fetchLatestRelease(_repoSlug);
      if (_latestRelease!.tagName == null) throw Exception("Release doesn't have a tag");
      latestVersion = Version.parse(_latestRelease!.tagName!);
    } catch (err) {
      debugPrint(err.toString());
    }

    if (currentVersion != null && latestVersion != null) {
      debugPrint('Latest version for $_repoSlug is $latestVersion');
      if (latestVersion! > currentVersion!) {
        updateAvailability = UpdateAvailability.newVersionAvailable;
      } else {
        updateAvailability = UpdateAvailability.upToDate;
      }
    } else {
      updateAvailability = UpdateAvailability.unknown;
    }

    notifyListeners();
  }

  Future<String> downloadFile(
    String url, 
    {
      CancelToken? cancelToken, 
      Function(double progress)? onProgress,
      bool externalStorage = false,
    }) async {

    PermissionStatus permissionStatus;

    if (_sdkVersion < 33) {
      permissionStatus = await Permission.storage.request();
      if (!permissionStatus.isGranted) {
        throw Exception('Storage permission not granted');
      }
    }

    if (externalStorage && _sdkVersion > 30) {
      permissionStatus = await Permission.manageExternalStorage.request();
      if (!permissionStatus.isGranted) {
        throw Exception('Manage external storage permission not granted');
      }
    }

    final Directory? dir =
      externalStorage ? 
        await getExternalStorageDirectory() :
        await getApplicationCacheDirectory();
    
    if (dir == null) throw Exception('Failed to find directory');
    
    final String fileName = url.split('/').last;
    final String filePath = '${dir.path}/$fileName';
    
    debugPrint('Downloading $url to $filePath');

    await _dio.download(
      url,
      filePath,
      cancelToken: cancelToken,
      onReceiveProgress: (onProgress != null) ? 
        (count, total) => onProgress(count / total) : null,
    );

    return filePath;
  }

  Future<Release> _fetchLatestRelease(RepositorySlug slug) =>
    _appSettings.experimentalMode == true ? 
      _gitHub.repositories.listReleases(slug).take(1).first :
      _gitHub.repositories.getLatestRelease(slug);
}

class UpdaterTask {
  final String description;
  final Future Function(UpdaterTaskContext) run;

  UpdaterTask({
    required this.description,
    required this.run,
  });
}

class UpdaterTaskContext {
  final Release release;
  final void Function(double) setProgress;

  UpdaterTaskContext({
    required this.release,
    required this.setProgress,
  });
}