import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class HospitalCard extends StatelessWidget {
  const HospitalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),

      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 65,
                  height: 65,

                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: const Icon(
                    Icons.local_hospital,
                    color: Colors.green,
                    size: 34,
                  ),
                ),

                const SizedBox(width: 15),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Apollo Hospital",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "Multi Speciality Hospital",
                        style: TextStyle(color: Colors.white70),
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),

                          SizedBox(width: 4),

                          Text("4.8"),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Text(
                    "Beds: 12",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 12),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                _HospitalInfo(
                  icon: Icons.location_on,
                  value: "3.1 km",
                  title: "Distance",
                ),

                _HospitalInfo(
                  icon: Icons.access_time,
                  value: "8 min",
                  title: "ETA",
                ),

                _HospitalInfo(icon: Icons.bed, value: "12", title: "Beds"),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.call),
                    label: const Text("Call"),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.event_available),
                    label: const Text("Reserve"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HospitalInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const _HospitalInfo({
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),

        const SizedBox(height: 6),

        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 4),

        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
}
