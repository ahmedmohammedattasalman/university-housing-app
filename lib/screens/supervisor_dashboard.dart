import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/screens/qr_attendance_screen.dart';
import 'package:universityhousing/widgets/dashboard_card.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Navigate to profile
            },
          ),
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
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh dashboard data
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards for supervisor
                Row(
                  children: [
                    _buildSummaryCard(
                      context: context,
                      title: 'Pending Requests',
                      value: '12',
                      icon: Icons.pending_actions,
                      color: AppColors.warningColor,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      context: context,
                      title: 'Staff on Duty',
                      value: '8',
                      icon: Icons.people,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSummaryCard(
                      context: context,
                      title: 'Cleaning Tasks',
                      value: '17',
                      icon: Icons.cleaning_services,
                      color: AppColors.secondaryColor,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      context: context,
                      title: 'Attendance',
                      value: '92%',
                      icon: Icons.how_to_reg,
                      color: AppColors.successColor,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  'Supervision',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Management grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    DashboardCard(
                      title: 'Take Attendance',
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
                      title: 'Vacation Requests',
                      icon: Icons.beach_access,
                      color: AppColors.secondaryColor,
                      onTap: () {
                        // Navigate to vacation requests
                      },
                    ),
                    DashboardCard(
                      title: 'Move Out Requests',
                      icon: Icons.exit_to_app,
                      color: AppColors.warningColor,
                      onTap: () {
                        // Navigate to move out requests
                      },
                    ),
                    DashboardCard(
                      title: 'Assign Tasks',
                      icon: Icons.assignment,
                      color: AppColors.accentColor,
                      onTap: () {
                        // Navigate to task assignment
                      },
                    ),
                    DashboardCard(
                      title: 'Room Inspections',
                      icon: Icons.search,
                      color: AppColors.infoColor,
                      onTap: () {
                        // Navigate to room inspections
                      },
                    ),
                    DashboardCard(
                      title: 'Student Records',
                      icon: Icons.folder_open,
                      color: AppColors.errorColor,
                      onTap: () {
                        // Navigate to student records
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  'Today\'s Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Tasks for today
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3, // Show dummy data for now
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final taskTitles = [
                        'Morning Attendance',
                        'Room Inspection - East Wing',
                        'Staff Meeting',
                      ];

                      final taskTimes = [
                        '8:00 AM',
                        '11:30 AM',
                        '2:00 PM',
                      ];

                      final taskStatuses = [
                        'Completed',
                        'In Progress',
                        'Upcoming',
                      ];

                      final taskIcons = [
                        Icons.check_circle,
                        Icons.pending,
                        Icons.schedule,
                      ];

                      final taskColors = [
                        AppColors.successColor,
                        AppColors.warningColor,
                        Colors.grey,
                      ];

                      return ListTile(
                        leading: Icon(
                          taskIcons[index],
                          color: taskColors[index],
                        ),
                        title: Text(taskTitles[index]),
                        subtitle: Text(taskTimes[index]),
                        trailing: Chip(
                          label: Text(
                            taskStatuses[index],
                            style: TextStyle(
                              color: index == 0 ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: taskColors[index]
                              .withOpacity(index == 0 ? 1.0 : 0.2),
                        ),
                        onTap: () {
                          // View task details
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
