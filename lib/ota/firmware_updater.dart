// import 'package:android_package_installer/android_package_installer.dart';
import 'dart:async';
import 'dart:io';

import 'package:candle_dash/bluetooth/bluetooth_uuids.dart';
import 'package:candle_dash/ota/updater.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:github/github.dart';
import 'package:version/version.dart';
import 'package:convert/convert.dart';

class FirmwareUpdater extends Updater {
  final BluetoothDevice _bluetoothDevice;
  late final BluetoothService _infoService;
  late final String _hardwareModel;

  Completer<List<int>>? _responseCompleter;

  String? _binFilePath;
  String? _hashFilePath;
  
  FirmwareUpdater(AppSettings appSettings, BluetoothDevice bluetoothDevice) : 
    _bluetoothDevice = bluetoothDevice,
    super(
      appSettings,
      RepositorySlug('djh20', 'candle'),
    );

  @override
  Future<void> init() async {
    _infoService = _bluetoothDevice.servicesList.firstWhere(
      (m) => m.uuid == Guid(BluetoothUuids.infoService),
    );

    final hardwareModelChar = _infoService.characteristics.firstWhere(
      (c) => c.uuid == Guid(BluetoothUuids.infoHardwareModelChar),
    );

    _hardwareModel = String.fromCharCodes(await hardwareModelChar.read());

    return super.init();
  }

  @override
  Future<Version> fetchCurrentVersion() async {
    debugPrint('Fetching firmware version...');
    
    final firmwareChar = _infoService.characteristics.firstWhere(
      (c) => c.uuid == Guid(BluetoothUuids.infoFirmwareChar),
    );

    final version = String.fromCharCodes(await firmwareChar.read());

    debugPrint('Firmware Version: $version');

    return Version.parse(version);
  }

  @override
  List<UpdaterTask> getTasks() => [
    UpdaterTask(description: 'Downloading', run: _flashFirmware),
    UpdaterTask(description: 'Installing', run: _installFirmware),
  ];

  Future<void> _flashFirmware(UpdaterTaskContext ctx) async {
    final compatibleAssets = ctx.release.assets?.where(
      (a) => a.name?.contains(RegExp('$_hardwareModel.*')) == true,
    ).toList();

    if (compatibleAssets == null) throw Exception('No compatible assets found');

    final binAsset = 
      compatibleAssets.firstWhere((a) => a.name?.endsWith('.bin') == true);

    final hashAsset = 
      compatibleAssets.firstWhere((a) => a.name?.endsWith('.md5') == true);

    debugPrint('Firmware Bin: ${binAsset.browserDownloadUrl}');
    debugPrint('Firmware Hash: ${hashAsset.browserDownloadUrl}');

    if (binAsset.browserDownloadUrl != null && hashAsset.browserDownloadUrl != null) {
      _hashFilePath = await downloadFile(hashAsset.browserDownloadUrl!);
      _binFilePath = await downloadFile(
        binAsset.browserDownloadUrl!,
        onProgress: ctx.setProgress,
      );
    }
  }

  Future<void> _installFirmware(UpdaterTaskContext ctx) async {
    if (_binFilePath == null || _hashFilePath == null) return;
    
    // File binFile = File(_binFilePath!);
    // binFile.length()

    final binFile = File(_binFilePath!);
    final binSize = await binFile.length();
    final binSizeEncoded = uint32ToIntList(binSize);

    debugPrint('Binary Size: $binSize');

    final hashFile = File(_hashFilePath!);
    final hash = await hashFile.readAsString();
    final hashEncoded = hex.decode(hash);

    debugPrint('MD5 Hash: $hash');
    debugPrint('Encoded hash is ${hashEncoded.length} bytes long');

    final otaService = _bluetoothDevice.servicesList.firstWhere(
      (m) => m.uuid == Guid(BluetoothUuids.otaService),
    );

    final otaCommandChar = otaService.characteristics.firstWhere(
      (c) => c.uuid == Guid(BluetoothUuids.otaCommandChar),
    );

    final otaDataChar = otaService.characteristics.firstWhere(
      (c) => c.uuid == Guid(BluetoothUuids.otaDataChar),
    );

    otaCommandChar.onValueReceived.listen(
      (data) => _processResponse(data),
    );

    final mtu = _bluetoothDevice.mtuNow;
    debugPrint('MTU: $mtu');
    
    await otaCommandChar.setNotifyValue(true, timeout: 2);

    try {
      debugPrint('Starting OTA');
      List<int> startData = <int>[0x01] + binSizeEncoded + hashEncoded;
      debugPrint('Data: $startData');
      await _write(startData, otaCommandChar);

      final binFileAccess = await binFile.open();

      /// Chunk size based on mtu minus estimated overhead.
      final int chunkSize = mtu - 20;

      debugPrint('Chunk Size: $chunkSize');

      for (int pos = 0; pos < binSize; pos += chunkSize) {
        final data = await binFileAccess.read(chunkSize);
        await otaDataChar.write(data);
        ctx.setProgress(pos / binSize);
        debugPrint('$pos / $binSize');
      }

      await binFileAccess.close();
      await _write([0x02], otaCommandChar);
      await _bluetoothDevice.disconnect(queue: false);

    } catch (err) {
      debugPrint(err.toString());
      await otaCommandChar.setNotifyValue(false, timeout: 2);
    }
  }

  Future<List<int>> _write(List<int> data, BluetoothCharacteristic char) async {
    _responseCompleter = Completer<List<int>>();
    await char.write(data, withoutResponse: true);
    return _responseCompleter!.future.timeout(const Duration(seconds: 5));
  }

  void _processResponse(List<int> data) {
    if (_responseCompleter == null || _responseCompleter!.isCompleted) return;
    debugPrint('Response: $data');

    if (data[0] == 0xFF) {
      data[1] == 0x00 ? 
        _responseCompleter?.complete(data) : 
        _responseCompleter?.completeError(
          Exception('Device responded with error'),
        );
    }
  }
}