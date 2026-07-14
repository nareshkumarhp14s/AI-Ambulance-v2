import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/role_selector.dart';

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
  final bloodController = TextEditingController();
  final emergencyController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;

  String selectedRole = "patient";

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bloodController.dispose();
    emergencyController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void register() {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return;
    }

    debugPrint("Register Clicked");

    debugPrint(nameController.text);
    debugPrint(emailController.text);
    debugPrint(phoneController.text);
    debugPrint(bloodController.text);
    debugPrint(emergencyController.text);
    debugPrint(selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),

            children: [
              const SizedBox(height: 20),

              const Icon(Icons.local_hospital, color: Colors.red, size: 80),

              const SizedBox(height: 30),

              CustomTextField(
                controller: nameController,
                hint: "Full Name",
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              CustomTextField(
                controller: emailController,
                hint: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              CustomTextField(
                controller: phoneController,
                hint: "Phone Number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter phone number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              CustomTextField(
                controller: bloodController,
                hint: "Blood Group",
                icon: Icons.bloodtype,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter blood group";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              CustomTextField(
                controller: emergencyController,
                hint: "Emergency Contact",
                icon: Icons.contact_phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter emergency contact";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              PasswordField(
                controller: passwordController,
                hint: "Password",
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Minimum 6 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              PasswordField(
                controller: confirmController,
                hint: "Confirm Password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirm password";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              RoleSelector(
                selectedRole: selectedRole,
                onChanged: (role) {
                  setState(() {
                    selectedRole = role;
                  });
                },
              ),

              const SizedBox(height: 35),

              CustomButton(
                text: "Create Account",
                icon: Icons.person_add,
                isLoading: isLoading,
                onPressed: register,
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Already have an account? Login"),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
