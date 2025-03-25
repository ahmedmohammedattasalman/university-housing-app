import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/providers/theme_provider.dart';
import 'package:universityhousing/screens/login_screen.dart';
import 'package:universityhousing/screens/payment_screen.dart';
import 'package:universityhousing/screens/qr_attendance_screen.dart';
import 'package:universityhousing/screens/vacation_request_screen.dart';
import 'package:universityhousing/screens/eviction_request_screen.dart';
import 'package:universityhousing/screens/maintenance_request_screen.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:universityhousing/widgets/dashboard_card.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  final List<String> _titles = [
    'Dashboard',
    'Profile',
    'Notifications',
    'Settings'
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: authProvider.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildProfile();
      case 2:
        return _buildNotifications();
      case 3:
        return _buildSettings();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final authProvider = Provider.of<AuthProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Info Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            AppColors.primaryColor.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.studentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Student ID: ${authProvider.studentId}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Room: ${authProvider.roomNumber}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // Balance information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Outstanding Balance',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat
                                .format(authProvider.outstandingBalance),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: authProvider.outstandingBalance > 0
                                  ? AppColors.errorColor
                                  : AppColors.successColor,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Make Payment'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Service grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              DashboardCard(
                title: 'Attendance',
                icon: Icons.qr_code_scanner,
                color: AppColors.primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QrAttendanceScreen(),
                    ),
                  );
                },
              ),
              DashboardCard(
                title: 'Vacation Request',
                icon: Icons.beach_access,
                color: AppColors.secondaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VacationRequestScreen(),
                    ),
                  );
                },
              ),
              DashboardCard(
                title: 'Move Out Request',
                icon: Icons.exit_to_app,
                color: AppColors.warningColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EvictionRequestScreen(),
                    ),
                  );
                },
              ),
              DashboardCard(
                title: 'Payments',
                icon: Icons.payment,
                color: AppColors.accentColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentScreen(),
                    ),
                  );
                },
              ),
              DashboardCard(
                title: 'Maintenance',
                icon: Icons.build,
                color: Colors.amber,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaintenanceRequestScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Activity list would be populated from database
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Show dummy data for now
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                // This would be replaced with real data
                final activityIcons = [
                  Icons.payment,
                  Icons.qr_code_scanner,
                  Icons.beach_access,
                ];

                final activityTitles = [
                  'Payment Processed',
                  'Attendance Recorded',
                  'Vacation Request Approved',
                ];

                final activityDates = [
                  '2 hours ago',
                  'Yesterday',
                  '3 days ago',
                ];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                    child: Icon(
                      activityIcons[index],
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: Text(activityTitles[index]),
                  subtitle: Text(activityDates[index]),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // View activity details
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Profile Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Text(
              'S',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            'Student Name',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),

          // Role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Student',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Profile Details
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileItem('Student ID', 'ST12345', Icons.badge),
                  const Divider(),
                  _buildProfileItem(
                      'Email', 'student@example.com', Icons.email),
                  const Divider(),
                  _buildProfileItem('Phone', '+1234567890', Icons.phone),
                  const Divider(),
                  _buildProfileItem('Room Number', '101', Icons.apartment),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Edit Profile Button
          CustomButton(
            text: 'Edit Profile',
            icon: Icons.edit,
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    // Placeholder notifications
    final notifications = [
      {
        'title': 'Payment Due Reminder',
        'description': 'Your monthly housing payment is due in 3 days.',
        'time': '2 hours ago',
        'icon': Icons.payment,
        'color': AppColors.warningColor,
      },
      {
        'title': 'Maintenance Scheduled',
        'description':
            'Maintenance team will visit your room tomorrow at 10 AM.',
        'time': '1 day ago',
        'icon': Icons.build,
        'color': AppColors.infoColor,
      },
      {
        'title': 'Vacation Request Approved',
        'description':
            'Your vacation request for April 15-20 has been approved.',
        'time': '2 days ago',
        'icon': Icons.check_circle,
        'color': AppColors.successColor,
      },
    ];

    return notifications.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification['color'] as Color,
                    child: Icon(
                      notification['icon'] as IconData,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(notification['title'] as String),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notification['description'] as String),
                      const SizedBox(height: 4),
                      Text(
                        notification['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
  }

  Widget _buildSettings() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('App Theme'),
                subtitle: Text(
                  themeProvider.themeMode == ThemeMode.dark
                      ? 'Dark Mode'
                      : 'Light Mode',
                ),
                leading: const Icon(Icons.palette),
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Enable or disable notifications'),
                leading: const Icon(Icons.notifications),
                trailing: Switch(
                  value: true, // Placeholder
                  onChanged: (value) {
                    // TODO: Toggle notifications
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Privacy Policy'),
                leading: const Icon(Icons.privacy_tip),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Terms & Conditions'),
                leading: const Icon(Icons.description),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Navigate to terms
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('About'),
                leading: const Icon(Icons.info),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Navigate to about
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: 'Logout',
          icon: Icons.logout,
          backgroundColor: AppColors.errorColor,
          onPressed: () async {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            await authProvider.signOut();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          },
        ),
      ],
    );
  }
}
