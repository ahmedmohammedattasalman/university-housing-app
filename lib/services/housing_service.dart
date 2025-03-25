import 'package:universityhousing/main.dart';
import 'package:universityhousing/services/supabase_service.dart';
import 'package:universityhousing/models/vacation_request_model.dart';
import 'package:universityhousing/models/eviction_request_model.dart';

class HousingService {
  final SupabaseService _supabaseService = SupabaseService();

  // PAYMENT METHODS
  Future<void> initiatePayment({
    required double amount,
    required String paymentMethod,
    required String paymentType,
    String? referenceNumber,
    Map<String, dynamic>? transactionDetails,
    String? notes,
  }) async {
    await _supabaseService.initiatePayment(
      amount: amount,
      paymentMethod: paymentMethod,
      paymentType: paymentType,
      referenceNumber: referenceNumber,
      transactionDetails: transactionDetails,
      notes: notes,
    );
  }

  Future<Map<String, dynamic>> completePayment({
    required String paymentId,
    required bool isSuccessful,
    String? receiptNumber,
    String? failureReason,
  }) async {
    return await _supabaseService.completePayment(
      paymentId: paymentId,
      isSuccessful: isSuccessful,
      receiptNumber: receiptNumber,
      failureReason: failureReason,
    );
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final results = await _supabaseService.getAllPaymentHistory();

    // Filter by date if provided
    if (startDate != null || endDate != null) {
      return results.where((payment) {
        final paymentDate = DateTime.parse(payment['payment_date']);
        if (startDate != null && paymentDate.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && paymentDate.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();
    }

    return results;
  }

  // HOUSING REGISTRATION METHODS
  Future<void> submitHousingRegistration({
    required String semesterTerm,
    required String academicYear,
    required String roomPreference,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get student profile to retrieve student ID
    final studentProfile = await _supabaseService.getStudentProfile();
    if (studentProfile == null) {
      throw Exception('Student profile not found');
    }

    final studentId = studentProfile['student_id'] ?? '';

    await _supabaseService.submitHousingRegistration(
      studentId: studentId,
      semesterTerm: semesterTerm,
      academicYear: academicYear,
      roomPreference: roomPreference,
    );
  }

  Future<List<Map<String, dynamic>>> getHousingRegistrations({
    String? status,
    bool includeDetails = false,
  }) async {
    return await _supabaseService.getHousingRegistrations(
      status: status,
      includeDetails: includeDetails,
    );
  }

  Future<void> reviewHousingRegistration({
    required String registrationId,
    required String decision,
    String? housingUnitId,
    String? rejectionReason,
  }) async {
    await _supabaseService.reviewHousingRegistration(
      registrationId: registrationId,
      decision: decision,
      housingUnitId: housingUnitId,
      rejectionReason: rejectionReason,
    );
  }

  // ATTENDANCE TRACKING METHODS
  Future<void> recordAttendance({
    required String attendanceType,
    String? location,
    bool requestMeal = false,
    bool? isMealRequested,
    String? notes,
    String? userId,
  }) async {
    await _supabaseService.recordAttendance(
      attendanceType: attendanceType,
      location: location,
      requestMeal: isMealRequested ?? requestMeal,
      notes: notes,
    );
  }

  Future<void> confirmMeal(String attendanceId) async {
    await _supabaseService.confirmMeal(attendanceId);
  }

  Future<List<Map<String, dynamic>>> getAttendanceRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? attendanceType,
    String? userId,
    String? filterByType,
  }) async {
    return await _supabaseService.getAttendanceRecords(
      startDate: startDate,
      endDate: endDate,
      attendanceType: filterByType ?? attendanceType,
    );
  }

  // VACATION REQUEST METHODS
  Future<void> submitVacationRequest({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    await _supabaseService.createVacationRequest(
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }

  Future<List<Map<String, dynamic>>> getVacationRequests({
    String? status,
  }) async {
    return await _supabaseService.getAllVacationRequests(status: status);
  }

  Future<void> reviewVacationRequest({
    required String requestId,
    required String decision,
    String? rejectionReason,
  }) async {
    await _supabaseService.reviewVacationRequest(
      requestId: requestId,
      decision: decision,
      rejectionReason: rejectionReason,
    );
  }

  // EVICTION REQUEST METHODS
  Future<void> submitEvictionRequest({
    required DateTime moveOutDate,
    required String reason,
  }) async {
    await _supabaseService.createEvictionRequest(
      moveOutDate: moveOutDate,
      reason: reason,
    );
  }

  Future<List<Map<String, dynamic>>> getEvictionRequests({
    String? status,
  }) async {
    return await _supabaseService.getEvictionRequests(status: status);
  }

  Future<void> reviewEvictionRequest({
    required String requestId,
    required String decision,
    String? rejectionReason,
  }) async {
    await _supabaseService.reviewEvictionRequest(
      requestId: requestId,
      decision: decision,
      rejectionReason: rejectionReason,
    );
  }

  Future<void> executeEviction({
    required String requestId,
  }) async {
    await _supabaseService.executeEviction(requestId: requestId);
  }

  // BACKWARD COMPATIBILITY METHODS

  // Backward compatibility for vacation requests with student ID
  Future<void> submitVacationRequestWithStudentId({
    String? studentId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? contactInfo,
  }) async {
    await _supabaseService.createVacationRequest(
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }

  // Backward compatibility for eviction requests with additional parameters
  Future<void> submitEvictionRequestWithAdminId({
    String? adminId,
    String? studentId,
    required DateTime moveOutDate,
    required String reason,
    String? notes,
  }) async {
    await _supabaseService.createEvictionRequest(
      moveOutDate: moveOutDate,
      reason: reason,
    );
  }

  // Backward compatibility for review eviction with additional parameters
  Future<void> reviewEvictionRequestWithStatus({
    required String requestId,
    String? reviewerId,
    required EvictionRequestStatus newStatus,
    String? feedback,
  }) async {
    String decision;
    switch (newStatus) {
      case EvictionRequestStatus.approved:
        decision = 'approved';
        break;
      case EvictionRequestStatus.rejected:
        decision = 'rejected';
        break;
      default:
        decision = 'pending';
        break;
    }

    await _supabaseService.reviewEvictionRequest(
      requestId: requestId,
      decision: decision,
      rejectionReason: feedback,
    );
  }

  // Backward compatibility for execute eviction with additional parameters
  Future<void> executeEvictionWithExtras({
    required String requestId,
    String? executedById,
    String? housingUnitId,
  }) async {
    await _supabaseService.executeEviction(
      requestId: requestId,
    );
  }

  // Backward compatibility for vacation requests with different filters
  Future<List<VacationRequestModel>> getVacationRequestsAsModel({
    VacationRequestStatus? statusFilter,
    String? studentId,
  }) async {
    String? statusStr;
    if (statusFilter != null) {
      statusStr = statusFilter.toString().split('.').last;
    }

    final results =
        await _supabaseService.getAllVacationRequests(status: statusStr);

    return results.map((data) => VacationRequestModel.fromJson(data)).toList();
  }

  // Backward compatibility for eviction requests with different filters
  Future<List<EvictionRequestModel>> getEvictionRequestsAsModel({
    EvictionRequestStatus? statusFilter,
    String? userRole,
    String? userId,
  }) async {
    String? statusStr;
    if (statusFilter != null) {
      statusStr = statusFilter.toString().split('.').last;
    }

    final results =
        await _supabaseService.getEvictionRequests(status: statusStr);

    return results.map((data) => EvictionRequestModel.fromJson(data)).toList();
  }
}
