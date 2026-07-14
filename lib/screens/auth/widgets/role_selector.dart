import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

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
          "Select Role",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _RoleCard(
                title: "Patient",
                icon: Icons.person,
                value: "patient",
                selected: selectedRole == "patient",
                onTap: () => onChanged("patient"),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: _RoleCard(
                title: "Driver",
                icon: Icons.local_shipping,
                value: "driver",
                selected: selectedRole == "driver",
                onTap: () => onChanged("driver"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: selected
              ? Colors.red.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.red : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: selected
                  ? Colors.red.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.15),
              child: Icon(
                icon,
                color: selected ? Colors.red : Colors.grey,
                size: 30,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.red : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
