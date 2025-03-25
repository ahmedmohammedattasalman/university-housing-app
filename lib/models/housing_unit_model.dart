class HousingUnitModel {
  final String id;
  final String buildingName;
  final String roomNumber;
  final int capacity;
  final int floorNumber;
  final bool isAvailable;
  final double monthlyRate;
  final String unitType;
  final Map<String, dynamic>? amenities;
  final DateTime createdAt;

  HousingUnitModel({
    required this.id,
    required this.buildingName,
    required this.roomNumber,
    required this.capacity,
    required this.floorNumber,
    required this.isAvailable,
    required this.monthlyRate,
    required this.unitType,
    this.amenities,
    required this.createdAt,
  });

  String get fullRoomName => '$buildingName $roomNumber';

  factory HousingUnitModel.fromJson(Map<String, dynamic> json) {
    return HousingUnitModel(
      id: json['id'],
      buildingName: json['building_name'],
      roomNumber: json['room_number'],
      capacity: json['capacity'],
      floorNumber: json['floor_number'],
      isAvailable: json['is_available'],
      monthlyRate: (json['monthly_rate'] as num).toDouble(),
      unitType: json['unit_type'],
      amenities: json['amenities'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_name': buildingName,
      'room_number': roomNumber,
      'capacity': capacity,
      'floor_number': floorNumber,
      'is_available': isAvailable,
      'monthly_rate': monthlyRate,
      'unit_type': unitType,
      'amenities': amenities,
    };
  }

  HousingUnitModel copyWith({
    String? id,
    String? buildingName,
    String? roomNumber,
    int? capacity,
    int? floorNumber,
    bool? isAvailable,
    double? monthlyRate,
    String? unitType,
    Map<String, dynamic>? amenities,
    DateTime? createdAt,
  }) {
    return HousingUnitModel(
      id: id ?? this.id,
      buildingName: buildingName ?? this.buildingName,
      roomNumber: roomNumber ?? this.roomNumber,
      capacity: capacity ?? this.capacity,
      floorNumber: floorNumber ?? this.floorNumber,
      isAvailable: isAvailable ?? this.isAvailable,
      monthlyRate: monthlyRate ?? this.monthlyRate,
      unitType: unitType ?? this.unitType,
      amenities: amenities ?? this.amenities,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
