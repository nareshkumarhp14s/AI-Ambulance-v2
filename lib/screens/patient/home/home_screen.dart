import 'package:flutter/material.dart';

import 'widgets/greeting_card.dart';
import 'widgets/sos_button.dart';
import 'widgets/quick_actions.dart';
import 'widgets/ambulance_card.dart';
import 'widgets/hospital_card.dart';
import 'widgets/emergency_tip_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            const SliverToBoxAdapter(child: GreetingCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            const SliverToBoxAdapter(child: SOSButton()),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            const SliverToBoxAdapter(child: QuickActions()),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Nearby Ambulances",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const AmbulanceCard(),
                childCount: 3,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Nearby Hospitals",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const HospitalCard(),
                childCount: 2,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            const SliverToBoxAdapter(child: EmergencyTipCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}
