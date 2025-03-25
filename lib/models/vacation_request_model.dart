enum VacationRequestStatus {
  pending,
  supervisorApproved,
  adminApproved,
  rejected
}

class VacationRequestModel {
  final String? id;
  final String studentId;
  final String? studentProfileId;
  final DateTime requestDate;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final VacationRequestStatus status;
  final String? supervisorId;
  final DateTime? supervisorReviewDate;
  final String? adminId;
  final DateTime? adminReviewDate;
  final String? rejectionReason;
  final String? notes;

  VacationRequestModel({
    this.id,
    required this.studentId,
    this.studentProfileId,
    required this.requestDate,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.supervisorId,
    this.supervisorReviewDate,
    this.adminId,
    this.adminReviewDate,
    this.rejectionReason,
    this.notes,
  });

  factory VacationRequestModel.fromJson(Map<String, dynamic> json) {
    return VacationRequestModel(
      id: json['id'],
      studentId: json['student_id'],
      studentProfileId: json['student_profile_id'],
      requestDate: DateTime.parse(json['request_date']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      reason: json['reason'],
      status: _parseStatus(json['status']),
      supervisorId: json['supervisor_id'],
      supervisorReviewDate: json['supervisor_review_date'] != null
          ? DateTime.parse(json['supervisor_review_date'])
          : null,
      adminId: json['admin_id'],
      adminReviewDate: json['admin_review_date'] != null
          ? DateTime.parse(json['admin_review_date'])
          : null,
      rejectionReason: json['rejection_reason'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_profile_id': studentProfileId,
      'request_date': requestDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reason': reason,
      'status': status.toString().split('.').last,
      'supervisor_id': supervisorId,
      'supervisor_review_date': supervisorReviewDate?.toIso8601String(),
      'admin_id': adminId,
      'admin_review_date': adminReviewDate?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'notes': notes,
    };
  }

  VacationRequestModel copyWith({
    String? id,
    String? studentId,
    String? studentProfileId,
    DateTime? requestDate,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    VacationRequestStatus? status,
    String? supervisorId,
    DateTime? supervisorReviewDate,
    String? adminId,
    DateTime? adminReviewDate,
    String? rejectionReason,
    String? notes,
  }) {
    return VacationRequestModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentProfileId: studentProfileId ?? this.studentProfileId,
      requestDate: requestDate ?? this.requestDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      supervisorId: supervisorId ?? this.supervisorId,
      supervisorReviewDate: supervisorReviewDate ?? this.supervisorReviewDate,
      adminId: adminId ?? this.adminId,
      adminReviewDate: adminReviewDate ?? this.adminReviewDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
    );
  }

  int getDurationDays() {
    return endDate.difference(startDate).inDays + 1;
  }

  bool isPending() {
    return status == VacationRequestStatus.pending;
  }

  bool isFullyApproved() {
    return status == VacationRequestStatus.adminApproved;
  }

  bool isRejected() {
    return status == VacationRequestStatus.rejected;
  }

  static VacationRequestStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'supervisorapproved':
        return VacationRequestStatus.supervisorApproved;
      case 'adminapproved':
        return VacationRequestStatus.adminApproved;
      case 'rejected':
        return VacationRequestStatus.rejected;
      case 'pending':
      default:
        return VacationRequestStatus.pending;
    }
  }
}
