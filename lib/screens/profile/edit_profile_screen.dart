import 'package:flutter/material.dart';
import '../../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProfileService _profileService = ProfileService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _emergencyController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);

    final data = await _profileService.getProfile();

    if (data != null) {
      _nameController.text = data["name"] ?? "";
      _phoneController.text = data["phone"] ?? "";
      _bloodGroupController.text = data["bloodGroup"] ?? "";
      _emergencyController.text = data["emergencyContact"] ?? "";
    }

    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await _profileService.saveProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      bloodGroup: _bloodGroupController.text.trim(),
      emergencyContact: _emergencyController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bloodGroupController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  InputDecoration decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: decoration("Full Name", Icons.person),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter your name" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: decoration("Phone", Icons.phone),
                validator: (value) => value == null || value.isEmpty
                    ? "Enter phone number"
                    : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _bloodGroupController,
                decoration: decoration("Blood Group", Icons.bloodtype),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emergencyController,
                keyboardType: TextInputType.phone,
                decoration: decoration(
                  "Emergency Contact",
                  Icons.contact_emergency,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
