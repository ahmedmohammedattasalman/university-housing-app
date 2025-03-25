import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/services/supabase_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QrAttendanceScreen extends StatefulWidget {
  const QrAttendanceScreen({super.key});

  @override
  State<QrAttendanceScreen> createState() => _QrAttendanceScreenState();
}

class _QrAttendanceScreenState extends State<QrAttendanceScreen>
    with SingleTickerProviderStateMixin {
  final _supabaseService = SupabaseService();
  late TabController _tabController;
  final TextEditingController _manualIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualIdController.dispose();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    try {
      final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (barcodeScanRes == '-1') {
        // User canceled the scan
        return;
      }

      // Process the scanned QR code
      if (mounted) {
        _processAttendance(barcodeScanRes);
      }
    } on PlatformException {
      Fluttertoast.showToast(
        msg: 'Failed to scan QR code',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _processAttendance(String studentId) async {
    if (studentId.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Invalid QR code or student ID',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call - replace with actual API call to record attendance
      await Future.delayed(const Duration(seconds: 1));

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // In a real implementation, you would call the Supabase service to record attendance
      // await _supabaseService.recordAttendance(
      //   studentProfileId: studentId,
      //   attendanceType: 'regular',
      //   location: 'Main Building',
      // );

      Fluttertoast.showToast(
        msg: 'Attendance recorded successfully',
        backgroundColor: Colors.green,
      );

      // Clear the manual entry field
      _manualIdController.clear();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to record attendance: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildScanTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // QR Code Scanner
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 64,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scan QR Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Scan student QR code to record attendance',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _scanQRCode,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Start Scanning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Manual Entry
          const Text(
            'Manual Entry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualIdController,
                  decoration: InputDecoration(
                    hintText: 'Enter Student ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _processAttendance(_manualIdController.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Attendance List Placeholder
          const Text(
            'Recent Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.separated(
                itemCount: 3, // Sample data
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final names = ['John Doe', 'Jane Smith', 'Michael Johnson'];
                  final ids = ['S12345', 'S12346', 'S12347'];
                  final times = ['10:30 AM', '10:45 AM', '11:15 AM'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                      child: Text(
                        names[index].substring(0, 1),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(names[index]),
                    subtitle: Text('ID: ${ids[index]}'),
                    trailing: Text(
                      times[index],
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyQrTab() {
    final authProvider = Provider.of<AuthProvider>(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Attendance QR Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Show this to your supervisor to record attendance',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // QR Code
                    QrImageView(
                      data: authProvider.studentId,
                      version: QrVersions.auto,
                      size: 240.0,
                      backgroundColor: Colors.white,
                      errorStateBuilder: (context, error) {
                        return const Center(
                          child: Text(
                            'Error generating QR code',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Student Info
                    Text(
                      authProvider.studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${authProvider.studentId}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Room: ${authProvider.roomNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Important',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Do not share your QR code with others. Sharing your QR code may result in incorrect attendance records.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Attendance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Scan QR'),
            Tab(text: 'My QR Code'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScanTab(),
          _buildMyQrTab(),
        ],
      ),
    );
  }
}
