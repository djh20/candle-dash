class BluetoothUuids {
  // This class is not meant to be instantiated or extended; this constructor prevents instantiation and extension.
  BluetoothUuids._();

  static const String customSuffix = '0000-4d91-b049-e2828e6da1a0';

  static const String infoService = '180A';
  static const String infoHardwareModelChar = '2A24';
  static const String infoFirmwareChar = '2A26';

  static const String otaService = '00000000-$customSuffix';
  static const String otaCommandChar = '00000001-$customSuffix';
  static const String otaDataChar = '00000002-$customSuffix';

  static const String consoleService = '00000100-$customSuffix';
  static const String consoleCommandChar = '00000101-$customSuffix';

  // static const String vehicleCatalogService = '00000300-$customSuffix';

  static const String metricsService = '00000300-$customSuffix';
  static const String metricsDescriptor = '00000302-$customSuffix';

  static bool customCheck(List<int> uuid, int shortId) {
    return (uuid[2] << 8 | uuid[3]) == shortId;
  }
}