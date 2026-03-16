import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:cryptoarth/shared/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _dobController;
  
  bool _isEditing = false;

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

  Future<void> _saveChanges() async {
    try {
      await ref.read(authProvider.notifier).updateProfile({
        "first_name": _nameController.text.split(' ').first,
        "last_name": _nameController.text.split(' ').length > 1 ? _nameController.text.split(' ').last : '',
        "email": _emailController.text,
        "location": _locationController.text,
        "dob": _dobController.text,
      });
      if (mounted) {
        setState(() => _isEditing = false);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.digitalVoidBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PROFILE SETTINGS",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.8),
            ),
            Text(
              (_isEditing ? "Edit your account details" : "My account details").toUpperCase(),
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ],
        ),
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      body: LuxuryBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 40),
          child: Column(
            children: [
              // Profile Picture Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cyan.withOpacity(0.3), width: 2),
                        gradient: LinearGradient(
                          colors: [AppColors.cyan.withOpacity(0.2), AppColors.purple.withOpacity(0.2)],
                        ),
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
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1),
                          );
                        }
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "IDENTITY AVATAR",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _isEditing ? () {} : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.cyan.withOpacity(0.8),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                ),
                                child: const Text("UPLOAD", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: _isEditing ? () {} : null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white38,
                                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                ),
                                child: const Text("REMOVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "PERSONAL INFORMATION",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8),
                        ),
                        if (!_isEditing)
                           const Icon(Icons.verified_user_outlined, color: AppColors.cyan, size: 14),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    CustomTextField(
                      label: "FULL NAME",
                      hint: "Enter your full name",
                      icon: Icons.person_outline,
                      controller: _nameController,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "EMAIL ADDRESS",
                      hint: "Enter your email",
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "PHONE NUMBER",
                      hint: "Enter phone number",
                      icon: Icons.phone_android_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "LOCATION",
                      hint: "City, Country",
                      icon: Icons.location_on_outlined,
                      controller: _locationController,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "DATE OF BIRTH",
                      hint: "DD/MM/YYYY",
                      icon: Icons.calendar_today_outlined,
                      controller: _dobController,
                      readOnly: !_isEditing,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    if (!_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            setState(() => _isEditing = true);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.cyan),
                          label: const Text("EDIT MASTER PROFILE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.cyan.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: AppColors.green.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))
                          ]
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _saveChanges();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                        ),
                      ),
                  ],
                ),
              ),
  
              const SizedBox(height: 24),
  
              // Danger Zone
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security_outlined, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 12),
                        const Text("PRIVACY & SECURITY", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Account deletion is irreversible and will purge all encrypted trade data from our secure vaults.",
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                        },
                        icon: const Icon(Icons.delete_forever_outlined, size: 18),
                        label: const Text("DELETE ACCOUNT PERMANENTLY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent.withOpacity(0.6),
                          side: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
