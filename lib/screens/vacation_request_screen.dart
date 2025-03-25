import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:universityhousing/models/vacation_request_model.dart';
import 'package:universityhousing/services/housing_service.dart';
import 'package:universityhousing/widgets/custom_button.dart';

class VacationRequestScreen extends StatefulWidget {
  const VacationRequestScreen({super.key});

  @override
  State<VacationRequestScreen> createState() => _VacationRequestScreenState();
}

class _VacationRequestScreenState extends State<VacationRequestScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _housingService = HousingService();
  late TabController _tabController;
  bool _isLoading = false;
  bool _isLoadingRequests = false;

  // Form fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();

  // Date variables
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // Vacation requests
  List<VacationRequestModel> _vacationRequests = [];
  String _filterByStatus = 'All';

  // Filter options
  final List<String> _statusFilterOptions = [
    'All',
    'Pending',
    'Approved',
    'Rejected'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVacationRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> _loadVacationRequests() async {
    setState(() {
      _isLoadingRequests = true;
    });

    try {
      // Convert string status filter to enum if needed
      VacationRequestStatus? statusFilter;
      if (_filterByStatus != 'All') {
        switch (_filterByStatus.toLowerCase()) {
          case 'pending':
            statusFilter = VacationRequestStatus.pending;
            break;
          case 'approved':
            statusFilter = VacationRequestStatus.adminApproved;
            break;
          case 'rejected':
            statusFilter = VacationRequestStatus.rejected;
            break;
        }
      }

      final requests = await _housingService.getVacationRequestsAsModel(
        statusFilter: statusFilter,
      );

      if (mounted) {
        setState(() {
          _vacationRequests = requests;
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRequests = false;
        });
        Fluttertoast.showToast(
          msg: 'Error loading vacation requests: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  // Helper method to get display text for status
  String _getStatusDisplayText(VacationRequestStatus status) {
    switch (status) {
      case VacationRequestStatus.pending:
        return 'Pending';
      case VacationRequestStatus.supervisorApproved:
        return 'Approved by Supervisor';
      case VacationRequestStatus.adminApproved:
        return 'Approved';
      case VacationRequestStatus.rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  // Helper method to get color for status
  Color _getStatusColor(VacationRequestStatus status) {
    switch (status) {
      case VacationRequestStatus.pending:
        return Colors.blue;
      case VacationRequestStatus.supervisorApproved:
        return Colors.orange;
      case VacationRequestStatus.adminApproved:
        return Colors.green;
      case VacationRequestStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? _selectedStartDate ?? DateTime.now()
        : _selectedEndDate ??
            (_selectedStartDate ?? DateTime.now()).add(const Duration(days: 1));
    final minDate = isStartDate
        ? DateTime.now()
        : (_selectedStartDate ?? DateTime.now()).add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
          _startDateController.text = DateFormat('MMM d, yyyy').format(picked);

          // Clear end date if it's before new start date
          if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
            _selectedEndDate = null;
            _endDateController.text = '';
          }
        } else {
          _selectedEndDate = picked;
          _endDateController.text = DateFormat('MMM d, yyyy').format(picked);
        }
      });
    }
  }

  Future<void> _submitVacationRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStartDate == null || _selectedEndDate == null) {
      Fluttertoast.showToast(
        msg: 'Please select both start and end dates',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _housingService.submitVacationRequest(
        startDate: _selectedStartDate!,
        endDate: _selectedEndDate!,
        reason: _reasonController.text,
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Vacation request submitted successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Clear form
        _formKey.currentState!.reset();
        _startDateController.clear();
        _endDateController.clear();
        _reasonController.clear();
        _contactInfoController.clear();
        setState(() {
          _selectedStartDate = null;
          _selectedEndDate = null;
        });

        // Reload vacation requests and switch to requests tab
        await _loadVacationRequests();
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error submitting vacation request: ${e.toString()}',
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
        title: const Text('Vacation Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New Request'),
            Tab(text: 'My Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVacationRequestForm(),
          _buildVacationRequestsList(),
        ],
      ),
    );
  }

  Widget _buildVacationRequestForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Submit Vacation Request',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Information card
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
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Vacation requests must be submitted at least 3 days in advance.\n'
                      '• You are responsible for all missed academic requirements.\n'
                      '• Room remains locked during your absence unless otherwise requested.\n'
                      '• Approved requests will be reflected in the attendance system.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date range
            Text(
              'Vacation Period',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Start date
            TextFormField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'Start Date',
                hintText: 'Select start date',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a start date';
                }
                return null;
              },
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 16),

            // End date
            TextFormField(
              controller: _endDateController,
              decoration: const InputDecoration(
                labelText: 'End Date',
                hintText: 'Select end date',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an end date';
                }
                return null;
              },
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 24),

            // Duration display
            if (_selectedStartDate != null && _selectedEndDate != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${_selectedEndDate!.difference(_selectedStartDate!).inDays + 1} days',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Reason
            Text(
              'Request Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Vacation',
                hintText: 'Please provide a detailed reason',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide a reason for your vacation request';
                }
                if (value.length < 10) {
                  return 'Please provide a more detailed reason';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Contact information
            TextFormField(
              controller: _contactInfoController,
              decoration: const InputDecoration(
                labelText: 'Contact Information (Optional)',
                hintText: 'Phone number or email during vacation',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.contact_phone),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: 'Submit Request',
                    onPressed: _submitVacationRequest,
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVacationRequestsList() {
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
                  value: _filterByStatus,
                  items: _statusFilterOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterByStatus = value!;
                    });
                    _loadVacationRequests();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadVacationRequests,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // Requests list
        Expanded(
          child: _isLoadingRequests
              ? const Center(child: CircularProgressIndicator())
              : _vacationRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flight_takeoff,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No vacation requests found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _tabController.animateTo(0),
                            child: const Text('Create a new request'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _vacationRequests.length,
                      itemBuilder: (context, index) {
                        final request = _vacationRequests[index];
                        return _buildRequestCard(request);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(VacationRequestModel request) {
    final startDate = DateFormat('MMM d, yyyy').format(request.startDate);
    final endDate = DateFormat('MMM d, yyyy').format(request.endDate);
    final submissionDate =
        DateFormat('MMM d, yyyy').format(request.requestDate);
    final duration = request.getDurationDays();

    // Determine status color and icon
    Color statusColor = _getStatusColor(request.status);
    IconData statusIcon = Icons.pending;
    if (request.status == VacationRequestStatus.adminApproved) {
      statusIcon = Icons.check_circle;
    } else if (request.status == VacationRequestStatus.rejected) {
      statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  _getStatusDisplayText(request.status),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  'Submitted: $submissionDate',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date range
                Row(
                  children: [
                    const Icon(Icons.date_range, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'From $startDate to $endDate',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$duration ${duration == 1 ? 'day' : 'days'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reason
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reason:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(request.reason),
                        ],
                      ),
                    ),
                  ],
                ),

                // Rejection reason if available
                if (request.rejectionReason != null &&
                    request.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.cancel_outlined,
                          color: Colors.red.shade300, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rejection Reason:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(request.rejectionReason!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // Notes if available
                if (request.notes != null && request.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.feedback, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notes:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(request.notes!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
