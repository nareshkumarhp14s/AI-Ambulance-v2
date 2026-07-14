import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/user_provider.dart';

class GreetingCard extends ConsumerWidget {
  const GreetingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),

      padding: const EdgeInsets.all(AppSpacing.lg),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffE53935), Color(0xffC62828)],
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Good Morning 👋",
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),

                const SizedBox(height: 8),

                user.when(
                  data: (data) => Text(
                    data?.name ?? "User",
                    style: AppTextStyles.heading.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),

                  loading: () => Text(
                    "Loading...",
                    style: AppTextStyles.heading.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),

                  error: (_, _) => Text(
                    "User",
                    style: AppTextStyles.heading.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 18,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "Ranchi, Jharkhand",
                      style: AppTextStyles.body.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),

            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }
}
