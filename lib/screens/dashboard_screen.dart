import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/screens/student_dashboard.dart';
import 'package:universityhousing/screens/admin_dashboard.dart';
import 'package:universityhousing/screens/supervisor_dashboard.dart';
import 'package:universityhousing/screens/labor_dashboard.dart';
import 'package:universityhousing/screens/general_dashboard.dart';
import 'package:universityhousing/widgets/loading_indicator.dart';
import 'package:universityhousing/widgets/role_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showRoleMessage = true;

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _showRoleMessage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading indicator while profile is loading
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(
            color: Colors.blue,
          ),
        ),
      );
    }

    // Show role determination message for a moment
    if (_showRoleMessage && authProvider.hasValidRole) {
      return _buildRoleDeterminationScreen(authProvider);
    }

    // Check user role and redirect to appropriate dashboard
    if (authProvider.isStudent) {
      return const StudentDashboard();
    } else if (authProvider.isAdmin) {
      return const AdminDashboard();
    } else if (authProvider.isSupervisor) {
      return const SupervisorDashboard();
    } else if (authProvider.isLabor) {
      return const LaborDashboard();
    } else if (authProvider.isGeneral) {
      return const GeneralDashboard();
    }

    // If role not found or not loaded yet, show error dashboard
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Housing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'User role not recognized',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Unable to determine your role. Current role: "${authProvider.userRole}". Please contact support or try updating your profile.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Try to fix the user role
                await _fixUserRole(context, authProvider);
              },
              child: const Text('Fix My Role'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDeterminationScreen(AuthProvider authProvider) {
    final roleInfo = _getRoleInfo(authProvider.userRole);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: (roleInfo['color'] as Color).withOpacity(0.2),
              child: Icon(
                roleInfo['icon'] as IconData,
                size: 60,
                color: roleInfo['color'] as Color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Welcome, ${authProvider.studentName}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RoleIndicator(
              role: authProvider.userRole,
              iconSize: 24,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                roleInfo['description'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const LoadingIndicator(
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              "Loading your dashboard...",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getRoleInfo(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return {
          'label': 'Student',
          'icon': Icons.school,
          'color': Colors.blue,
          'description': 'Access housing information, attendance, and payments',
        };
      case 'admin':
        return {
          'label': 'Administrator',
          'icon': Icons.admin_panel_settings,
          'color': Colors.purple,
          'description':
              'Manage housing units, assignments, and system settings',
        };
      case 'supervisor':
        return {
          'label': 'Supervisor',
          'icon': Icons.manage_accounts,
          'color': Colors.orange,
          'description': 'Oversee housing facilities and manage staff',
        };
      case 'labor':
        return {
          'label': 'Labor Staff',
          'icon': Icons.handyman,
          'color': Colors.green,
          'description': 'Handle maintenance and facility management tasks',
        };
      case 'general':
        return {
          'label': 'General User',
          'icon': Icons.person,
          'color': Colors.blueGrey,
          'description': 'View housing information and general announcements',
        };
      default:
        return {
          'label': 'Unknown',
          'icon': Icons.help_outline,
          'color': Colors.grey,
          'description': 'Unknown user role',
        };
    }
  }

  Future<void> _fixUserRole(
      BuildContext context, AuthProvider authProvider) async {
    // Show a dialog to select a role
    final selectedRole = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Your Role'),
        content: const Text('Please select your correct role:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'student'),
            child: const Text('Student'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'general'),
            child: const Text('General User'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedRole != null && context.mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Updating your role...'),
            ],
          ),
        ),
      );

      try {
        // Update the user role
        await Provider.of<AuthProvider>(context, listen: false)
            .updateUserRole(selectedRole);

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating role: $e')),
          );
        }
      }
    }
  }
}
