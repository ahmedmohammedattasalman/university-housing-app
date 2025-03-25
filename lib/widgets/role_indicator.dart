import 'package:flutter/material.dart';

class RoleIndicator extends StatelessWidget {
  final String role;
  final bool showLabel;
  final double iconSize;
  final bool showBackground;

  const RoleIndicator({
    super.key,
    required this.role,
    this.showLabel = true,
    this.iconSize = 16,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final roleInfo = _getRoleInfo(role);

    if (!showBackground) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            roleInfo['icon'] as IconData,
            size: iconSize,
            color: roleInfo['color'] as Color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              roleInfo['label'] as String,
              style: TextStyle(
                fontSize: iconSize * 0.75,
                fontWeight: FontWeight.bold,
                color: roleInfo['color'] as Color,
              ),
            ),
          ],
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: (roleInfo['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (roleInfo['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            roleInfo['icon'] as IconData,
            size: iconSize,
            color: roleInfo['color'] as Color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              roleInfo['label'] as String,
              style: TextStyle(
                fontSize: iconSize * 0.75,
                fontWeight: FontWeight.bold,
                color: (roleInfo['color'] as Color).withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _getRoleInfo(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return {
          'label': 'Student',
          'icon': Icons.school,
          'color': Colors.blue,
          'description': 'Access housing information, attendance, and payments',
        };
      case 'admin':
        return {
          'label': 'Administrator',
          'icon': Icons.admin_panel_settings,
          'color': Colors.purple,
          'description':
              'Manage housing units, assignments, and system settings',
        };
      case 'supervisor':
        return {
          'label': 'Supervisor',
          'icon': Icons.manage_accounts,
          'color': Colors.orange,
          'description': 'Oversee housing facilities and manage staff',
        };
      case 'labor':
        return {
          'label': 'Labor Staff',
          'icon': Icons.handyman,
          'color': Colors.green,
          'description': 'Handle maintenance and facility management tasks',
        };
      case 'general':
        return {
          'label': 'General User',
          'icon': Icons.person,
          'color': Colors.blueGrey,
          'description': 'View housing information and general announcements',
        };
      default:
        return {
          'label': 'Unknown',
          'icon': Icons.help_outline,
          'color': Colors.grey,
          'description': 'Unknown user role',
        };
    }
  }
}
