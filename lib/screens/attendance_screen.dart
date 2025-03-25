import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/services/housing_service.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  final _housingService = HousingService();
  late TabController _tabController;
  bool _isLoading = false;

  // Check-in/out variables
  String _selectedLocation = 'Main Dorm';
  String _selectedAttendanceType = 'Check In';
  bool _isMealRequested = false;
  final TextEditingController _notesController = TextEditingController();

  // Attendance records
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isLoadingRecords = false;
  String _filterByType = 'All';

  // Location options
  final List<String> _locationOptions = [
    'Main Dorm',
    'North Campus',
    'South Campus',
    'East Wing',
    'West Wing'
  ];

  // Attendance type options
  final List<String> _attendanceTypeOptions = [
    'Check In',
    'Check Out',
    'Return From Leave',
    'Temporary Leave'
  ];

  // Filter options
  final List<String> _filterOptions = [
    'All',
    'Check In',
    'Check Out',
    'Return From Leave',
    'Temporary Leave'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAttendanceRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendanceRecords() async {
    setState(() {
      _isLoadingRecords = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final records = await _housingService.getAttendanceRecords(
        userId: authProvider.user!.id,
        filterByType: _filterByType != 'All' ? _filterByType : null,
      );

      if (mounted) {
        setState(() {
          _attendanceRecords = records;
          _isLoadingRecords = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecords = false;
        });
        Fluttertoast.showToast(
          msg: 'Error loading attendance records: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _recordAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Call the service to record attendance
      await _housingService.recordAttendance(
        userId: authProvider.user!.id,
        attendanceType: _selectedAttendanceType,
        location: _selectedLocation,
        isMealRequested: _isMealRequested,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: '${_selectedAttendanceType} recorded successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Clear form
        _notesController.clear();
        setState(() {
          _isMealRequested = false;
        });

        // Reload attendance records and switch to records tab
        await _loadAttendanceRecords();
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error recording attendance: ${e.toString()}',
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
        title: const Text('Attendance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Record Attendance'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAttendanceForm(),
          _buildAttendanceHistory(),
        ],
      ),
    );
  }

  Widget _buildAttendanceForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and time display
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Date & Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy')
                                    .format(DateTime.now()),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('h:mm:ss a').format(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Record Attendance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Attendance Type Selection
          Text(
            'Attendance Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _attendanceTypeOptions.map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _selectedAttendanceType == type,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedAttendanceType = type;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Location Selection
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            value: _selectedLocation,
            items: _locationOptions.map((location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(location),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLocation = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Meal Request
          CheckboxListTile(
            title: const Text('Request Meal'),
            subtitle: const Text('Check if you need a meal today'),
            value: _isMealRequested,
            onChanged: (value) {
              setState(() {
                _isMealRequested = value!;
              });
            },
            secondary: const Icon(Icons.restaurant),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),

          // Notes
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              hintText: 'Add any additional information',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),

          // Submit Button
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: 'Submit Attendance',
                  onPressed: _recordAttendance,
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    return Column(
      children: [
        // Filter options
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Filter by: '),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _filterByType,
                  items: _filterOptions.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterByType = value!;
                    });
                    _loadAttendanceRecords();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAttendanceRecords,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // Attendance history list
        Expanded(
          child: _isLoadingRecords
              ? const Center(child: CircularProgressIndicator())
              : _attendanceRecords.isEmpty
                  ? const Center(child: Text('No attendance records found'))
                  : ListView.builder(
                      itemCount: _attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = _attendanceRecords[index];
                        final timestamp = DateTime.parse(record['timestamp']);
                        final formattedDate =
                            DateFormat('MMM d, yyyy').format(timestamp);
                        final formattedTime =
                            DateFormat('h:mm a').format(timestamp);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading:
                                _getAttendanceIcon(record['attendance_type']),
                            title: Text(record['attendance_type']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$formattedDate at $formattedTime'),
                                Text('Location: ${record['location']}'),
                              ],
                            ),
                            trailing: record['is_meal_requested'] == true
                                ? _getMealStatusIcon(
                                    record['is_meal_confirmed'])
                                : null,
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _getAttendanceIcon(String attendanceType) {
    IconData iconData;
    Color iconColor;

    switch (attendanceType) {
      case 'Check In':
        iconData = Icons.login;
        iconColor = Colors.green;
        break;
      case 'Check Out':
        iconData = Icons.logout;
        iconColor = Colors.red;
        break;
      case 'Return From Leave':
        iconData = Icons.home;
        iconColor = Colors.blue;
        break;
      case 'Temporary Leave':
        iconData = Icons.directions_walk;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.person;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(iconData, color: iconColor),
    );
  }

  Widget _getMealStatusIcon(bool? isConfirmed) {
    if (isConfirmed == true) {
      return const Chip(
        label: Text('Meal Confirmed'),
        avatar: Icon(Icons.check_circle, color: Colors.green, size: 18),
        backgroundColor: Colors.green,
        labelStyle: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else {
      return const Chip(
        label: Text('Meal Pending'),
        avatar: Icon(Icons.pending, color: Colors.orange, size: 18),
        backgroundColor: Colors.orange,
        labelStyle: TextStyle(color: Colors.white, fontSize: 12),
      );
    }
  }
}
