import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universityhousing/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _user;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _studentProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  Map<String, dynamic>? get studentProfile => _studentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

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

  // Get user's role as string
  String get userRole => _userProfile != null
      ? _userProfile!['user_role']?.toString() ?? 'unknown'
      : 'unknown';

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

      // If user is student, load student profile
      if (isStudent) {
        _studentProfile = await _supabaseService.getStudentProfile();
      }
    } catch (e) {
      _error = 'Failed to load user profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password, {String? userRole}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      _user = response.user;

      if (_user != null) {
        await _loadUserProfile();

        // Verify user role if provided
        if (userRole != null && _userProfile != null) {
          final actualRole = _userProfile!['user_role'];
          if (actualRole != userRole) {
            _error = 'Access denied. You do not have access as a $userRole.';
            await signOut();
            return false;
          }
        }

        return true;
      }
      return false;
    } catch (e) {
      _error = 'Sign in failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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

      _user = null;
      _userProfile = null;
      _studentProfile = null;
    } catch (e) {
      _error = 'Sign out failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get student information
  String get studentName {
    if (_userProfile == null) return '';
    return '${_userProfile!['first_name']} ${_userProfile!['last_name']}';
  }

  String get studentId {
    if (_studentProfile == null) return '';
    return _studentProfile!['student_id'] ?? '';
  }

  String get roomNumber {
    if (_studentProfile == null || _studentProfile!['housing_unit'] == null)
      return '';
    final housing = _studentProfile!['housing_unit'];
    return '${housing['building_name']} ${housing['room_number']}';
  }

  double get outstandingBalance {
    if (_studentProfile == null) return 0.0;
    return (_studentProfile!['outstanding_balance'] as num?)?.toDouble() ?? 0.0;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh user profile - useful for updating the profile after changes
  Future<void> refreshUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _loadUserProfile();
      return;
    } catch (e) {
      _error = 'Failed to refresh profile: ${e.toString()}';
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manual update of user role
  Future<bool> updateUserRole(String role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) {
        _error = 'No user logged in';
        return false;
      }

      // Call supabase service to update role
      await _supabaseService.updateUserRole(_user!.id, role);

      // Refresh the profile
      await _loadUserProfile();
      return true;
    } catch (e) {
      _error = 'Failed to update role: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
