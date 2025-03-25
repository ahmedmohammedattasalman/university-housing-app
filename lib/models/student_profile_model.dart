import 'package:universityhousing/models/user_model.dart';
import 'package:universityhousing/models/housing_unit_model.dart';

class StudentProfileModel {
  final String id;
  final String userId;
  final String studentId;
  final String? housingUnitId;
  final DateTime enrollmentDate;
  final int academicYear;
  final String program;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final double outstandingBalance;
  final DateTime? checkInDate;
  final DateTime? expectedCheckOutDate;
  final DateTime createdAt;

  // Optional nested objects
  final UserModel? user;
  final HousingUnitModel? housingUnit;

  StudentProfileModel({
    required this.id,
    required this.userId,
    required this.studentId,
    this.housingUnitId,
    required this.enrollmentDate,
    required this.academicYear,
    required this.program,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.outstandingBalance,
    this.checkInDate,
    this.expectedCheckOutDate,
    required this.createdAt,
    this.user,
    this.housingUnit,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: json['id'],
      userId: json['user_id'],
      studentId: json['student_id'],
      housingUnitId: json['housing_unit_id'],
      enrollmentDate: DateTime.parse(json['enrollment_date']),
      academicYear: json['academic_year'],
      program: json['program'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      outstandingBalance: (json['outstanding_balance'] as num).toDouble(),
      checkInDate: json['check_in_date'] != null
          ? DateTime.parse(json['check_in_date'])
          : null,
      expectedCheckOutDate: json['expected_check_out_date'] != null
          ? DateTime.parse(json['expected_check_out_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      housingUnit: json['housing_unit'] != null
          ? HousingUnitModel.fromJson(json['housing_unit'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'student_id': studentId,
      'housing_unit_id': housingUnitId,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'academic_year': academicYear,
      'program': program,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'outstanding_balance': outstandingBalance,
      'check_in_date': checkInDate?.toIso8601String(),
      'expected_check_out_date': expectedCheckOutDate?.toIso8601String(),
    };
  }

  StudentProfileModel copyWith({
    String? id,
    String? userId,
    String? studentId,
    String? housingUnitId,
    DateTime? enrollmentDate,
    int? academicYear,
    String? program,
    String? emergencyContactName,
    String? emergencyContactPhone,
    double? outstandingBalance,
    DateTime? checkInDate,
    DateTime? expectedCheckOutDate,
    DateTime? createdAt,
    UserModel? user,
    HousingUnitModel? housingUnit,
  }) {
    return StudentProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studentId: studentId ?? this.studentId,
      housingUnitId: housingUnitId ?? this.housingUnitId,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      academicYear: academicYear ?? this.academicYear,
      program: program ?? this.program,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      checkInDate: checkInDate ?? this.checkInDate,
      expectedCheckOutDate: expectedCheckOutDate ?? this.expectedCheckOutDate,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      housingUnit: housingUnit ?? this.housingUnit,
    );
  }
}
