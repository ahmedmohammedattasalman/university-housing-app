import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universityhousing/main.dart';

class SupabaseService {
  // Authentication methods
  Future<AuthResponse> signIn(
      {required String email, required String password}) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userRole,
    String? phoneNumber,
    String? studentId,
  }) async {
    // First create the auth user
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user != null) {
      // Insert the user data into the users table
      await supabase.from('users').insert({
        'id': authResponse.user!.id,
        'email': email,
        'user_role': userRole,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'is_active': true,
      });

      // If user is a student, create student profile
      if (userRole == 'student' && studentId != null) {
        try {
          await supabase.from('student_profiles').insert({
            'user_id': authResponse.user!.id,
            'student_id': studentId,
            'enrollment_date': DateTime.now().toIso8601String(),
            'academic_year': DateTime.now().year.toString(),
            'outstanding_balance': 0.0,
            'check_in_date': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          // Log the error but don't fail registration
          print('Failed to create student profile: $e');
        }
      }
    }

    return authResponse;
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // User profile methods
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final userData =
        await supabase.from('users').select().eq('id', user.id).single();

    // Check if user role is missing and set a default
    if (userData != null &&
        (userData['user_role'] == null ||
            userData['user_role'].toString().isEmpty)) {
      await setDefaultUserRole(user.id);
      // Fetch the updated profile after setting default role
      return await supabase.from('users').select().eq('id', user.id).single();
    }

    return userData;
  }

  Future<Map<String, dynamic>?> getStudentProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase.from('student_profiles').select('''
          *,
          user:user_id(*),
          housing_unit:housing_unit_id(*)
        ''').eq('user_id', user.id).single();

    return data;
  }

  // Housing units methods
  Future<List<Map<String, dynamic>>> getAvailableHousingUnits() async {
    final data =
        await supabase.from('housing_units').select().eq('is_available', true);

    return List<Map<String, dynamic>>.from(data);
  }

  // Attendance methods
  Future<void> recordAttendance({
    required String studentProfileId,
    required String attendanceType,
    String? location,
    String? notes,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await supabase.rpc(
      'record_attendance',
      params: {
        'p_student_id': studentProfileId,
        'p_recorder_id': user.id,
        'p_attendance_type': attendanceType,
        'p_location': location,
        'p_notes': notes,
      },
    );
  }

  // Vacation request methods
  Future<void> submitVacationRequest({
    required String studentProfileId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    await supabase.from('vacation_requests').insert({
      'student_id': studentProfileId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reason': reason,
    });
  }

  Future<List<Map<String, dynamic>>> getVacationRequests() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final profileData = await supabase
        .from('student_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    final studentProfileId = profileData['id'];

    final data = await supabase
        .from('vacation_requests')
        .select()
        .eq('student_id', studentProfileId);

    return List<Map<String, dynamic>>.from(data);
  }

  // Eviction request methods
  Future<void> submitEvictionRequest({
    required String studentProfileId,
    required DateTime moveOutDate,
    required String reason,
  }) async {
    await supabase.from('eviction_requests').insert({
      'student_id': studentProfileId,
      'requested_move_out_date': moveOutDate.toIso8601String(),
      'reason': reason,
    });
  }

  // Payment methods
  Future<void> processPayment({
    required String studentProfileId,
    required double amount,
    required String paymentMethod,
    required String paymentType,
    String? referenceNumber,
    Map<String, dynamic>? transactionDetails,
    String? notes,
  }) async {
    await supabase.rpc(
      'process_payment',
      params: {
        'p_student_id': studentProfileId,
        'p_amount': amount,
        'p_payment_method': paymentMethod,
        'p_payment_type': paymentType,
        'p_reference_number': referenceNumber,
        'p_transaction_details': transactionDetails,
        'p_notes': notes,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final profileData = await supabase
        .from('student_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    final studentProfileId = profileData['id'];

    final data = await supabase
        .from('payments')
        .select()
        .eq('student_id', studentProfileId)
        .order('payment_date', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // Notifications methods
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final data = await supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  // Add a function to set default user role if missing
  Future<void> setDefaultUserRole(String userId) async {
    try {
      // Check if user exists in student_profiles
      final studentProfile = await supabase
          .from('student_profiles')
          .select('id')
          .eq('user_id', userId);

      String defaultRole = 'student';

      // If no student profile exists, set role to a general user
      if (studentProfile == null || studentProfile.isEmpty) {
        defaultRole = 'general';
      }

      // Update the user record with the default role
      await supabase.from('users').update({
        'user_role': defaultRole,
      }).eq('id', userId);

      print('Set default user role: $defaultRole for user: $userId');
    } catch (e) {
      print('Error setting default user role: $e');
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    // Validate role
    final validRoles = ['student', 'admin', 'supervisor', 'labor', 'general'];
    if (!validRoles.contains(role)) {
      throw Exception('Invalid role: $role. Must be one of $validRoles');
    }

    // Update the user record
    await supabase.from('users').update({
      'user_role': role,
    }).eq('id', userId);

    // If updating to student role, check if student profile exists
    if (role == 'student') {
      final studentProfile = await supabase
          .from('student_profiles')
          .select('id')
          .eq('user_id', userId);

      // If no student profile exists, create one
      if (studentProfile == null || studentProfile.isEmpty) {
        await supabase.from('student_profiles').insert({
          'user_id': userId,
          'enrollment_date': DateTime.now().toIso8601String(),
          'academic_year': DateTime.now().year.toString(),
          'outstanding_balance': 0.0,
        });
      }
    }
  }

  // Housing registration methods
  Future<void> submitHousingRegistration({
    required String studentId,
    required String semesterTerm,
    required String academicYear,
    required String roomPreference,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get student profile id
    final studentProfile = await supabase
        .from('student_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    await supabase.from('housing_registrations').insert({
      'student_id': studentId,
      'student_user_id': user.id,
      'request_date': DateTime.now().toIso8601String(),
      'semester_term': semesterTerm,
      'academic_year': academicYear,
      'room_preference': roomPreference,
      'status': 'pending',
      'student_profile_id': studentProfile['id'],
    });
  }

  Future<List<Map<String, dynamic>>> getHousingRegistrations({
    String? status,
    bool includeDetails = false,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userProfile = await getCurrentUserProfile();
    final isAdmin = userProfile != null && userProfile['user_role'] == 'admin';

    // Build query based on details needed
    String query = '*';
    if (includeDetails) {
      query = '''
        *,
        student:student_user_id(
          id,
          email,
          first_name,
          last_name,
          phone_number
        ),
        housing_unit:housing_unit_id(*)
      ''';
    }

    // Apply filters based on user role
    final registrationsQuery =
        supabase.from('housing_registrations').select(query);

    if (isAdmin) {
      // Admins can see all registrations or filtered by status
      if (status != null) {
        return await registrationsQuery
            .eq('status', status)
            .order('request_date', ascending: false);
      }
      return await registrationsQuery.order('request_date', ascending: false);
    } else {
      // Students can only see their own registrations
      if (status != null) {
        return await registrationsQuery
            .eq('student_user_id', user.id)
            .eq('status', status)
            .order('request_date', ascending: false);
      }
      return await registrationsQuery
          .eq('student_user_id', user.id)
          .order('request_date', ascending: false);
    }
  }

  Future<void> reviewHousingRegistration({
    required String registrationId,
    required String decision,
    String? housingUnitId,
    String? rejectionReason,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userProfile = await getCurrentUserProfile();
    if (userProfile == null || userProfile['user_role'] != 'admin') {
      throw Exception('Only administrators can review registrations');
    }

    final updateData = {
      'status': decision,
      'review_date': DateTime.now().toIso8601String(),
      'reviewer_id': user.id,
    };

    if (decision == 'approved') {
      if (housingUnitId == null) {
        throw Exception('Housing unit ID is required for approval');
      }
      updateData['housing_unit_id'] = housingUnitId;

      // Mark the housing unit as occupied
      await supabase
          .from('housing_units')
          .update({'is_available': false}).eq('id', housingUnitId);
    } else if (decision == 'rejected') {
      if (rejectionReason == null) {
        throw Exception('Rejection reason is required');
      }
      updateData['rejection_reason'] = rejectionReason;
    }

    await supabase
        .from('housing_registrations')
        .update(updateData)
        .eq('id', registrationId);
  }

  // Payment processing methods
  Future<void> initiatePayment({
    required double amount,
    required String paymentMethod,
    required String paymentType,
    String? referenceNumber,
    Map<String, dynamic>? transactionDetails,
    String? notes,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get student profile id
    final studentProfile = await supabase
        .from('student_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    await supabase.from('payments').insert({
      'student_id': user.id,
      'student_profile_id': studentProfile['id'],
      'amount': amount,
      'payment_date': DateTime.now().toIso8601String(),
      'status': 'pending',
      'payment_method': paymentMethod,
      'payment_type': paymentType,
      'reference_number': referenceNumber,
      'transaction_details': transactionDetails,
      'notes': notes,
    });
  }

  Future<Map<String, dynamic>> completePayment({
    required String paymentId,
    required bool isSuccessful,
    String? receiptNumber,
    String? failureReason,
  }) async {
    final updateData = {
      'status': isSuccessful ? 'completed' : 'failed',
    };

    if (isSuccessful) {
      updateData['receipt_number'] = receiptNumber;
    } else {
      updateData['notes'] = failureReason;
    }

    final result = await supabase
        .from('payments')
        .update(updateData)
        .eq('id', paymentId)
        .select()
        .single();

    // If payment is successful, update student outstanding balance
    if (isSuccessful) {
      await _updateStudentBalance(
        result['student_profile_id'],
        (result['amount'] as num).toDouble(),
      );
    }

    return result;
  }

  Future<void> _updateStudentBalance(
      String studentProfileId, double paymentAmount) async {
    // Get current balance
    final studentProfile = await supabase
        .from('student_profiles')
        .select('outstanding_balance')
        .eq('id', studentProfileId)
        .single();

    final currentBalance =
        (studentProfile['outstanding_balance'] as num).toDouble();
    final newBalance = currentBalance - paymentAmount;

    // Update balance
    await supabase
        .from('student_profiles')
        .update({'outstanding_balance': newBalance}).eq('id', studentProfileId);
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userProfile = await getCurrentUserProfile();
    final isAdmin = userProfile != null &&
        (userProfile['user_role'] == 'admin' ||
            userProfile['user_role'] == 'supervisor');

    if (isAdmin) {
      return await supabase.from('payments').select('''
            *,
            student:student_id(
              id, 
              first_name, 
              last_name
            )
          ''').order('payment_date', ascending: false);
    }

    // For students, only show their own payments
    final studentProfile = await supabase
        .from('student_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    return await supabase
        .from('payments')
        .select()
        .eq('student_profile_id', studentProfile['id'])
        .order('payment_date', ascending: false);
  }

  // Attendance tracking methods
  Future<void> recordAttendance({
    required String attendanceType,
    String? location,
    bool requestMeal = false,
    String? notes,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get student profile id
    final studentProfile = await supabase
        .from('student_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    await supabase.from('attendance_records').insert({
      'student_id': user.id,
      'student_profile_id': studentProfile['id'],
      'timestamp': DateTime.now().toIso8601String(),
      'attendance_type': attendanceType,
      'location': location,
      'recorded_by': user.id,
      'is_meal_requested': requestMeal,
      'notes': notes,
    });
  }

  Future<void> confirmMeal(String attendanceId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if the user is authorized (restaurant staff or admin)
    final userProfile = await getCurrentUserProfile();
    final isAuthorized = userProfile != null &&
        (userProfile['user_role'] == 'labor' ||
            userProfile['user_role'] == 'admin');

    if (!isAuthorized) {
      throw Exception('Only authorized staff can confirm meals');
    }

    await supabase.from('attendance_records').update({
      'is_meal_confirmed': true,
      'notes':
          'Meal confirmed by ${userProfile['first_name']} ${userProfile['last_name']}',
    }).eq('id', attendanceId);
  }

  Future<List<Map<String, dynamic>>> getAttendanceRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? attendanceType,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userProfile = await getCurrentUserProfile();
    final isAdmin = userProfile != null &&
        (userProfile['user_role'] == 'admin' ||
            userProfile['user_role'] == 'supervisor');

    // Base query
    var query = supabase.from('attendance_records').select('''
      *,
      student:student_id(
        id, 
        first_name, 
        last_name
      )
    ''');

    // Apply filters
    if (startDate != null) {
      query = query.gte('timestamp', startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.lte('timestamp', endDate.toIso8601String());
    }

    if (attendanceType != null) {
      query = query.eq('attendance_type', attendanceType);
    }

    // Filter by user if not admin
    if (!isAdmin) {
      query = query.eq('student_id', user.id);
    }

    return await query.order('timestamp', ascending: false);
  }

  // Vacation request methods
  Future<void> submitVacationRequest({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get student profile id
    final studentProfile = await supabase
        .from('student_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    await supabase.from('vacation_requests').insert({
      'student_id': user.id,
      'student_profile_id': studentProfile['id'],
      'request_date': DateTime.now().toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reason': reason,
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getVacationRequests({
    String? status,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userProfile = await getCurrentUserProfile();
    final userRole = userProfile?['user_role'];

    // Base query with student details
    var query = supabase.from('vacation_requests').select('''
      *,
      student:student_id(
        id, 
        first_name, 
        last_name,
        user_role
      )
    ''');

    // Apply status filter if provided
    if (status != null) {
      query = query.eq('status', status);
    }

    // Filter based on role
    if (userRole == 'admin') {
      // Admins see all requests for final approval
      return await query.order('request_date', ascending: false);
    } else if (userRole == 'supervisor') {
      // Supervisors see pending or supervisor-approved requests
      return await query.in_('status', ['pending', 'supervisorApproved']).order(
          'request_date',
          ascending: false);
    } else {
      // Students see only their own requests
      return await query
          .eq('student_id', user.id)
          .order('request_date', ascending: false);
    }
  }

  Future<void> reviewVacationRequest({
    required String requestId,
    required String decision,
    String? rejectionReason,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userProfile = await getCurrentUserProfile();
    final userRole = userProfile?['user_role'];

    if (userRole != 'supervisor' && userRole != 'admin') {
      throw Exception('Only supervisors and admins can review requests');
    }

    final updateData = {};

    // Handle different approval flows based on role
    if (userRole == 'supervisor') {
      if (decision == 'approved') {
        updateData['status'] = 'supervisorApproved';
        updateData['supervisor_id'] = user.id;
        updateData['supervisor_review_date'] = DateTime.now().toIso8601String();
      } else {
        updateData['status'] = 'rejected';
        updateData['rejection_reason'] = rejectionReason;
        updateData['supervisor_id'] = user.id;
        updateData['supervisor_review_date'] = DateTime.now().toIso8601String();
      }
    } else if (userRole == 'admin') {
      if (decision == 'approved') {
        updateData['status'] = 'adminApproved';
        updateData['admin_id'] = user.id;
        updateData['admin_review_date'] = DateTime.now().toIso8601String();
      } else {
        updateData['status'] = 'rejected';
        updateData['rejection_reason'] = rejectionReason;
        updateData['admin_id'] = user.id;
        updateData['admin_review_date'] = DateTime.now().toIso8601String();
      }
    }

    await supabase
        .from('vacation_requests')
        .update(updateData)
        .eq('id', requestId);
  }

  // Eviction request methods
  Future<void> submitEvictionRequest({
    required DateTime moveOutDate,
    required String reason,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get student profile id
    final studentProfile = await supabase
        .from('student_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    await supabase.from('eviction_requests').insert({
      'student_id': user.id,
      'student_profile_id': studentProfile['id'],
      'request_date': DateTime.now().toIso8601String(),
      'requested_move_out_date': moveOutDate.toIso8601String(),
      'reason': reason,
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getEvictionRequests({
    String? status,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userProfile = await getCurrentUserProfile();
    final userRole = userProfile?['user_role'];

    // Base query with student details
    var query = supabase.from('eviction_requests').select('''
      *,
      student:student_id(
        id, 
        first_name, 
        last_name,
        email
      ),
      student_profile:student_profile_id(
        id,
        housing_unit_id
      ),
      housing_unit:student_profile!housing_unit_id(
        id,
        building_name,
        room_number
      )
    ''');

    // Apply status filter if provided
    if (status != null) {
      query = query.eq('status', status);
    }

    // Filter based on role
    if (userRole == 'admin') {
      // Admins see all requests
      return await query.order('request_date', ascending: false);
    } else if (userRole == 'supervisor') {
      // Supervisors see approved requests that need execution
      return await query
          .eq('status', 'approved')
          .order('request_date', ascending: false);
    } else {
      // Students see only their own requests
      return await query
          .eq('student_id', user.id)
          .order('request_date', ascending: false);
    }
  }

  Future<void> reviewEvictionRequest({
    required String requestId,
    required String decision,
    String? rejectionReason,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userProfile = await getCurrentUserProfile();
    if (userProfile == null || userProfile['user_role'] != 'admin') {
      throw Exception('Only administrators can review eviction requests');
    }

    final updateData = {
      'status': decision,
      'admin_id': user.id,
      'admin_review_date': DateTime.now().toIso8601String(),
    };

    if (decision == 'rejected') {
      if (rejectionReason == null) {
        throw Exception('Rejection reason is required');
      }
      updateData['rejection_reason'] = rejectionReason;
    }

    await supabase
        .from('eviction_requests')
        .update(updateData)
        .eq('id', requestId);
  }

  Future<void> executeEviction({
    required String requestId,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userProfile = await getCurrentUserProfile();
    if (userProfile == null || userProfile['user_role'] != 'supervisor') {
      throw Exception('Only supervisors can execute evictions');
    }

    // Get the request details
    final request = await supabase
        .from('eviction_requests')
        .select('student_profile_id, status')
        .eq('id', requestId)
        .single();

    if (request['status'] != 'approved') {
      throw Exception('Only approved eviction requests can be executed');
    }

    // Get student profile to retrieve housing unit
    final studentProfile = await supabase
        .from('student_profiles')
        .select('housing_unit_id')
        .eq('id', request['student_profile_id'])
        .single();

    // Execute the eviction in a transaction using Supabase's rpc
    await supabase.rpc('execute_eviction', {
      'p_request_id': requestId,
      'p_supervisor_id': user.id,
      'p_housing_unit_id': studentProfile['housing_unit_id'],
    });
  }
}
