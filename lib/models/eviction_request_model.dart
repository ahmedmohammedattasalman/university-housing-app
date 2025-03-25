enum EvictionRequestStatus { pending, approved, rejected, executed }

class EvictionRequestModel {
  final String? id;
  final String studentId;
  final String? studentProfileId;
  final DateTime requestDate;
  final DateTime requestedMoveOutDate;
  final String reason;
  final EvictionRequestStatus status;
  final String? adminId;
  final DateTime? adminReviewDate;
  final String? supervisorId;
  final DateTime? executionDate;
  final String? rejectionReason;
  final String? notes;

  EvictionRequestModel({
    this.id,
    required this.studentId,
    this.studentProfileId,
    required this.requestDate,
    required this.requestedMoveOutDate,
    required this.reason,
    required this.status,
    this.adminId,
    this.adminReviewDate,
    this.supervisorId,
    this.executionDate,
    this.rejectionReason,
    this.notes,
  });

  factory EvictionRequestModel.fromJson(Map<String, dynamic> json) {
    return EvictionRequestModel(
      id: json['id'],
      studentId: json['student_id'],
      studentProfileId: json['student_profile_id'],
      requestDate: DateTime.parse(json['request_date']),
      requestedMoveOutDate: DateTime.parse(json['requested_move_out_date']),
      reason: json['reason'],
      status: _parseStatus(json['status']),
      adminId: json['admin_id'],
      adminReviewDate: json['admin_review_date'] != null
          ? DateTime.parse(json['admin_review_date'])
          : null,
      supervisorId: json['supervisor_id'],
      executionDate: json['execution_date'] != null
          ? DateTime.parse(json['execution_date'])
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
      'requested_move_out_date': requestedMoveOutDate.toIso8601String(),
      'reason': reason,
      'status': status.toString().split('.').last,
      'admin_id': adminId,
      'admin_review_date': adminReviewDate?.toIso8601String(),
      'supervisor_id': supervisorId,
      'execution_date': executionDate?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'notes': notes,
    };
  }

  EvictionRequestModel copyWith({
    String? id,
    String? studentId,
    String? studentProfileId,
    DateTime? requestDate,
    DateTime? requestedMoveOutDate,
    String? reason,
    EvictionRequestStatus? status,
    String? adminId,
    DateTime? adminReviewDate,
    String? supervisorId,
    DateTime? executionDate,
    String? rejectionReason,
    String? notes,
  }) {
    return EvictionRequestModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentProfileId: studentProfileId ?? this.studentProfileId,
      requestDate: requestDate ?? this.requestDate,
      requestedMoveOutDate: requestedMoveOutDate ?? this.requestedMoveOutDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      adminId: adminId ?? this.adminId,
      adminReviewDate: adminReviewDate ?? this.adminReviewDate,
      supervisorId: supervisorId ?? this.supervisorId,
      executionDate: executionDate ?? this.executionDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
    );
  }

  bool isPending() {
    return status == EvictionRequestStatus.pending;
  }

  bool isApproved() {
    return status == EvictionRequestStatus.approved;
  }

  bool isRejected() {
    return status == EvictionRequestStatus.rejected;
  }

  bool isExecuted() {
    return status == EvictionRequestStatus.executed;
  }

  int getDaysToMoveOut() {
    final now = DateTime.now();
    if (now.isAfter(requestedMoveOutDate)) {
      return 0;
    }
    return requestedMoveOutDate.difference(now).inDays;
  }

  static EvictionRequestStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return EvictionRequestStatus.approved;
      case 'rejected':
        return EvictionRequestStatus.rejected;
      case 'executed':
        return EvictionRequestStatus.executed;
      case 'pending':
      default:
        return EvictionRequestStatus.pending;
    }
  }
}
