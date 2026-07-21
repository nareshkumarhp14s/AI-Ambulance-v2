import 'package:flutter/material.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Dashboard"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Driver Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      child: Icon(Icons.person, size: 35),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Driver Name",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text("Ambulance : JH01AB1234"),

                          Text("ALS Ambulance"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Online Switch
            Card(
              child: SwitchListTile(
                value: isOnline,

                onChanged: (value) {
                  setState(() {
                    isOnline = value;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? "Driver Online" : "Driver Offline"),
                    ),
                  );
                },

                title: const Text(
                  "Online Status",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Text(
                  isOnline
                      ? "Receiving Emergency Requests"
                      : "Not Receiving Requests",
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Today's Trips",
                    "0",
                    Icons.local_shipping,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildStatCard("Completed", "0", Icons.check_circle),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Current Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    Icon(Icons.local_shipping, size: 70, color: Colors.red),

                    SizedBox(height: 15),

                    Text(
                      "Waiting for Emergency Request",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Go online to receive new ambulance requests.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              mainAxisSpacing: 12,
              crossAxisSpacing: 12,

              childAspectRatio: 1.4,

              children: [
                _actionCard(Icons.notifications, "Requests"),

                _actionCard(Icons.history, "History"),

                _actionCard(Icons.map, "Trip"),

                _actionCard(Icons.person, "Profile"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 32),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(IconData icon, String title) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35),

            const SizedBox(height: 10),

            Text(title),
          ],
        ),
      ),
    );
  }
}
