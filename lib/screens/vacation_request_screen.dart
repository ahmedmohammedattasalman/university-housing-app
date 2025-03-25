import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VacationRequestScreen extends StatefulWidget {
  const VacationRequestScreen({super.key});

  @override
  State<VacationRequestScreen> createState() => _VacationRequestScreenState();
}

class _VacationRequestScreenState extends State<VacationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _supabaseService = SupabaseService();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
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
        _startDate = picked;
        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      Fluttertoast.showToast(
        msg: "Please select a start date first",
        backgroundColor: Colors.red,
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 180)),
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
        _endDate = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      Fluttertoast.showToast(
        msg: "Please select both start and end dates",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // In a real implementation, call the submitVacationRequest method
      // await _supabaseService.submitVacationRequest(
      //   studentProfileId: authProvider.studentProfileId,
      //   startDate: _startDate!,
      //   endDate: _endDate!,
      //   reason: _reasonController.text.trim(),
      // );

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Vacation request submitted successfully",
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
        title: const Text('Vacation Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
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
                              Icons.person,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.studentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${authProvider.studentId}',
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

              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _startDate != null
                              ? dateFormat.format(_startDate!)
                              : 'Select Date',
                          style: TextStyle(
                            color: _startDate != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _endDate != null
                              ? dateFormat.format(_endDate!)
                              : 'Select Date',
                          style: TextStyle(
                            color: _endDate != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Reason Field
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason for Vacation',
                  hintText: 'Explain why you need a vacation...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a reason for your vacation request';
                  }
                  if (value.length < 10) {
                    return 'Reason must be at least 10 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Vacation Guidelines
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
                            'Vacation Guidelines',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Requests must be submitted at least 3 days in advance',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Maximum vacation period is 30 days per semester',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• You will receive approval notification within 48 hours',
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
