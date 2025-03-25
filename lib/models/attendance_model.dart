enum AttendanceType { checkIn, checkOut, mealSession, event }

class AttendanceModel {
  final String? id;
  final String studentId;
  final String? studentProfileId;
  final DateTime timestamp;
  final AttendanceType attendanceType;
  final String? location;
  final String? recordedBy;
  final bool isMealRequested;
  final bool? isMealConfirmed;
  final String? notes;

  AttendanceModel({
    this.id,
    required this.studentId,
    this.studentProfileId,
    required this.timestamp,
    required this.attendanceType,
    this.location,
    this.recordedBy,
    this.isMealRequested = false,
    this.isMealConfirmed,
    this.notes,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      studentId: json['student_id'],
      studentProfileId: json['student_profile_id'],
      timestamp: DateTime.parse(json['timestamp']),
      attendanceType: _parseType(json['attendance_type']),
      location: json['location'],
      recordedBy: json['recorded_by'],
      isMealRequested: json['is_meal_requested'] ?? false,
      isMealConfirmed: json['is_meal_confirmed'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_profile_id': studentProfileId,
      'timestamp': timestamp.toIso8601String(),
      'attendance_type': attendanceType.toString().split('.').last,
      'location': location,
      'recorded_by': recordedBy,
      'is_meal_requested': isMealRequested,
      'is_meal_confirmed': isMealConfirmed,
      'notes': notes,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? studentProfileId,
    DateTime? timestamp,
    AttendanceType? attendanceType,
    String? location,
    String? recordedBy,
    bool? isMealRequested,
    bool? isMealConfirmed,
    String? notes,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentProfileId: studentProfileId ?? this.studentProfileId,
      timestamp: timestamp ?? this.timestamp,
      attendanceType: attendanceType ?? this.attendanceType,
      location: location ?? this.location,
      recordedBy: recordedBy ?? this.recordedBy,
      isMealRequested: isMealRequested ?? this.isMealRequested,
      isMealConfirmed: isMealConfirmed ?? this.isMealConfirmed,
      notes: notes ?? this.notes,
    );
  }

  static AttendanceType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'checkin':
        return AttendanceType.checkIn;
      case 'checkout':
        return AttendanceType.checkOut;
      case 'mealsession':
        return AttendanceType.mealSession;
      case 'event':
      default:
        return AttendanceType.event;
    }
  }
}
