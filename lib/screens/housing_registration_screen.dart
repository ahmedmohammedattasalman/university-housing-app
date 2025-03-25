import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/services/housing_service.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HousingRegistrationScreen extends StatefulWidget {
  const HousingRegistrationScreen({super.key});

  @override
  State<HousingRegistrationScreen> createState() =>
      _HousingRegistrationScreenState();
}

class _HousingRegistrationScreenState extends State<HousingRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _housingService = HousingService();
  bool _isLoading = false;

  // Form fields
  String _selectedSemester = 'Fall 2023';
  String _selectedRoomType = 'Single';
  String _selectedAcademicYear = '2023/2024';
  String? _additionalNotes;

  // Semester options
  final List<String> _semesterOptions = [
    'Fall 2023',
    'Spring 2024',
    'Summer 2024',
    'Fall 2024'
  ];

  // Room type options
  final List<Map<String, dynamic>> _roomTypeOptions = [
    {
      'value': 'Single',
      'description': 'Private room for one student',
      'icon': Icons.person,
    },
    {
      'value': 'Double',
      'description': 'Shared room for two students',
      'icon': Icons.people,
    },
    {
      'value': 'Suite',
      'description': 'Multiple rooms with shared common area',
      'icon': Icons.meeting_room,
    },
    {
      'value': 'Studio',
      'description': 'Small apartment-style unit',
      'icon': Icons.apartment,
    },
  ];

  // Academic year options
  final List<String> _academicYearOptions = ['2023/2024', '2024/2025'];

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.user == null) {
        throw Exception('You must be logged in to register');
      }

      await _housingService.submitHousingRegistration(
        semesterTerm: _selectedSemester,
        academicYear: _selectedAcademicYear,
        roomPreference: _selectedRoomType,
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Housing registration submitted successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navigate back to previous screen or dashboard
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error submitting registration: ${e.toString()}',
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
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Housing Registration'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student information card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Information',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Name: ${authProvider.studentName}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.numbers, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Student ID: ${authProvider.studentId}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Email: ${authProvider.user?.email ?? ""}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Registration Form
                    Text(
                      'Housing Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Academic Year dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Academic Year',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      value: _selectedAcademicYear,
                      items: _academicYearOptions.map((year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAcademicYear = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an academic year';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Semester dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      value: _selectedSemester,
                      items: _semesterOptions.map((semester) {
                        return DropdownMenuItem<String>(
                          value: semester,
                          child: Text(semester),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSemester = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a semester';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Room Type selection
                    Text(
                      'Preferred Room Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_roomTypeOptions.length, (index) {
                      final option = _roomTypeOptions[index];
                      return RadioListTile<String>(
                        title: Text(option['value']),
                        subtitle: Text(option['description']),
                        secondary: Icon(option['icon']),
                        value: option['value'],
                        groupValue: _selectedRoomType,
                        onChanged: (value) {
                          setState(() {
                            _selectedRoomType = value!;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 16),

                    // Additional Notes
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        hintText: 'Any special requirements or preferences',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        _additionalNotes = value;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Important notes about the process
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue.shade800),
                              const SizedBox(width: 8),
                              Text(
                                'Important Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Applications are reviewed within 5-7 business days.\n'
                            '• Room assignments are based on availability and preferences.\n'
                            '• You will be notified via email once your application is processed.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    CustomButton(
                      text: 'Submit Registration',
                      isLoading: _isLoading,
                      onPressed: _submitRegistration,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
