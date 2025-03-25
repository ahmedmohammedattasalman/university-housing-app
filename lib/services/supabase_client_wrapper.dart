import 'package:universityhousing/main.dart';

class SupabaseClientWrapper {
  static Future<void> logDatabaseSchema() async {
    try {
      print('Attempting to fetch schema information...');

      // Get tables in the public schema
      final tables = await supabase.rpc('get_tables').select();

      print('Tables in database:');
      print(tables);

      // Try to get users table structure
      try {
        final userColumns = await supabase
            .rpc('get_columns', params: {'table_name': 'users'}).select();

        print('Users table columns:');
        print(userColumns);
      } catch (e) {
        print('Failed to get users table columns: $e');
      }
    } catch (e) {
      print('Error fetching schema information: $e');
    }
  }

  static Future<void> testUserRoleUpdate(String userId, String newRole) async {
    try {
      print('Testing user role update for user ID: $userId to role: $newRole');

      // First get current role
      final userData = await supabase
          .from('users')
          .select('user_role')
          .eq('id', userId)
          .maybeSingle();

      print('Current user role: ${userData?['user_role'] ?? 'unknown'}');

      // Try direct update
      await supabase.from('users').update({
        'user_role': newRole,
      }).eq('id', userId);

      print('Update appears successful, verifying...');

      // Verify update
      final updatedData = await supabase
          .from('users')
          .select('user_role')
          .eq('id', userId)
          .maybeSingle();

      print('New user role: ${updatedData?['user_role'] ?? 'unknown'}');
    } catch (e) {
      print('Error in test update: $e');
    }
  }
}
