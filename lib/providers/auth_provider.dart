import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universityhousing/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final _supabaseService = SupabaseService();
  User? _user;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _studentProfile;
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
