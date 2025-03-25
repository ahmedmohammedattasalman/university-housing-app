import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universityhousing/services/supabase_service.dart';
import 'package:universityhousing/services/supabase_client_wrapper.dart';
import 'package:universityhousing/main.dart';

class AuthProvider extends ChangeNotifier {
  final _supabaseService = SupabaseService();
  User? _user;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _studentProfile;
  Map<String, dynamic>? _userPermissions;
  bool _isLoading = false;
  String? _error;
  String _userRole = '';
  String _firstName = '';
  String _lastName = '';
  String _studentId = '';
  String? _phoneNumber;
  String? _emergencyContact;
  String? _emergencyPhone;
  String _roomNumber = 'Not Assigned';
  String _housingStatus = 'Pending';
  double _outstandingBalance = 0.0;
  DateTime _checkInDate = DateTime.now();

  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  Map<String, dynamic>? get studentProfile => _studentProfile;
  Map<String, dynamic>? get userPermissions => _userPermissions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String get userRole => _userRole;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get studentName => '$_firstName $_lastName';
  String get studentId => _studentId;
  String? get phoneNumber => _phoneNumber;
  String? get emergencyContact => _emergencyContact;
  String? get emergencyPhone => _emergencyPhone;
  String get roomNumber => _roomNumber;
  String get housingStatus => _housingStatus;
  double get outstandingBalance => _outstandingBalance;
  DateTime get checkInDate => _checkInDate;

  // User role getters
  bool get isStudent =>
      _userProfile != null && _userProfile!['user_role'] == 'student';
  bool get isAdmin =>
      _userProfile != null && _userProfile!['user_role'] == 'admin';
  bool get isSupervisor =>
      _userProfile != null && _userProfile!['user_role'] == 'supervisor';
  bool get isLabor =>
      _userProfile != null && _userProfile!['user_role'] == 'labor';
  bool get isGeneral =>
      _userProfile != null && _userProfile!['user_role'] == 'general';

  // Check if user has a valid recognized role
  bool get hasValidRole =>
      isStudent || isAdmin || isSupervisor || isLabor || isGeneral;

  // Permission check helpers
  bool hasPermission(String permission) {
    if (_userPermissions == null) return false;
    return _userPermissions![permission] == true;
  }

  // Common permission getters
  bool get canViewHousing => hasPermission('can_view_housing') || isAdmin;
  bool get canManageHousing => hasPermission('can_manage_housing') || isAdmin;
  bool get canAssignHousing => hasPermission('can_assign_housing') || isAdmin;
  bool get canRequestHousing =>
      hasPermission('can_request_housing') || isStudent;

  bool get canViewAttendance => hasPermission('can_view_attendance') || isAdmin;
  bool get canRecordAttendance =>
      hasPermission('can_record_attendance') || isAdmin || isSupervisor;

  bool get canViewPayments => hasPermission('can_view_payments') || isAdmin;
  bool get canMakePayments => hasPermission('can_make_payments') || isStudent;
  bool get canProcessPayments =>
      hasPermission('can_process_payments') || isAdmin;

  bool get canManageUsers => hasPermission('can_manage_users') || isAdmin;

  bool get canViewMaintenance =>
      hasPermission('can_view_maintenance') || isAdmin || isLabor;
  bool get canRequestMaintenance =>
      hasPermission('can_request_maintenance') || isStudent;
  bool get canPerformMaintenance =>
      hasPermission('can_perform_maintenance') || isLabor;
  bool get canUpdateMaintenance =>
      hasPermission('can_update_maintenance') || isLabor;
  bool get canManageMaintenance =>
      hasPermission('can_manage_maintenance') || isAdmin || isSupervisor;

  bool get canViewReports =>
      hasPermission('can_view_reports') || isAdmin || isSupervisor;

  bool get canPostAnnouncements =>
      hasPermission('can_post_announcements') || isAdmin || isSupervisor;
  bool get canViewAnnouncements =>
      hasPermission('can_view_announcements') ||
      true; // Everyone can view announcements

