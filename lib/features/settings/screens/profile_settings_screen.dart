import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/custom_text_field.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
    _phoneController = TextEditingController(text: user?.phone ?? "");
    _locationController = TextEditingController(text: user?.location ?? "");
    _dobController = TextEditingController(text: user?.dob ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profile Settings",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Manage your account details",
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
             padding: const EdgeInsets.only(right: 16.0),
             child: Container(
               width: 32,
               height: 32,
               decoration: const BoxDecoration(
                 color: Color(0xFFD946EF), // Pink/Purple to differentiate slightly
                 shape: BoxShape.circle,
               ),
               alignment: Alignment.center,
               child: Consumer(
                 builder: (context, ref, child) {
                   final user = ref.watch(authProvider).user;
                   String initials = "U";
                   if (user != null && user.name != null && user.name!.isNotEmpty) {
                     final parts = user.name!.trim().split(' ');
                     initials = parts.length > 1 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : parts[0].substring(0, 1).toUpperCase();
                   }
                   return Text(
                     initials,
                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                   );
                 }
               ),
             ),
           ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.cyan, AppColors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final user = ref.watch(authProvider).user;
                        String initials = "U";
                        if (user != null && user.name != null && user.name!.isNotEmpty) {
                          final parts = user.name!.trim().split(' ');
                          initials = parts.length > 1 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : parts[0].substring(0, 1).toUpperCase();
                        }
                        return Text(
                          initials,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        );
                      }
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Profile Picture",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Update your profile picture",
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cyan,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              ),
                              child: const Text("Upload Photo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              ),
                              child: const Text("Remove", style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Personal Information",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  CustomTextField(
                    label: "Full Name",
                    hint: "Enter your full name",
                    icon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Email Address",
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Phone Number",
                    hint: "Enter phone number",
                    icon: Icons.phone_android_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  // Location with Preview Badge? Screenshot had a "Preview" badge next to label
                  Row(
                    children: [
                       const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 16),
                       const SizedBox(width: 8),
                       const Text(
                         "Location",
                         style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                       ),
                       const SizedBox(width: 8),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(4),
                         ),
                         child: const Text("Preview", style: TextStyle(color: Colors.white70, fontSize: 10)),
                       )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container( // Manual container for Location to match custom style if needed, or reuse CustomTextField structure
                    decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)), // Slight tint
                      ),
                      child: TextField(
                        controller: _locationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          hintText: "Location",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                  ),


                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Date of Birth",
                    hint: "DD/MM/YYYY",
                    icon: Icons.calendar_today_outlined,
                    controller: _dobController,
                  ),
                  
                  const SizedBox(height: 24),

                  // Save Changes Button - Using a gradient container similar to GradientButton but without the Icon specific to rocket launch if we want to match screenshot exactly, 
                  // or just reuse GradientButton. The screenshot shows a wide purple/blue button.
                  // I'll use a custom Container for exact match with "Save Changes" text only.
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.cyan, AppColors.purple],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await ref.read(authProvider.notifier).updateProfile({
                            "first_name": _nameController.text.split(' ').first,
                            "last_name": _nameController.text.split(' ').length > 1 ? _nameController.text.split(' ').last : '',
                            "email": _emailController.text,
                            "location": _locationController.text,
                            "dob": _dobController.text,
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: AppColors.green),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Update failed: $e"), backgroundColor: Colors.redAccent),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Danger Zone
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1B1B).withOpacity(0.5), // Reddish dark tint
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Danger Zone",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Once you delete your account, there is no going back. Please be certain.",
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("Delete My Account"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
