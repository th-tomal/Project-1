import 'package:flutter/material.dart';
import '../utils/user_roles.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final Function(UserRole) onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Login as",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: UserRole.values.map((role) {
            final isSelected = role == selectedRole;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(role),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.indigo : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo),
                  ),
                  child: Text(
                    role.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