  // Constructor - Check if user is already logged in
  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _user = Supabase.instance.client.auth.currentUser;
    if (_user != null) {
      await _loadUserProfile();
    }
  }

  // Load user profile from database
  Future<void> _loadUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userProfile = await _supabaseService.getCurrentUserProfile();

      if (_userProfile == null) {
        print("No user profile found, creating basic profile");
        // Create a basic user profile if it doesn't exist
        if (_user != null) {
          try {
            // First just set a default role directly in the database
            await supabase.from('users').upsert({
              'id': _user!.id,
              'email': _user!.email,
              'user_role': 'student', // Default role
              'first_name': _user!.userMetadata?['first_name'] ?? 'User',
              'last_name': _user!.userMetadata?['last_name'] ?? '',
              'is_active': true,
            });

            // Then try to get the profile again
            _userProfile = await _supabaseService.getCurrentUserProfile();
          } catch (e) {
            print("Error creating basic profile: $e");
          }
        }
      }

      // If user is student, load student profile
      if (isStudent) {
        try {
          _studentProfile = await _supabaseService.getStudentProfile();

          // If no student profile exists, create one
          if (_studentProfile == null && _user != null) {
            print("No student profile found, creating basic student profile");
            try {
              await supabase.from('student_profiles').insert({
                'user_id': _user!.id,
                'student_id': 'S${DateTime.now().millisecondsSinceEpoch}',
                'enrollment_date': DateTime.now().toIso8601String(),
                'academic_year': DateTime.now().year.toString(),
                'outstanding_balance': 0.0,
                'check_in_date': DateTime.now().toIso8601String(),
              });

              // Try to get the profile again
              _studentProfile = await _supabaseService.getStudentProfile();
            } catch (e) {
              print("Error creating student profile: $e");
            }
          }
        } catch (e) {
          print("Error loading student profile: $e");
        }
      }

      // Load user permissions
      await _loadUserPermissions();

      if (_userProfile != null) {
        _userRole = _userProfile!['user_role'] ?? 'student';
        _firstName = _userProfile!['first_name'] ?? '';
        _lastName = _userProfile!['last_name'] ?? '';
        _phoneNumber = _userProfile!['phone_number'];
        _emergencyContact = _userProfile!['emergency_contact'];
        _emergencyPhone = _userProfile!['emergency_phone'];

        if (_userRole == 'student' && _studentProfile != null) {
          _studentId = _studentProfile!['student_id'] ?? '';
          _roomNumber = _studentProfile!['room_number'] ?? 'Not Assigned';
          _housingStatus = _studentProfile!['housing_status'] ?? 'Pending';
          _outstandingBalance =
              (_studentProfile!['outstanding_balance'] as num?)?.toDouble() ??
                  0.0;
          _checkInDate = _studentProfile!['check_in_date'] != null
              ? DateTime.parse(_studentProfile!['check_in_date'])
              : DateTime.now();
        }
      } else {
        // Set default values if profile is still null
        _userRole = 'student';
        _firstName = _user?.userMetadata?['first_name'] ?? 'User';
        _lastName = _user?.userMetadata?['last_name'] ?? '';
      }
    } catch (e) {
      _error = 'Failed to load user profile: ${e.toString()}';
      print("Error in _loadUserProfile: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user permissions
  Future<void> _loadUserPermissions() async {
    try {
      if (_user == null) return;

      print("Loading permissions for user: ${_user!.id}");

      // Get user permissions from the database
      try {
        final data = await supabase
            .from('user_permissions')
            .select()
            .eq('user_id', _user!.id)
            .maybeSingle();

        if (data != null) {
          _userPermissions = data;
          print("Loaded user permissions: $_userPermissions");
        } else {
          print("No permissions found, setting default based on role");
          // Set default permissions based on user role if none exist
          if (_userProfile != null) {
            await _supabaseService.setupRoleBasedAccess(
                _user!.id, _userProfile!['user_role'] ?? 'student');

            // Try to load permissions again
            final updatedData = await supabase
                .from('user_permissions')
                .select()
                .eq('user_id', _user!.id)
                .maybeSingle();

            if (updatedData != null) {
              _userPermissions = updatedData;
              print("Loaded default permissions: $_userPermissions");
            }
          }
        }
      } catch (e) {
        print("Error loading permissions: $e");
      }
    } catch (e) {
      print("Error in _loadUserPermissions: $e");
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password, {String? userRole}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Special case for test account with preknown credentials
      if (email.toLowerCase() == 'ahmedatta@gmail.com' &&
          password == '12341234') {
        print('Special login handling for test account');

        try {
          // Try to sign in first
          final response = await _supabaseService.signIn(
            email: email,
            password: password,
          );

          _user = response.user;

          // If login successful, check if profile exists
          if (_user != null) {
            await _loadUserProfile();

            // Force set role to student regardless of current role
            if (_user != null) {
              try {
                print('Setting role directly in database for test account');
                await supabase.from('users').upsert({
                  'id': _user!.id,
                  'email': _user!.email,
                  'user_role': 'student',
                  'first_name': 'Ahmed',
                  'last_name': 'Atta',
                  'is_active': true,
                }, onConflict: 'id');

                // Ensure student profile exists
                try {
                  print('Ensuring student profile exists');
                  final studentCheckResponse = await supabase
                      .from('student_profiles')
                      .select('id')
                      .eq('user_id', _user!.id);

                  if (studentCheckResponse == null ||
                      (studentCheckResponse as List).isEmpty) {
                    print('Creating student profile for test account');
                    await supabase.from('student_profiles').insert({
                      'user_id': _user!.id,
                      'student_id': 'S12345',
                      'enrollment_date': DateTime.now().toIso8601String(),
                      'academic_year': '2023',
                      'program': 'Computer Science',
                      'outstanding_balance': 0.0,
                      'check_in_date': DateTime.now().toIso8601String(),
                    });
                  } else {
                    print('Student profile already exists');
                  }
                } catch (profileError) {
                  print('Error with student profile: $profileError');
                }

                // Reload profile to get updated data
                await _loadUserProfile();
                _userRole = 'student'; // Force set role in memory
              } catch (roleError) {
                print('Error setting role for test account: $roleError');
                // Continue anyway
              }
            }
            return true;
          }
        } catch (loginError) {
          print('Error logging in: $loginError - trying to create account');

          // If login fails, try to create the account
          try {
            final signUpResponse = await _supabaseService.signUp(
              email: email,
              password: password,
              firstName: 'Ahmed',
              lastName: 'Atta',
              userRole: 'student',
            );

            _user = signUpResponse.user;

            if (_user != null) {
              await _loadUserProfile();
              return true;
            }
          } catch (signUpError) {
            print('Error creating account: $signUpError');
            _error = 'Could not sign in or create test account';
            return false;
          }
        }
      }

      // Normal flow for non-test accounts
      print('Starting regular login process for email: $email');
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      _user = response.user;

      if (_user != null) {
        print('User authenticated successfully, loading profile');
        await _loadUserProfile();

        // Always ensure user has permissions - this is critical
        bool permissionsLoaded = await _ensureUserPermissions();
        if (!permissionsLoaded) {
          print('WARNING: Could not load or create user permissions');
          // We will continue login but with potentially limited access
        }

        // Check user role if specified at login
        if (userRole != null && _userProfile != null) {
          final actualRole = _userProfile!['user_role'];
          print('Actual role: $actualRole, Selected role at login: $userRole');

          // More flexible approach based on permissions rather than just role titles
          // Check based on specific permission requirements for each role type
          if (userRole == 'admin' && !isAdmin && !hasPermission('is_admin')) {
            _error = 'Access denied. You do not have administrator privileges.';
            await signOut();
            return false;
          } else if (userRole == 'supervisor' &&
              !isSupervisor &&
              !isAdmin &&
              !hasPermission('can_manage_maintenance')) {
            _error = 'Access denied. You do not have supervisor privileges.';
            await signOut();
            return false;
          } else if (userRole == 'labor' &&
              !isLabor &&
              !isSupervisor &&
              !isAdmin &&
              !hasPermission('can_perform_maintenance')) {
            _error = 'Access denied. You do not have labor staff privileges.';
            await signOut();
            return false;
          }

          // For student role access, we're more permissive - anyone can access student features
        }

        // Check if user is active
        if (_userProfile != null && _userProfile!['is_active'] == false) {
          _error =
              'Your account has been deactivated. Please contact the administrator.';
          await signOut();
          return false;
        }

        return true;
      } else {
        _error = 'Invalid email or password.';
        return false;
      }
    } catch (e) {
      _error = 'Sign in failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to ensure user has permissions
  Future<bool> _ensureUserPermissions() async {
    if (_user == null || _userProfile == null) {
      return false;
    }

    try {
      print('Ensuring user has permissions: ${_user!.id}');

      // First try loading permissions
      await _loadUserPermissions();

      // If still no permissions, try to create them
      if (_userPermissions == null || _userPermissions!.isEmpty) {
        print(
            'No permissions found, creating permissions for role: $_userRole');

        try {
          // Create permissions based on user's role
          await _supabaseService.setupRoleBasedAccess(_user!.id, _userRole);

          // Try loading permissions again
          await _loadUserPermissions();

          // Check if we succeeded
          if (_userPermissions != null && _userPermissions!.isNotEmpty) {
            print('Successfully created permissions during login');
            return true;
          } else {
            print('Failed to create permissions during login');
            return false;
          }
        } catch (e) {
          print('Error creating permissions: $e');
          return false;
        }
      }

      return true; // Permissions were already loaded
    } catch (e) {
      print('Error in _ensureUserPermissions: $e');
      return false;
    }
  }

  // Sign up new user
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userRole,
    String? phoneNumber,
    String? studentId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        userRole: userRole,
        phoneNumber: phoneNumber,
        studentId: studentId,
      );

      _user = response.user;

      if (_user != null) {
        await _loadUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Sign up failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabaseService.signOut();

      // Clear user data
      _user = null;
      _userProfile = null;
      _studentProfile = null;
      _userPermissions = null;
      _userRole = '';
      _firstName = '';
      _lastName = '';
      _studentId = '';
      _phoneNumber = null;
      _emergencyContact = null;
      _emergencyPhone = null;
      _roomNumber = 'Not Assigned';
      _housingStatus = 'Pending';
      _outstandingBalance = 0.0;
    } catch (e) {
      _error = 'Sign out failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user role
  Future<void> updateUserRole(String newRole) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user != null) {
        await _supabaseService.updateUserRole(_user!.id, newRole);

        // Reload user profile to get updated role
        await _loadUserProfile();

        // Make sure we load the updated permissions
        await _loadUserPermissions();
      }
    } catch (e) {
      _error = 'Failed to update user role: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh user profile - useful for updating the profile after changes
  Future<void> refreshUserProfile() async {
    if (_user != null) {
      await _loadUserProfile();
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? emergencyContact,
    String? emergencyPhone,
  }) async {
    try {
      if (_user == null) throw Exception('User not authenticated');

      await _supabaseService.updateUserProfile(
        _user!.id,
        {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'emergency_contact': emergencyContact,
          'emergency_phone': emergencyPhone,
        },
      );

      // Update local state
      _firstName = firstName;
      _lastName = lastName;
      _phoneNumber = phoneNumber;
      _emergencyContact = emergencyContact;
      _emergencyPhone = emergencyPhone;

      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}
