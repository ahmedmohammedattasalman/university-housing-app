import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:universityhousing/widgets/custom_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EvictionRequestScreen extends StatefulWidget {
  const EvictionRequestScreen({super.key});

  @override
  State<EvictionRequestScreen> createState() => _EvictionRequestScreenState();
}

class _EvictionRequestScreenState extends State<EvictionRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  DateTime _moveOutDate = DateTime.now().add(const Duration(days: 7));
  bool _isSubmitting = false;
  bool _hasOutstandingBalances =
      false; // In a real app, this would be checked with an API
  bool _hasConfirmed = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _moveOutDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (picked != null) {
      setState(() {
        _moveOutDate = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (!_hasConfirmed) {
        Fluttertoast.showToast(
          msg: "Please confirm that you understand the conditions",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.warningColor,
          textColor: Colors.white,
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        // In a real app, this would call an API to submit the request
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call

        if (mounted) {
          Fluttertoast.showToast(
            msg: "Eviction request submitted successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.successColor,
            textColor: Colors.white,
          );

          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Failed to submit request",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.errorColor,
            textColor: Colors.white,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eviction Request'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Request to Move Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete this form to request to move out of your current housing. Your request will need approval before it is finalized.',
              ),
              const SizedBox(height: 30),

              // Student info card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Name: ${authProvider.studentName}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.badge, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('ID: ${authProvider.studentId}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.home, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Room: ${authProvider.roomNumber}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Warning about balances
              if (_hasOutstandingBalances)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warningColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.warningColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Outstanding Balance',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warningColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'You have unpaid balances. These must be settled before your eviction request can be approved.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_hasOutstandingBalances) const SizedBox(height: 24),

              // Move-out date selection
              const Text(
                'Requested Move-Out Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: TextEditingController(
                      text: dateFormat.format(_moveOutDate),
                    ),
                    labelText: 'Move-Out Date',
                    prefixIcon: Icons.calendar_today,
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time until move-out display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.infoColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.infoColor),
                    const SizedBox(width: 8),
                    Text(
                      'Moving out in ${_moveOutDate.difference(DateTime.now()).inDays} days',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reason
              CustomTextField(
                controller: _reasonController,
                labelText: 'Reason for Moving Out',
                hintText: 'Please explain why you want to move out',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a reason for your request';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Checkbox for confirmation
              CheckboxListTile(
                title: const Text(
                  'I understand that once approved, I must vacate the room by the requested date and return all keys and university property.',
                  style: TextStyle(fontSize: 14),
                ),
                value: _hasConfirmed,
                onChanged: (value) {
                  setState(() {
                    _hasConfirmed = value ?? false;
                  });
                },
                activeColor: AppColors.primaryColor,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 30),

              // Submit button
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Submit Request',
                      onPressed: _submitRequest,
                    ),
              const SizedBox(height: 16),

              // Cancel button
              CustomButton(
                text: 'Cancel',
                backgroundColor: Colors.grey[200],
                textColor: Colors.black87,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
