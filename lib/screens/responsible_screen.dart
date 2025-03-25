import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResponsibleScreen extends StatefulWidget {
  const ResponsibleScreen({super.key});

  @override
  State<ResponsibleScreen> createState() => _ResponsibleScreenState();
}

class _ResponsibleScreenState extends State<ResponsibleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVerified = false;
  bool _isLoading = false;

  // Registration form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordRegController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  String _selectedUserRole = 'student';
  final List<String> _userRoles = [
    'student',
    'admin',
    'supervisor',
    'labor',
    'general'
  ];

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _passwordRegController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void _verifyPassword() {
    setState(() {
      _isLoading = true;
    });

    // The hardcoded access password
    const accessPassword = '20914908';

    if (_passwordController.text == accessPassword) {
      setState(() {
        _isPasswordVerified = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: 'Invalid password. Access denied.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate password confirmation
    if (_passwordRegController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(
        msg: 'Passwords do not match',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordRegController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        userRole: _selectedUserRole,
        phoneNumber: _phoneController.text.trim(),
        studentId: _selectedUserRole == 'student'
            ? _studentIdController.text.trim()
            : null,
      );

      if (mounted) {
        if (success) {
          Fluttertoast.showToast(
            msg: 'User registered successfully!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // Clear the form
          _emailController.clear();
          _passwordRegController.clear();
          _confirmPasswordController.clear();
          _firstNameController.clear();
          _lastNameController.clear();
          _phoneController.clear();
          _studentIdController.clear();
          setState(() {
            _selectedUserRole = 'student';
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Registration failed: ${authProvider.error}',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator Access'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isPasswordVerified
              ? _buildPasswordVerification()
              : _buildRegistrationForm(),
    );
  }

  Widget _buildPasswordVerification() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Administrator Access',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please enter the administrator password to continue',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Administrator Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifyPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Verify Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Register New User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // User Role Selection
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'User Role',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: _selectedUserRole,
              items: _userRoles.map((role) {
                String displayRole = role[0].toUpperCase() + role.substring(1);
                IconData icon;
                switch (role) {
                  case 'student':
                    icon = Icons.school;
                    break;
                  case 'admin':
                    icon = Icons.admin_panel_settings;
                    break;
                  case 'supervisor':
                    icon = Icons.manage_accounts;
                    break;
                  case 'labor':
                    icon = Icons.handyman;
                    break;
                  default:
                    icon = Icons.person;
                }

                return DropdownMenuItem<String>(
                  value: role,
                  child: Row(
                    children: [
                      Icon(icon, size: 22, color: AppColors.primaryColor),
                      const SizedBox(width: 10),
                      Text(displayRole),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUserRole = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password Fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _passwordRegController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordRegController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name Fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a first name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a last name';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number (Optional)',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Student ID Field (only visible for student role)
            if (_selectedUserRole == 'student')
              TextFormField(
                controller: _studentIdController,
                decoration: InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (_selectedUserRole == 'student' &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter a student ID';
                  }
                  return null;
                },
              ),

            const SizedBox(height: 32),

            // Register Button
            CustomButton(
              text: 'Register User',
              onPressed: _registerUser,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 24),

            // User Registration List
            const Text(
              'Recently Registered Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // This would be fetched from a database in a real app
            // For now, just a placeholder
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'No users registered recently.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
