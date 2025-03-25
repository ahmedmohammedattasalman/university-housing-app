import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/providers/theme_provider.dart';
import 'package:universityhousing/screens/login_screen.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:universityhousing/widgets/dashboard_card.dart';
import 'package:universityhousing/widgets/loading_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<String> _titles = ['Dashboard', 'Housing', 'Students', 'Settings'];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

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
              child: LoadingIndicator(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
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
            icon: Icon(Icons.apartment),
            label: 'Housing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Students',
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
        return _buildHousing();
      case 2:
        return _buildStudents();
      case 3:
        return _buildSettings();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Welcome Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.admin_panel_settings,
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
                          'Welcome, ${authProvider.studentName}!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Administrator Dashboard',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Overview
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  title: 'Total Students',
                  value: '264',
                  color: AppColors.infoColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.apartment,
                  title: 'Occupancy Rate',
                  value: '92%',
                  color: AppColors.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pending_actions,
                  title: 'Pending Requests',
                  value: '24',
                  color: AppColors.warningColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.payments,
                  title: 'Monthly Revenue',
                  value: '\$118,800',
                  color: AppColors.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Grid of options
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              DashboardCard(
                title: 'Manage Registrations',
                icon: Icons.app_registration,
                color: AppColors.primaryColor,
                onTap: () {
                  // TODO: Navigate to registration management
                },
              ),
              DashboardCard(
                title: 'Payment Records',
                icon: Icons.payments,
                color: AppColors.infoColor,
                onTap: () {
                  // TODO: Navigate to payment records
                },
              ),
              DashboardCard(
                title: 'Manage Housing',
                icon: Icons.home,
                color: AppColors.accentColor,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1; // Switch to Housing tab
                  });
                },
              ),
              DashboardCard(
                title: 'Eviction Approvals',
                icon: Icons.exit_to_app,
                color: AppColors.errorColor,
                onTap: () {
                  // TODO: Navigate to eviction approvals
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activities
          Text(
            'Recent Activities',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Activities list (placeholder for now)
          _buildActivityItem(
            title: 'Room 204 Assigned',
            subtitle: 'Room 204 was assigned to John Smith',
            time: '1 hour ago',
            icon: Icons.home,
            color: AppColors.successColor,
          ),
          _buildActivityItem(
            title: 'Payment Received',
            subtitle: 'Lisa Johnson paid \$450 for April housing fee',
            time: '3 hours ago',
            icon: Icons.payment,
            color: AppColors.infoColor,
          ),
          _buildActivityItem(
            title: 'Registration Approved',
            subtitle: 'Michael Brown\'s registration was approved',
            time: '5 hours ago',
            icon: Icons.check_circle,
            color: AppColors.primaryColor,
          ),

          const SizedBox(height: 16),

          // View All Button
          CustomButton(
            text: 'View All Activities',
            icon: Icons.arrow_forward,
            backgroundColor: Colors.white,
            textColor: AppColors.primaryColor,
            onPressed: () {
              // TODO: Navigate to all activities
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              time,
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
  }

  Widget _buildHousing() {
    // Sample housing data
    final housingUnits = [
      {
        'id': 'A1',
        'name': 'Building A - First Floor',
        'rooms': 20,
        'occupied': 18,
        'status': 'active',
      },
      {
        'id': 'A2',
        'name': 'Building A - Second Floor',
        'rooms': 20,
        'occupied': 20,
        'status': 'full',
      },
      {
        'id': 'B1',
        'name': 'Building B - First Floor',
        'rooms': 15,
        'occupied': 12,
        'status': 'active',
      },
      {
        'id': 'B2',
        'name': 'Building B - Second Floor',
        'rooms': 15,
        'occupied': 14,
        'status': 'active',
      },
      {
        'id': 'C1',
        'name': 'Building C - First Floor',
        'rooms': 25,
        'occupied': 22,
        'status': 'active',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Housing Units',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              CustomButton(
                text: 'Add Unit',
                icon: Icons.add,
                backgroundColor: AppColors.successColor,
                height: 40,
                onPressed: () {
                  // TODO: Add new housing unit
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search box
          TextField(
            decoration: InputDecoration(
              hintText: 'Search housing units...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Housing list
          ...housingUnits.map((unit) => _buildHousingItem(unit)),
        ],
      ),
    );
  }

  Widget _buildHousingItem(Map<String, dynamic> unit) {
    Color statusColor;
    switch (unit['status']) {
      case 'active':
        statusColor = AppColors.successColor;
        break;
      case 'full':
        statusColor = AppColors.infoColor;
        break;
      case 'maintenance':
        statusColor = AppColors.warningColor;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  unit['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    unit['status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildHousingDetail(
                  label: 'ID',
                  value: unit['id'],
                  icon: Icons.tag,
                ),
                const SizedBox(width: 24),
                _buildHousingDetail(
                  label: 'Rooms',
                  value: unit['rooms'].toString(),
                  icon: Icons.meeting_room,
                ),
                const SizedBox(width: 24),
                _buildHousingDetail(
                  label: 'Occupied',
                  value: '${unit['occupied']}/${unit['rooms']}',
                  icon: Icons.people,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'View Details',
                    icon: Icons.visibility,
                    backgroundColor: Colors.white,
                    textColor: AppColors.primaryColor,
                    height: 40,
                    onPressed: () {
                      // TODO: View housing detail
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'Edit',
                    icon: Icons.edit,
                    height: 40,
                    onPressed: () {
                      // TODO: Edit housing
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHousingDetail({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudents() {
    // Sample student data
    final students = [
      {
        'id': 'S12345',
        'name': 'John Smith',
        'email': 'john.smith@university.edu',
        'room': 'A-101',
        'status': 'active',
        'image': null,
      },
      {
        'id': 'S12346',
        'name': 'Jane Doe',
        'email': 'jane.doe@university.edu',
        'room': 'A-102',
        'status': 'active',
        'image': null,
      },
      {
        'id': 'S12347',
        'name': 'Mike Johnson',
        'email': 'mike.j@university.edu',
        'room': 'B-205',
        'status': 'active',
        'image': null,
      },
      {
        'id': 'S12348',
        'name': 'Sarah Wilson',
        'email': 'sarah.w@university.edu',
        'room': 'C-110',
        'status': 'inactive',
        'image': null,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Students',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              CustomButton(
                text: 'Add Student',
                icon: Icons.person_add,
                backgroundColor: AppColors.successColor,
                height: 40,
                onPressed: () {
                  // TODO: Add new student
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search box
          TextField(
            decoration: InputDecoration(
              hintText: 'Search students...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Filter chips
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: true,
                onSelected: (selected) {},
                backgroundColor: Colors.grey[200],
                selectedColor: AppColors.primaryColor.withOpacity(0.2),
                checkmarkColor: AppColors.primaryColor,
              ),
              FilterChip(
                label: const Text('Active'),
                selected: false,
                onSelected: (selected) {},
                backgroundColor: Colors.grey[200],
              ),
              FilterChip(
                label: const Text('Inactive'),
                selected: false,
                onSelected: (selected) {},
                backgroundColor: Colors.grey[200],
              ),
              FilterChip(
                label: const Text('Pending'),
                selected: false,
                onSelected: (selected) {},
                backgroundColor: Colors.grey[200],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Students list
          ...students.map((student) => _buildStudentItem(student)),
        ],
      ),
    );
  }

  Widget _buildStudentItem(Map<String, dynamic> student) {
    Color statusColor = student['status'] == 'active'
        ? AppColors.successColor
        : AppColors.warningColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            student['name'].toString().substring(0, 1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          student['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${student['id']}'),
            Text('Email: ${student['email']}'),
            Text('Room: ${student['room']}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            student['status'].toString().toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        isThreeLine: true,
        onTap: () {
          // TODO: View student details
        },
      ),
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
                title: const Text('Account Settings'),
                leading: const Icon(Icons.admin_panel_settings),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Navigate to account settings
                },
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
