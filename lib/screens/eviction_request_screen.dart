import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/services/housing_service.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:universityhousing/models/eviction_request_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class EvictionRequestScreen extends StatefulWidget {
  const EvictionRequestScreen({super.key});

  @override
  State<EvictionRequestScreen> createState() => _EvictionRequestScreenState();
}

class _EvictionRequestScreenState extends State<EvictionRequestScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _housingService = HousingService();
  late TabController _tabController;
  bool _isLoading = false;
  bool _isLoadingRequests = false;

  // Form fields
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _moveOutDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _additionalNotesController =
      TextEditingController();

  // Date variables
  DateTime? _selectedMoveOutDate;

  // Eviction requests
  List<EvictionRequestModel> _evictionRequests = [];
  String _filterByStatus = 'All';

  // Filter options
  final List<String> _statusFilterOptions = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Executed'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvictionRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentIdController.dispose();
    _moveOutDateController.dispose();
    _reasonController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadEvictionRequests() async {
    setState(() {
      _isLoadingRequests = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Convert string status filter to enum if needed
      EvictionRequestStatus? statusFilter;
      if (_filterByStatus != 'All') {
        statusFilter = EvictionRequestStatus.values.firstWhere(
          (status) =>
              status.toString().split('.').last.toLowerCase() ==
              _filterByStatus.toLowerCase(),
        );
      }

      final requests = await _housingService.getEvictionRequestsAsModel(
        statusFilter: statusFilter,
        userId: authProvider.user!.id,
      );

      if (mounted) {
        setState(() {
          _evictionRequests = requests;
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRequests = false;
        });
        Fluttertoast.showToast(
          msg: 'Error loading eviction requests: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _selectMoveOutDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedMoveOutDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now().add(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        _selectedMoveOutDate = picked;
        _moveOutDateController.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _submitEvictionRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMoveOutDate == null) {
      Fluttertoast.showToast(
        msg: 'Please select a move-out date',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _housingService.submitEvictionRequest(
        moveOutDate: _selectedMoveOutDate!,
        reason: _reasonController.text,
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Eviction request submitted successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Clear form
        _formKey.currentState!.reset();
        _studentIdController.clear();
        _moveOutDateController.clear();
        _reasonController.clear();
        _additionalNotesController.clear();
        setState(() {
          _selectedMoveOutDate = null;
        });

        // Reload eviction requests and switch to requests tab
        await _loadEvictionRequests();
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error submitting eviction request: ${e.toString()}',
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

  Future<void> _reviewEvictionRequest(String requestId, String decision,
      [String? rejectionReason]) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Convert decision string to appropriate status
      EvictionRequestStatus newStatus;
      if (decision == 'approved') {
        newStatus = EvictionRequestStatus.approved;
      } else if (decision == 'rejected') {
        newStatus = EvictionRequestStatus.rejected;
      } else {
        newStatus = EvictionRequestStatus.pending;
      }

      await _housingService.reviewEvictionRequestWithStatus(
        requestId: requestId,
        newStatus: newStatus,
        feedback: rejectionReason,
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Request updated successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Reload eviction requests
        await _loadEvictionRequests();
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error updating request: ${e.toString()}',
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

  Future<void> _executeEviction(EvictionRequestModel request) async {
    final TextEditingController _confirmationController =
        TextEditingController();
    bool confirm = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Execute Eviction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action will permanently evict the student and cannot be undone. Please type "CONFIRM" to proceed.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmationController,
              decoration: const InputDecoration(
                labelText: 'Type CONFIRM',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                confirm = value == 'CONFIRM';
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (confirm) {
                Navigator.pop(context, true);
              } else {
                Fluttertoast.showToast(
                  msg: 'Please type CONFIRM to proceed',
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Execute'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        setState(() {
          _isLoading = true;
        });

        try {
          await _housingService.executeEviction(
            requestId: request.id ?? '',
          );

          if (mounted) {
            Fluttertoast.showToast(
              msg: 'Eviction executed successfully',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );

            // Reload eviction requests
            await _loadEvictionRequests();
          }
        } catch (e) {
          if (mounted) {
            Fluttertoast.showToast(
              msg: 'Error executing eviction: ${e.toString()}',
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
    });

    _confirmationController.dispose();
  }

  Future<void> _showFeedbackDialog(
      String requestId, EvictionRequestStatus newStatus) async {
    final TextEditingController _feedbackController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            '${newStatus == EvictionRequestStatus.approved ? 'Approve' : 'Reject'} Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for ${newStatus == EvictionRequestStatus.approved ? 'approving' : 'rejecting'} this request:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_feedbackController.text.isNotEmpty) {
                Navigator.pop(context, _feedbackController.text);
              } else {
                Fluttertoast.showToast(
                  msg: 'Please provide feedback',
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
            child: Text(newStatus == EvictionRequestStatus.approved
                ? 'Approve'
                : 'Reject'),
          ),
        ],
      ),
    ).then((feedback) {
      if (feedback != null) {
        _reviewEvictionRequest(requestId, feedback);
      }
    });

    _feedbackController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eviction Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New Request'),
            Tab(text: 'Manage Requests'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEvictionRequestForm(),
                _buildEvictionRequestsList(),
              ],
            ),
    );
  }

  Widget _buildEvictionRequestForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Submit Eviction Request',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Warning card
            Card(
              elevation: 2,
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Important Notice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Eviction requests should only be submitted for serious violations.\n'
                      '• This action requires supervisor approval before execution.\n'
                      '• Student will be notified immediately once the request is submitted.\n'
                      '• All eviction requests are logged for audit purposes.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Student information
            Text(
              'Student Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Student ID
            TextFormField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                hintText: 'Enter student ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a student ID';
                }
                if (value.length < 5) {
                  return 'Please enter a valid student ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Move-out date
            Text(
              'Eviction Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _moveOutDateController,
              decoration: const InputDecoration(
                labelText: 'Move-out Date',
                hintText: 'Select move-out date',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a move-out date';
                }
                return null;
              },
              onTap: () => _selectMoveOutDate(context),
            ),
            const SizedBox(height: 16),

            // Reason
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Eviction',
                hintText: 'Provide specific details of violations',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide a reason for eviction';
                }
                if (value.length < 20) {
                  return 'Please provide a more detailed reason';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Additional notes
            TextFormField(
              controller: _additionalNotesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'Any additional information or context',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_add),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Submit button
            CustomButton(
              text: 'Submit Eviction Request',
              onPressed: _submitEvictionRequest,
              backgroundColor: Colors.red,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEvictionRequestsList() {
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
                    _loadEvictionRequests();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadEvictionRequests,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // Requests list
        Expanded(
          child: _isLoadingRequests
              ? const Center(child: CircularProgressIndicator())
              : _evictionRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.no_accounts,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No eviction requests found',
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
                      itemCount: _evictionRequests.length,
                      itemBuilder: (context, index) {
                        final request = _evictionRequests[index];
                        return _buildRequestCard(request);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(EvictionRequestModel request) {
    final moveOutDate =
        DateFormat('MMM d, yyyy').format(request.requestedMoveOutDate);
    final submissionDate =
        DateFormat('MMM d, yyyy').format(request.requestDate);
    final daysUntilMoveOut = request.getDaysToMoveOut();

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    switch (request.status) {
      case EvictionRequestStatus.approved:
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case EvictionRequestStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case EvictionRequestStatus.executed:
        statusColor = Colors.purple;
        statusIcon = Icons.gavel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  request.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Submitted: $submissionDate',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Request details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student info
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Student ID: ${request.studentId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Move-out date
                Row(
                  children: [
                    const Icon(Icons.exit_to_app, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Move-out Date: $moveOutDate',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: daysUntilMoveOut < 3
                            ? Colors.red.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: daysUntilMoveOut < 3
                              ? Colors.red.shade400
                              : Colors.grey.shade400,
                        ),
                      ),
                      child: Text(
                        '$daysUntilMoveOut ${daysUntilMoveOut == 1 ? 'day' : 'days'} remaining',
                        style: TextStyle(
                          fontSize: 12,
                          color: daysUntilMoveOut < 3
                              ? Colors.red.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reason
                const Text(
                  'Reason:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(request.reason),

                // Feedback if available
                if (request.rejectionReason != null &&
                    request.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
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
                              'Feedback:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(request.rejectionReason!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Action buttons based on status
          if (request.status == EvictionRequestStatus.pending)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showFeedbackDialog(
                        request.id ?? '', EvictionRequestStatus.rejected),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('Reject',
                        style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showFeedbackDialog(
                        request.id ?? '', EvictionRequestStatus.approved),
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    label: const Text('Approve',
                        style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            ),

          // Execute button for approved requests
          if (request.status == EvictionRequestStatus.approved)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _executeEviction(request),
                    icon: const Icon(Icons.gavel),
                    label: const Text('Execute Eviction'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
