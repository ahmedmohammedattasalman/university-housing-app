import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/providers/theme_provider.dart';
import 'package:universityhousing/screens/login_screen.dart';
import 'package:universityhousing/widgets/loading_indicator.dart';
import 'package:universityhousing/widgets/dashboard_card.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class LaborStaffDashboard extends StatefulWidget {
  const LaborStaffDashboard({super.key});

  @override
  State<LaborStaffDashboard> createState() => _LaborStaffDashboardState();
}

class _LaborStaffDashboardState extends State<LaborStaffDashboard> {
  int _selectedIndex = 0;
  final List<String> _titles = ['Tasks', 'Completed', 'Profile', 'Settings'];

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
            icon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
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
        return _buildTasks();
      case 1:
        return _buildCompleted();
      case 2:
        return _buildProfile();
      case 3:
        return _buildSettings();
      default:
        return _buildTasks();
    }
  }

  Widget _buildTasks() {
    // Sample cleaning tasks
    final tasks = [
      {
        'id': 'T001',
        'building': 'Building A',
        'room': '101',
        'task': 'Regular Cleaning',
        'priority': 'high',
        'due': 'Today, 2:00 PM',
      },
      {
        'id': 'T002',
        'building': 'Building A',
        'room': '205',
        'task': 'Deep Cleaning',
        'priority': 'medium',
        'due': 'Today, 4:00 PM',
      },
      {
        'id': 'T003',
        'building': 'Building B',
        'room': '110',
        'task': 'Regular Cleaning',
        'priority': 'low',
        'due': 'Tomorrow, 10:00 AM',
      },
      {
        'id': 'T004',
        'building': 'Building C',
        'room': '302',
        'task': 'Bathroom Cleaning',
        'priority': 'high',
        'due': 'Today, 1:00 PM',
      },
    ];

    return tasks.isEmpty
        ? _buildEmptyState(
            icon: Icons.assignment,
            title: 'No Tasks Found',
            subtitle: 'You don\'t have any pending tasks',
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pending Tasks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Chip(
                      label: Text(
                        '${tasks.length} Tasks',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ],
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
                      label: const Text('High Priority'),
                      selected: false,
                      onSelected: (selected) {},
                      backgroundColor: Colors.grey[200],
                    ),
                    FilterChip(
                      label: const Text('Today'),
                      selected: false,
                      onSelected: (selected) {},
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tasks list
                ...tasks.map((task) => _buildTaskItem(task, false)),
              ],
            ),
          );
  }

  Widget _buildCompleted() {
    // Sample completed tasks
    final completedTasks = [
      {
        'id': 'T001',
        'building': 'Building A',
        'room': '102',
        'task': 'Regular Cleaning',
        'priority': 'medium',
        'completed': 'Today, 10:30 AM',
      },
      {
        'id': 'T002',
        'building': 'Building B',
        'room': '203',
        'task': 'Deep Cleaning',
        'priority': 'high',
        'completed': 'Yesterday, 3:45 PM',
      },
    ];

    return completedTasks.isEmpty
        ? _buildEmptyState(
            icon: Icons.check_circle,
            title: 'No Completed Tasks',
            subtitle: 'You haven\'t completed any tasks yet',
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completed Tasks',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Tasks list
                ...completedTasks.map((task) => _buildTaskItem(task, true)),
              ],
            ),
          );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, bool isCompleted) {
    Color priorityColor;
    switch (task['priority']) {
      case 'high':
        priorityColor = AppColors.errorColor;
        break;
      case 'medium':
        priorityColor = AppColors.warningColor;
        break;
      case 'low':
        priorityColor = AppColors.infoColor;
        break;
      default:
        priorityColor = Colors.grey;
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
                  '${task['building']} - Room ${task['room']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: priorityColor),
                  ),
                  child: Text(
                    '${task['priority'].toString().toUpperCase()} PRIORITY',
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Task: ${task['task']}'),
            Text(
              isCompleted
                  ? 'Completed: ${task['completed']}'
                  : 'Due: ${task['due']}',
              style: TextStyle(
                color: isCompleted ? AppColors.successColor : Colors.grey[600],
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Start Task',
                      icon: Icons.play_arrow,
                      backgroundColor: AppColors.infoColor,
                      onPressed: () {
                        // TODO: Start task
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      text: 'Mark Complete',
                      icon: Icons.check,
                      backgroundColor: AppColors.successColor,
                      onPressed: () {
                        // TODO: Mark as complete
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final authProvider = Provider.of<AuthProvider>(context);

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
              authProvider.studentName.isNotEmpty
                  ? authProvider.studentName.substring(0, 1).toUpperCase()
                  : 'L',
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
            authProvider.studentName,
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
            child: const Text(
              'Labor Staff',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Profile Details Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileItem(
                      'Email', authProvider.user?.email ?? 'N/A', Icons.email),
                  const Divider(),
                  _buildProfileItem('Phone', 'Not Available', Icons.phone),
                  const Divider(),
                  _buildProfileItem('ID', authProvider.studentId, Icons.badge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          'Tasks\nCompleted', '32', AppColors.successColor),
                      _buildStatItem(
                          'Pending\nTasks', '4', AppColors.warningColor),
                      _buildStatItem(
                          'Hours\nWorked', '128', AppColors.infoColor),
                    ],
                  ),
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
                style: const TextStyle(
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

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
