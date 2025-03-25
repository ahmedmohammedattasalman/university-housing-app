import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/screens/eviction_request_screen.dart';
import 'package:universityhousing/widgets/role_indicator.dart';
import 'package:universityhousing/services/housing_service.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _housingService = HousingService();

  // Dashboard stats
  int _pendingHousingRegistrations = 0;
  int _pendingVacationRequests = 0;
  int _pendingEvictionRequests = 0;
  int _mealsRequestedToday = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real implementation, these would be actual API calls
      // For now, we're simulating the data loading with random numbers
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _pendingHousingRegistrations = 12;
        _pendingVacationRequests = 5;
        _pendingEvictionRequests = 2;
        _mealsRequestedToday = 34;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Housing Administration'),
        actions: [
          RoleIndicator(role: 'admin'),
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(authProvider.user?.email ?? ''),
              accountEmail: Text('Housing Administrator'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child:
                    const Icon(Icons.admin_panel_settings, color: Colors.blue),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Student Management'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to student management screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_work),
              title: const Text('Room Management'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to room management screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payments'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to payments screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                authProvider.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: _buildDashboard(context),
            ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      radius: 24,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, Administrator',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Housing Management System',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Today\'s Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCurrentDate(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Stats Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildStatCard(
              title: 'Housing Registrations',
              value: _pendingHousingRegistrations.toString(),
              icon: Icons.app_registration,
              color: Colors.blue,
              subtitle: 'Pending Review',
              onTap: () {
                // Navigate to housing registrations screen
              },
            ),
            _buildStatCard(
              title: 'Vacation Requests',
              value: _pendingVacationRequests.toString(),
              icon: Icons.flight_takeoff,
              color: Colors.orange,
              subtitle: 'Pending Review',
              onTap: () {
                // Navigate to vacation requests screen
              },
            ),
            _buildStatCard(
              title: 'Eviction Requests',
              value: _pendingEvictionRequests.toString(),
              icon: Icons.no_accounts,
              color: Colors.red,
              subtitle: 'Pending Review',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EvictionRequestScreen(),
                  ),
                );
              },
            ),
            _buildStatCard(
              title: 'Meals',
              value: _mealsRequestedToday.toString(),
              icon: Icons.restaurant,
              color: Colors.green,
              subtitle: 'Requested Today',
              onTap: () {
                // Navigate to meal management screen
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Actions Section
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildActionTile(
                title: 'Assign Room',
                subtitle: 'Allocate rooms to students',
                icon: Icons.meeting_room,
                onTap: () {
                  // Navigate to room assignment screen
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                title: 'Process Payment',
                subtitle: 'Record a new payment',
                icon: Icons.payments,
                onTap: () {
                  // Navigate to payment processing screen
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                title: 'Create Announcement',
                subtitle: 'Send notifications to students',
                icon: Icons.campaign,
                onTap: () {
                  // Navigate to announcements screen
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                title: 'Generate Reports',
                subtitle: 'Financial and occupancy reports',
                icon: Icons.summarize,
                onTap: () {
                  // Navigate to reports screen
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Recent Activities Section
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildActivityTile(
                title: 'Room Assignment',
                subtitle: 'Jane Doe assigned to Room 302',
                timestamp: '2 hours ago',
                icon: Icons.meeting_room,
                iconColor: Colors.blue,
              ),
              const Divider(height: 1),
              _buildActivityTile(
                title: 'Payment Recorded',
                subtitle: '${currencyFormat.format(450)} housing fee received',
                timestamp: '3 hours ago',
                icon: Icons.payments,
                iconColor: Colors.green,
              ),
              const Divider(height: 1),
              _buildActivityTile(
                title: 'Vacation Request',
                subtitle: 'Approved John Smith\'s request',
                timestamp: '5 hours ago',
                icon: Icons.flight_takeoff,
                iconColor: Colors.orange,
              ),
              const Divider(height: 1),
              _buildActivityTile(
                title: 'Maintenance Request',
                subtitle: 'New plumbing issue reported in Room 210',
                timestamp: '1 day ago',
                icon: Icons.build,
                iconColor: Colors.purple,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              // Navigate to view all activities
            },
            child: const Text('View All Activities'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    color: color,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(icon, color: Colors.blue),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildActivityTile({
    required String title,
    required String subtitle,
    required String timestamp,
    required IconData icon,
    required Color iconColor,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 4),
          Text(
            timestamp,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      isThreeLine: true,
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}

String formatCurrentDate() {
  final now = DateTime.now();
  final formatter = DateFormat('EEEE, MMMM d, yyyy');
  return formatter.format(now);
}
