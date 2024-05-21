class KnownBluetoothDevice {
  KnownBluetoothDevice({
    required this.id,
    required this.name,
  });

  final String id;
  String name;

  KnownBluetoothDevice.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}