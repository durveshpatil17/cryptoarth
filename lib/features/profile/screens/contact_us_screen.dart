import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/shared/widgets/custom_text_field.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            
            // Info Grid
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildInfoCard(Icons.email_outlined, "Email", "support@cryptoarth.in\nsales@cryptoarth.in", cardWidth, subtitle: "Response within 2 hours"),
                    _buildInfoCard(Icons.phone_outlined, "Phone", "+91 9321446611\n+91 9321446622", cardWidth, subtitle: "Available during office hours"),
                    _buildInfoCard(Icons.location_on_outlined, "Office Address", "Office No.311, 3rd floor, NMS Icon, Ulwe, Navi Mumbai", cardWidth, subtitle: "Visit by appointment"),
                    _buildInfoCard(Icons.access_time, "Working Hours", "Mon-Fri: 9AM-6PM\nSat-Sun: 10AM-4PM", cardWidth, subtitle: "24/7 Emergency Support"),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            _buildMessageForm(),
            const SizedBox(height: 24),
            _buildFAQ(),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "© 2025 All rights reserved by\nDeMatade Algo Technology Solutions Private Limited",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      color: AppColors.cardSurface,
      opacity: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  "Contact Crypto Arth",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.headset_mic_outlined, color: AppColors.green, size: 10),
                    SizedBox(width: 4),
                    Text("24/7 SUPPORT AVAILABLE", style: TextStyle(color: AppColors.green, fontSize: 7, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Get in touch with our team for platform support, sales inquiries, partnership opportunities, or any questions about our trading platform.",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, double width, {String? subtitle}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, height: 1.5)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppColors.green, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.send_outlined, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text("Send Us a Message", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          color: AppColors.cardSurface,
          opacity: 0.2,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: "First Name", hint: "Enter First Name", icon: Icons.person_outline)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(label: "Last Name", hint: "Enter Last Name", icon: Icons.person_outline)),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(label: "Email Address", hint: "example@gmail.com", keyboardType: TextInputType.emailAddress, icon: Icons.email_outlined),
                const SizedBox(height: 16),
                CustomTextField(label: "Phone Number", hint: "10 digit mobile number", prefixText: "+91", keyboardType: TextInputType.phone, icon: Icons.phone_android_outlined),
                const SizedBox(height: 16),
                CustomTextField(label: "Message", hint: "Enter your message", maxLines: 4, icon: Icons.chat_bubble_outline),
                const SizedBox(height: 24),
                CustomButton(
                  text: "Send Message",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Message sent! We will get back to you soon."), backgroundColor: AppColors.green));
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text("Frequently Asked Questions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        _buildFAQItem("Do you offer a free trial?", "Crypto Arth Trading platform is completely free for use with supported brokers."),
        _buildFAQItem("What exchanges do you support?", "We currently support major exchanges through our integrated brokers like Binance, BYBIT, and CoinDCX."),
        _buildFAQItem("Is there any platform fee?", "No, there are no hidden platform fees. We believe in transparent trading."),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.green, size: 14),
              const SizedBox(width: 8),
              Expanded(child: Text(question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(answer, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
