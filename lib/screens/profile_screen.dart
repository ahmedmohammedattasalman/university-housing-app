import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:universityhousing/widgets/custom_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _firstNameController = TextEditingController(text: authProvider.firstName);
    _lastNameController = TextEditingController(text: authProvider.lastName);
    _phoneController =
        TextEditingController(text: authProvider.phoneNumber ?? '');
    _emergencyContactController =
        TextEditingController(text: authProvider.emergencyContact ?? '');
    _emergencyPhoneController =
        TextEditingController(text: authProvider.emergencyPhone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Update profile information
      await authProvider.updateProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneController.text,
        emergencyContact: _emergencyContactController.text,
        emergencyPhone: _emergencyPhoneController.text,
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Profile updated successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error updating profile: ${e.toString()}',
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
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                // Cancel editing - reset controllers
                _initializeControllers();
              }

              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Text(
                      authProvider.firstName.isNotEmpty &&
                              authProvider.lastName.isNotEmpty
                          ? '${authProvider.firstName[0]}${authProvider.lastName[0]}'
                          : '?',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isEditing) ...[
                    Text(
                      '${authProvider.firstName} ${authProvider.lastName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        authProvider.userRole.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (_isEditing)
              _buildEditForm()
            else
              _buildProfileInfo(authProvider, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // First Name
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Last Name
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          const Text(
            'Emergency Contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Emergency Contact Name
          TextFormField(
            controller: _emergencyContactController,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.contact_emergency),
            ),
          ),
          const SizedBox(height: 16),

          // Emergency Contact Phone
          TextFormField(
            controller: _emergencyPhoneController,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Phone',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),

          // Save Button
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: 'Save Changes',
                  onPressed: _updateProfile,
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(
      AuthProvider authProvider, NumberFormat currencyFormat) {
    // Set default values for missing properties
    final housingStatus = authProvider.housingStatus;
    final checkInDate = authProvider.checkInDate;
    final outstandingBalance = authProvider.outstandingBalance;
    final roomNumber = authProvider.roomNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information
        _buildSectionHeader('Personal Information'),
        const SizedBox(height: 16),
        _buildInfoItem('Email', authProvider.user?.email ?? '', Icons.email),
        const Divider(),
        _buildInfoItem('Student ID', authProvider.studentId, Icons.badge),
        const Divider(),
        _buildInfoItem(
            'Phone', authProvider.phoneNumber ?? 'Not provided', Icons.phone),
        const Divider(),

        const SizedBox(height: 24),

        // Housing Information
        _buildSectionHeader('Housing Information'),
        const SizedBox(height: 16),
        _buildInfoItem('Room', roomNumber, Icons.meeting_room),
        const Divider(),
        _buildInfoItem('Housing Status', housingStatus, Icons.home,
            valueColor:
                housingStatus == 'Active' ? Colors.green : Colors.orange),
        const Divider(),
        _buildInfoItem(
          'Outstanding Balance',
          currencyFormat.format(outstandingBalance),
          Icons.account_balance_wallet,
          valueColor: outstandingBalance <= 0 ? Colors.green : Colors.red,
        ),
        const Divider(),
        _buildInfoItem(
            'Check-in Date',
            DateFormat('MMM d, yyyy').format(checkInDate),
            Icons.calendar_today),
        const Divider(),

        const SizedBox(height: 24),

        // Emergency Contact
        _buildSectionHeader('Emergency Contact'),
        const SizedBox(height: 16),
        _buildInfoItem(
          'Name',
          authProvider.emergencyContact ?? 'Not provided',
          Icons.contact_emergency,
        ),
        const Divider(),
        _buildInfoItem(
          'Phone',
          authProvider.emergencyPhone ?? 'Not provided',
          Icons.phone_callback,
        ),
        const Divider(),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(thickness: 1),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
