import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/main.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:universityhousing/widgets/loading_indicator.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  bool _isLoading = false;
  String _resultMessage = '';
  bool _isError = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _resultMessage = '';
      _isError = false;
    });

    try {
      // Test database connection with a simple query
      final response = await supabase
          .from('_database_version')
          .select()
          .limit(1)
          .maybeSingle();

      setState(() {
        _isLoading = false;
        _resultMessage =
            'Connection successful!\nDatabase info: ${response ?? "No version info available"}';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resultMessage = 'Connection failed: ${e.toString()}';
        _isError = true;
      });
    }
  }

  Future<void> _initializeDatabase() async {
    setState(() {
      _isLoading = true;
      _resultMessage = '';
      _isError = false;
    });

    try {
      // Try to create a test user
      await supabase.from('users').insert({
        'email': 'test@example.com',
        'password': 'password123',
        'user_role': 'student',
        'first_name': 'Test',
        'last_name': 'User'
      }).select();

      setState(() {
        _isLoading = false;
        _resultMessage =
            'Test user created successfully! Your database connection is working.';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resultMessage =
            'Failed to create test user: ${e.toString()}\n\nYou need to first run the database setup SQL script in your Supabase dashboard.';
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Database Connection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.storage,
              size: 80,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Supabase Database Connection Test',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Test Connection',
              onPressed: _isLoading ? null : _testConnection,
              isLoading: _isLoading,
              icon: Icons.sync,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Initialize Database',
              onPressed: _isLoading ? null : _initializeDatabase,
              isLoading: _isLoading,
              icon: Icons.table_chart,
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: LoadingIndicator(color: Colors.blue))
            else if (_resultMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isError ? Colors.red : Colors.green,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isError ? 'Error' : 'Success',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isError ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_resultMessage),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
