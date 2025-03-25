import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/screens/dashboard_screen.dart';
import 'package:universityhousing/screens/register_screen.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:universityhousing/widgets/custom_text_field.dart';
import 'package:universityhousing/widgets/role_indicator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  String _selectedUserType = 'student';

  final List<Map<String, dynamic>> _userTypes = [
    {
      'value': 'student',
      'label': 'Student',
      'icon': Icons.school,
      'description': 'Access housing information, attendance, and payments',
    },
    {
      'value': 'admin',
      'label': 'Administrator',
      'icon': Icons.admin_panel_settings,
      'description': 'Manage housing units, assignments, and system settings',
    },
    {
      'value': 'supervisor',
      'label': 'Supervisor',
      'icon': Icons.manage_accounts,
      'description': 'Oversee housing facilities and manage staff',
    },
    {
      'value': 'labor',
      'label': 'Labor Staff',
      'icon': Icons.handyman,
      'description': 'Handle maintenance and facility management tasks',
    },
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
        userRole: _selectedUserType,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else if (mounted) {
        Fluttertoast.showToast(
          msg: authProvider.error ?? "Login failed. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or App name
                  const Icon(
                    Icons.apartment,
                    size: 80,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'University Housing',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // User type selection
                  const Text(
                    'Select User Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: _userTypes.map((type) {
                        final Color roleColor =
                            _getRoleColor(type['value'] as String);
                        return Column(
                          children: [
                            if (_userTypes.indexOf(type) > 0)
                              const Divider(height: 1),
                            ListTile(
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: roleColor.withOpacity(0.2),
                                    radius: 16,
                                    child: Icon(
                                      type['icon'] as IconData,
                                      size: 16,
                                      color: roleColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    type['label'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, left: 44),
                                child: Text(
                                  type['description'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              trailing: Radio<String>(
                                value: type['value'] as String,
                                groupValue: _selectedUserType,
                                activeColor: roleColor,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUserType = value!;
                                  });
                                },
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedUserType = type['value'] as String;
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Role description
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getRoleColor(_selectedUserType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _getRoleColor(_selectedUserType)
                              .withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        RoleIndicator(
                          role: _selectedUserType,
                          showBackground: false,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You are logging in as a ${_selectedUserType.toUpperCase()}. You will only see features available to this role.',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getRoleColor(_selectedUserType)
                                  .withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email field
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _isObscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to forgot password screen
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  CustomButton(
                    text: 'Login',
                    isLoading: authProvider.isLoading,
                    onPressed: authProvider.isLoading ? null : _login,
                  ),
                  const SizedBox(height: 16),

                  // Bottom text with register option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Admin or responsible person link
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/responsible');
                        },
                        child: const Text(
                          'Administrative Access',
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this method to get color based on role
  Color _getRoleColor(String role) {
    switch (role) {
      case 'student':
        return Colors.blue;
      case 'admin':
        return Colors.purple;
      case 'supervisor':
        return Colors.orange;
      case 'labor':
        return Colors.green;
      default:
        return AppColors.primaryColor;
    }
  }
}
