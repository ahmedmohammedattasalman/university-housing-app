import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/screens/housing_registration_screen.dart';
import 'package:universityhousing/screens/payment_screen.dart';
import 'package:universityhousing/screens/attendance_screen.dart';
import 'package:universityhousing/screens/vacation_request_screen.dart';
import 'package:universityhousing/screens/profile_screen.dart';
import 'package:universityhousing/widgets/role_indicator.dart';
import 'package:intl/intl.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;

  // Navigation items
  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard},
    {'title': 'Profile', 'icon': Icons.person},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Housing'),
        actions: [
          const RoleIndicator(role: 'student'),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(authProvider.studentName),
              accountEmail: Text(authProvider.user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  authProvider.studentName.isNotEmpty
                      ? authProvider.studentName[0].toUpperCase()
                      : 'S',
                  style: const TextStyle(fontSize: 24.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ...List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              return ListTile(
                leading: Icon(item['icon']),
                title: Text(item['title']),
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.pop(context); // Close drawer
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                authProvider.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? _buildDashboard(context, authProvider, currencyFormat)
          : const ProfileScreen(),
    );
  }

  Widget _buildDashboard(BuildContext context, AuthProvider authProvider,
      NumberFormat currencyFormat) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome and status card
        Card(
          elevation: 3,
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
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      radius: 28,
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${authProvider.studentName}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Student ID: ${authProvider.studentId}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusItem(
                      context,
                      title: 'Housing Status',
                      value: authProvider.housingStatus,
                      isPositive: authProvider.housingStatus == 'Active',
                      icon: Icons.home,
                    ),
                    _statusItem(
                      context,
                      title: 'Room',
                      value: authProvider.roomNumber,
                      icon: Icons.meeting_room,
                    ),
                    _statusItem(
                      context,
                      title: 'Balance',
                      value: currencyFormat
                          .format(authProvider.outstandingBalance),
                      isPositive: authProvider.outstandingBalance <= 0,
                      icon: Icons.account_balance_wallet,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Quick access features
        _buildSectionHeader('Quick Access'),
        const SizedBox(height: 16),

        // Feature cards grid
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              context,
              title: 'Check In/Out',
              description: 'Record your attendance',
              icon: Icons.login,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceScreen(),
                ),
              ),
            ),
            _buildFeatureCard(
              context,
              title: 'Make Payment',
              description: 'Pay housing fees',
              icon: Icons.payment,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentScreen(
                    amountDue: authProvider.outstandingBalance,
                    paymentFor: 'Housing Fee',
                  ),
                ),
              ),
            ),
            _buildFeatureCard(
              context,
              title: 'Housing Registration',
              description: 'Apply for housing',
              icon: Icons.house,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HousingRegistrationScreen(),
                ),
              ),
            ),
            _buildFeatureCard(
              context,
              title: 'Request Vacation',
              description: 'Plan your absence',
              icon: Icons.flight_takeoff,
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VacationRequestScreen(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Announcements section
        _buildSectionHeader('Announcements'),
        const SizedBox(height: 16),
        _buildAnnouncementCard(
          title: 'Room Inspection Notice',
          date: 'May 15, 2023',
          content:
              'Mandatory room inspections will be conducted next week. Please ensure your room is clean and tidy.',
          isPriority: true,
        ),
        const SizedBox(height: 12),
        _buildAnnouncementCard(
          title: 'Summer Housing Registration',
          date: 'May 5, 2023',
          content:
              'Summer housing registration is now open. Apply early to secure your preferred room.',
          isPriority: false,
        ),
        const SizedBox(height: 12),
        _buildAnnouncementCard(
          title: 'New Laundry Service',
          date: 'April 28, 2023',
          content:
              'A new laundry service is now available in the East Wing. Check the housing portal for details.',
          isPriority: false,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _statusItem(
    BuildContext context, {
    required String title,
    required String value,
    bool isPositive = true,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isPositive ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(thickness: 1),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String date,
    required String content,
    required bool isPriority,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPriority
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isPriority)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.priority_high,
                          size: 14,
                          color: Colors.red.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Important',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
