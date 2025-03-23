import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gridguardian/screens/onboarding_screen.dart';
import 'package:gridguardian/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  XFile? _profileImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          _nameController.text = userData['username'] ?? '';
          _emailController.text = userData['email'] ?? '';
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load profile: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() => _profileImage = image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image error: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'username': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        });

        // Update email in FirebaseAuth
        if (user.email != _emailController.text.trim()) {
          await user.verifyBeforeUpdateEmail(_emailController.text.trim());
        }

        // Update password if provided
        if (_passwordController.text.isNotEmpty) {
          await user.updatePassword(_passwordController.text.trim());
        }

        Fluttertoast.showToast(
          msg: "Profile updated successfully!",
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update profile: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Fluttertoast.showToast(
      msg: "Logged out successfully!",
      backgroundColor: Colors.green,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Profile"),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: _logout,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _ProfileHeader(
                    image: _profileImage,
                    onPressed: _pickImage,
                    theme: themeProvider.currentTheme,
                  ),
                  const SizedBox(height: 30),
                  _buildTextFormField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                  ),
                  _buildTextFormField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextFormField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  _ThemeSelector(themeProvider: themeProvider),
                  const SizedBox(height: 30),
                  _SaveButton(
                    isSaving: _isSaving,
                    onPressed: _saveProfile,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
      ),
    );
  }
}

// Reusable Components
class _ProfileHeader extends StatelessWidget {
  final XFile? image;
  final VoidCallback onPressed;
  final ThemeData theme;

  const _ProfileHeader({
    required this.image,
    required this.onPressed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: IconButton(
            icon: Icon(Icons.camera_alt,
                color: theme.colorScheme.onPrimaryContainer),
            onPressed: onPressed,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text('Change Photo',
              style: TextStyle(color: theme.colorScheme.primary)),
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _ThemeSelector({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => Card(
        child: Column(
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: themeProvider.currentThemeMode,
              onChanged: (mode) => themeProvider.updateThemeSettings(
                useSystem: true,
                mode: ThemeMode.system,
              ),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light Theme'),
              value: ThemeMode.light,
              groupValue: themeProvider.currentThemeMode,
              onChanged: (mode) => themeProvider.updateThemeSettings(
                useSystem: false,
                mode: ThemeMode.light,
              ),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Theme'),
              value: ThemeMode.dark,
              groupValue: themeProvider.currentThemeMode,
              onChanged: (mode) => themeProvider.updateThemeSettings(
                useSystem: false,
                mode: ThemeMode.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: isSaving ? null : onPressed,
        child: isSaving
            ? const CircularProgressIndicator()
            : const Text('Save Changes'),
      ),
    );
  }
}
