import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/services/supabase_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class MaintenanceRequestScreen extends StatefulWidget {
  const MaintenanceRequestScreen({super.key});

  @override
  State<MaintenanceRequestScreen> createState() =>
      _MaintenanceRequestScreenState();
}

class _MaintenanceRequestScreenState extends State<MaintenanceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _supabaseService = SupabaseService();

  bool _isLoading = false;
  String _selectedIssueType = 'Plumbing';
  bool _isUrgent = false;
  DateTime? _preferredDate;

  final List<String> _issueTypes = [
    'Plumbing',
    'Electrical',
    'Furniture',
    'Appliance',
    'Heating/Cooling',
    'Structural',
    'Pest Control',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectPreferredDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _preferredDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _preferredDate = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // In a real implementation, call the submitMaintenanceRequest method
      // await _supabaseService.submitMaintenanceRequest(
      //   userId: authProvider.userId,
      //   roomId: '12345', // Example room ID
      //   title: _titleController.text.trim(),
      //   description: _descriptionController.text.trim(),
      //   issueType: _selectedIssueType,
      //   isUrgent: _isUrgent,
      //   preferredDate: _preferredDate,
      // );

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Maintenance request submitted successfully",
          backgroundColor: Colors.green,
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Failed to submit request: $e",
          backgroundColor: Colors.red,
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
    final authProvider = Provider.of<AuthProvider>(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Location Card
              Card(
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
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.2),
                            child: Icon(
                              Icons.location_on,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Building: Campus Housing',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authProvider.roomNumber != null
                                    ? 'Room: ${authProvider.roomNumber}'
                                    : 'Room: 101',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Request Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Issue Title',
                  hintText: 'Brief title of the issue',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title for the issue';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Issue Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedIssueType,
                decoration: InputDecoration(
                  labelText: 'Issue Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _issueTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedIssueType = newValue;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the issue in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the issue';
                  }
                  if (value.length < 20) {
                    return 'Description must be at least 20 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Urgency Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isUrgent,
                    activeColor: AppColors.errorColor,
                    onChanged: (bool? value) {
                      setState(() {
                        _isUrgent = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'This is an urgent issue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.errorColor,
                  ),
                ],
              ),

              if (_isUrgent)
                Container(
                  margin:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'Urgent issues will be prioritized. Only mark as urgent if the issue poses immediate safety concerns or severely impacts living conditions.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Preferred Date
              InkWell(
                onTap: () => _selectPreferredDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Preferred Maintenance Date (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _preferredDate != null
                        ? dateFormat.format(_preferredDate!)
                        : 'Select Date (Optional)',
                    style: TextStyle(
                      color: _preferredDate != null
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Maintenance Guidelines
              Card(
                color: AppColors.infoColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.infoColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Maintenance Guidelines',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Maintenance staff will contact you before entering your room',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Standard requests are typically addressed within 3-5 business days',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Urgent requests will be prioritized based on severity',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit and Cancel Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Submit Request'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                        side: MaterialStateProperty.all(
                          BorderSide(color: AppColors.primaryColor),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
