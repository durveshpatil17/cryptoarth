import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/custom_text_field.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
        title: const Text(
          "Contact Crypto Arth",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green),
            ),
            alignment: Alignment.center,
            child: const Row(
              children: [
                Icon(Icons.headset_mic, color: AppColors.green, size: 14),
                SizedBox(width: 4),
                Text(
                  "24/7 SUPPORT",
                  style: TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Get in touch with our team for platform support, sales inquiries, or partnership opportunities.",
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Contact Info Section (Grid/List Mixed Layout)
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.email,
                    title: "Email",
                    content: "support@cryptoarth.in\nsales@cryptoarth.in",
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.phone,
                    title: "Phone",
                    content: "+91 9321446611\n+91 9321446622",
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.location_on,
              title: "Office Address",
              content: "Office No.311, 3rd floor, NMS Icon\nPlot No. 194, Sector- 19, Ulwe\nNavi Mumbai 410206",
              color: Colors.purpleAccent,
              fullWidth: true,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.access_time_filled,
              title: "Working Hours",
              content: "Mon-Fri: 9AM-6PM IST\nSat-Sun: 10AM-4PM IST\n\nSupport available 24/7 for emergencies",
              color: AppColors.cyan,
              fullWidth: true,
            ),

            const SizedBox(height: 32),

            // Send Us a Message Section
            const Row(
              children: [
                Icon(Icons.send_rounded, color: AppColors.green, size: 24),
                SizedBox(width: 12),
                Text(
                  "Send Us a Message",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Validation Guidelines styled container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.3), // Dark Blue Tint
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Row(
                     children: [
                       Icon(Icons.info_outline, color: Colors.blueAccent, size: 18),
                       SizedBox(width: 8),
                       Text(
                         "Validation Guidelines:",
                         style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                       ),
                     ],
                   ),
                   const SizedBox(height: 8),
                   _buildGuidelineItem("First & Last Name: 5-30 characters each"),
                   _buildGuidelineItem("Email: Must be from valid domains (gmail.com, etc.)"),
                   _buildGuidelineItem("Phone: Exactly 10 digits (Indian mobile number)"),
                   _buildGuidelineItem("Message: 10-300 characters"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            const Row(
              children: [
                Expanded(child: CustomTextField(label: "First Name *", hint: "Enter first name")),
                SizedBox(width: 16),
                Expanded(child: CustomTextField(label: "Last Name *", hint: "Enter last name")),
              ],
            ),
            const SizedBox(height: 16),
            const CustomTextField(label: "Email Address *", hint: "example@gmail.com", keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            const CustomTextField(label: "Phone Number *", hint: "98XXX XXXXX", keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            
            // Message Field (Custom height)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                     Icon(Icons.message, color: AppColors.textSecondary, size: 16), 
                     SizedBox(width: 8),
                     Text(
                      "Message *",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    maxLines: 5,
                    decoration: InputDecoration.collapsed(
                      hintText: "Enter your message (10-300 characters)",
                      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Send Button
            SizedBox(
              width: double.infinity, 
              child: ElevatedButton.icon(
                onPressed: (){}, 
                icon: const Icon(Icons.send, size: 18),
                label: const Text("Send Message"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF), // Dark Blue Button
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ),
             const SizedBox(height: 12),
             Center(child: Text("* All fields are required", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))),


            const SizedBox(height: 48),

            // Contact Departments
            const Row(
              children: [
                Icon(Icons.business, color: Colors.blueAccent, size: 24),
                SizedBox(width: 12),
                Text(
                  "Contact Departments",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDepartmentCard("Technical Support", "support@cryptoarth.in", "Platform issues & technical help", AppColors.green),
            const SizedBox(height: 12),
            _buildDepartmentCard("Sales & Onboarding", "sales@cryptoarth.in", "Pricing, demos & account setup", Colors.orangeAccent),
            const SizedBox(height: 12),
            _buildDepartmentCard("Partnerships", "admin@cryptoarth.in", "API access & business partnerships", Colors.pinkAccent),
            const SizedBox(height: 12),
            _buildDepartmentCard("Security", "cyberarth@cryptoarth.in", "Security concerns & audits", AppColors.cyan),

            const SizedBox(height: 48),

            // FAQ Section
            const Row(
              children: [
                Icon(Icons.quiz, color: AppColors.purple, size: 24),
                SizedBox(width: 12),
                Text(
                  "Frequently Asked Questions",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFAQTile(
              "Do you offer a free trial?",
              "Crypto Arth Trading platform is completely free. You can just open an account with any supported broker like CoinDCX and Delta Exchange.",
            ),
            const SizedBox(height: 12),
            _buildFAQTile(
              "What exchanges do you support?",
              "We support two major exchanges: CoinDCX and Delta Exchange. Both are integrated with our product.",
            ),
             const SizedBox(height: 40),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String content, required Color color, bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded( // To prevent overflow in title if needed
                 child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
          ),
          if (title == "Office Address") ...[ // Add a "Visit" link style text for address if needed
             const SizedBox(height: 12),
             const Text(
               "Visit by appointment",
               style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.bold),
             )
          ]
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 4, color: Colors.white54),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(String title, String email, String desc, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(email, style: TextStyle(color: accentColor, fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: AppColors.green,
        collapsedIconColor: Colors.white70,
        leading: const Icon(Icons.help_outline, color: AppColors.green, size: 20),
        title: Text(
          question, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
