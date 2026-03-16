import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/broker/providers/broker_provider.dart';

class BrokerConnectionDialog extends ConsumerStatefulWidget {
  final String brokerName;

  const BrokerConnectionDialog({super.key, required this.brokerName});

  @override
  ConsumerState<BrokerConnectionDialog> createState() => _BrokerConnectionDialogState();
}

class _BrokerConnectionDialogState extends ConsumerState<BrokerConnectionDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _apiSecretController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark blue/slate background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Connect to ${widget.brokerName}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Name Field
              _buildLabel("Name *"),
              const SizedBox(height: 8),
              _buildTextField("Enter name for Login", controller: _nameController),
              const SizedBox(height: 20),

              // API Key Field
              _buildLabel("API Key *"),
              const SizedBox(height: 8),
              _buildTextField("Enter your API key", controller: _apiKeyController),
              const SizedBox(height: 20),

              // API Secret Field
              _buildLabel("API Secret *"),
              const SizedBox(height: 8),
              _buildTextField("Enter your API secret", isObscure: true, controller: _apiSecretController),
              const SizedBox(height: 20),

              // Server IP Address (Read Only)
              _buildLabel("Server IP Address"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "52.66.86.139",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Copy logic placeholder
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(content: Text("IP Address Copied!")));
                      },
                      child: const Icon(Icons.copy, color: AppColors.cyan, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Add this IP to your broker's whitelist for secure connection",
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
              const SizedBox(height: 32),

              // Connect Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    try {
                      final name = _nameController.text.trim();
                      final apiKey = _apiKeyController.text.trim();
                      final apiSecret = _apiSecretController.text.trim();

                      if (name.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
                         throw Exception("Please fill all required fields");
                      }

                      if (widget.brokerName == "Delta Exchange") {
                        await ref.read(brokerProvider.notifier).connectDelta(name, apiKey, apiSecret);
                      } else if (widget.brokerName == "CoinDCX") {
                        await ref.read(brokerProvider.notifier).connectCoinDCX(name, apiKey, apiSecret);
                      } else if (widget.brokerName == "Mudrex") {
                        await ref.read(brokerProvider.notifier).connectMudrex(name, apiKey, apiSecret);
                      }
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Connected to ${widget.brokerName}"), backgroundColor: Colors.green)
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Connection failed: $e"), backgroundColor: Colors.redAccent)
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text(
                        "Connect",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text.replaceAll("*", ""),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        children: [
          if (text.contains("*"))
            const TextSpan(
              text: " *",
              style: TextStyle(color: Colors.redAccent),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isObscure = false, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slate 800
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
