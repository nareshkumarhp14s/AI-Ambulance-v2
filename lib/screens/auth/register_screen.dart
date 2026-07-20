import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String selectedRole = AppConstants.patientRole;

  final List<String> bloodGroups = const [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
  ];

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final uid = credential.user!.uid;

      final user = UserModel(
        uid: uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        role: selectedRole,
        bloodGroup: bloodGroupController.text.trim(),
        emergencyContact: emergencyContactController.text.trim(),
        photoUrl: null,
      );

      await UserRepository.instance.createUser(user);

      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({"createdAt": FieldValue.serverTimestamp()});
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration Successful")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration Failed")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bloodGroupController.dispose();
    emergencyContactController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Icon(Icons.local_hospital, size: 80, color: Colors.red),

                const SizedBox(height: 30),

                TextFormField(
                  controller: nameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter name" : null,
                  decoration: inputDecoration(
                    label: "Full Name",
                    icon: Icons.person,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter email" : null,
                  decoration: inputDecoration(
                    label: "Email",
                    icon: Icons.email,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter phone" : null,
                  decoration: inputDecoration(
                    label: "Phone",
                    icon: Icons.phone,
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: bloodGroupController.text.isEmpty
                      ? null
                      : bloodGroupController.text,
                  items: bloodGroups
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    bloodGroupController.text = value ?? "";
                  },
                  validator: (v) => v == null ? "Select blood group" : null,
                  decoration: inputDecoration(
                    label: "Blood Group",
                    icon: Icons.bloodtype,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: emergencyContactController,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter emergency contact" : null,
                  decoration: inputDecoration(
                    label: "Emergency Contact",
                    icon: Icons.contact_phone,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  validator: (v) => v != null && v.length >= 6
                      ? null
                      : "Minimum 6 characters",
                  decoration:
                      inputDecoration(
                        label: "Password",
                        icon: Icons.lock,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Confirm password" : null,
                  decoration:
                      inputDecoration(
                        label: "Confirm Password",
                        icon: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.patientRole,
                      child: Text("Patient"),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.driverRole,
                      child: Text("Driver"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRole = value;
                      });
                    }
                  },
                  decoration: inputDecoration(label: "Role", icon: Icons.badge),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Register"),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
