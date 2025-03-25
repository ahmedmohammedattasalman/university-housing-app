import 'package:universityhousing/models/user_model.dart';
import 'package:universityhousing/models/housing_unit_model.dart';

enum RegistrationStatus { pending, approved, rejected }

class HousingRegistrationModel {
  final String? id;
  final String studentId;
  final String? studentUserId;
  final String? housingUnitId;
  final DateTime requestDate;
  final String semesterTerm;
  final String academicYear;
  final String roomPreference; // single, double, etc.
  final RegistrationStatus status;
  final String? rejectionReason;
  final DateTime? reviewDate;
  final String? reviewerId;
  final UserModel? student;
  final HousingUnitModel? housingUnit;

  HousingRegistrationModel({
    this.id,
    required this.studentId,
    this.studentUserId,
    this.housingUnitId,
    required this.requestDate,
    required this.semesterTerm,
    required this.academicYear,
    required this.roomPreference,
    required this.status,
    this.rejectionReason,
    this.reviewDate,
    this.reviewerId,
    this.student,
    this.housingUnit,
  });

  factory HousingRegistrationModel.fromJson(Map<String, dynamic> json) {
    return HousingRegistrationModel(
      id: json['id'],
      studentId: json['student_id'],
      studentUserId: json['student_user_id'],
      housingUnitId: json['housing_unit_id'],
      requestDate: DateTime.parse(json['request_date']),
      semesterTerm: json['semester_term'],
      academicYear: json['academic_year'],
      roomPreference: json['room_preference'],
      status: _parseStatus(json['status']),
      rejectionReason: json['rejection_reason'],
      reviewDate: json['review_date'] != null
          ? DateTime.parse(json['review_date'])
          : null,
      reviewerId: json['reviewer_id'],
      student:
          json['student'] != null ? UserModel.fromJson(json['student']) : null,
      housingUnit: json['housing_unit'] != null
          ? HousingUnitModel.fromJson(json['housing_unit'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_user_id': studentUserId,
      'housing_unit_id': housingUnitId,
      'request_date': requestDate.toIso8601String(),
      'semester_term': semesterTerm,
      'academic_year': academicYear,
      'room_preference': roomPreference,
      'status': status.toString().split('.').last,
      'rejection_reason': rejectionReason,
      'review_date': reviewDate?.toIso8601String(),
      'reviewer_id': reviewerId,
    };
  }

  HousingRegistrationModel copyWith({
    String? id,
    String? studentId,
    String? studentUserId,
    String? housingUnitId,
    DateTime? requestDate,
    String? semesterTerm,
    String? academicYear,
    String? roomPreference,
    RegistrationStatus? status,
    String? rejectionReason,
    DateTime? reviewDate,
    String? reviewerId,
    UserModel? student,
    HousingUnitModel? housingUnit,
  }) {
    return HousingRegistrationModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentUserId: studentUserId ?? this.studentUserId,
      housingUnitId: housingUnitId ?? this.housingUnitId,
      requestDate: requestDate ?? this.requestDate,
      semesterTerm: semesterTerm ?? this.semesterTerm,
      academicYear: academicYear ?? this.academicYear,
      roomPreference: roomPreference ?? this.roomPreference,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewerId: reviewerId ?? this.reviewerId,
      student: student ?? this.student,
      housingUnit: housingUnit ?? this.housingUnit,
    );
  }

  static RegistrationStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return RegistrationStatus.approved;
      case 'rejected':
        return RegistrationStatus.rejected;
      case 'pending':
      default:
        return RegistrationStatus.pending;
    }
  }
}
