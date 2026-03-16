import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:flutter/services.dart';

import 'package:cryptoarth/features/broker/widgets/broker_connection_dialog.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/broker/providers/broker_provider.dart';

class BrokerLoginScreen extends ConsumerWidget {
  const BrokerLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brokerState = ref.watch(brokerProvider);
    final connectedBrokers = brokerState.value ?? [];
    final isDeltaConnected = connectedBrokers.any((b) => b.brokerName == 'Delta Exchange');
    final isCoinDCXConnected = connectedBrokers.any((b) => b.brokerName == 'CoinDCX');
    final isMudrexConnected = connectedBrokers.any((b) => b.brokerName == 'Mudrex');
    return Scaffold(
      backgroundColor: AppColors.digitalVoidBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "BROKER SYNC",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.8),
            ),
            Text(
              "ESTABLISH SECURE GATEWAY TO EXCHANGES",
              style: TextStyle(color: AppColors.cyan, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
      body: LuxuryBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
          children: [
            BrokerCard(
              name: "DELTA EXCHANGE",
              rating: 4.5,
              userCount: "500K+",
              description: "High-performance derivatives specialized in crypto options and perpetual swaps with deep institutional liquidity.",
              tags: const ["FUTURES", "OPTIONS", "PERPETUALS"],
              isConnected: isDeltaConnected,
              logoColor: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            BrokerCard(
              name: "COINDCX ELITE",
              rating: 4.7,
              userCount: "1M+",
              description: "Premium fiat-to-crypto gateway with advanced security protocols and integrated institutional custody.",
              tags: const ["SPOT", "SECURITY", "INSURED"],
              isConnected: isCoinDCXConnected,
              logoColor: Colors.blueGrey,
            ),
            const SizedBox(height: 20),
            BrokerCard(
              name: "MUDREX QUANT",
              rating: 4.8,
              userCount: "800K+",
              description: "Automated wealth management platform designed for algorithmic strategy deployment and retail ease.",
              tags: const ["AUTO", "VAULTS", "SAFE"],
              isConnected: isMudrexConnected,
              logoColor: Colors.orangeAccent,
            ),
          ],
        ),
      ),
    );
  }
}


class BrokerCard extends StatelessWidget {
  final String name;
  final double rating;
  final String userCount;
  final String description;
  final List<String> tags;
  final bool isConnected;
  final Color logoColor;

  const BrokerCard({
    super.key,
    required this.name,
    required this.rating,
    required this.userCount,
    required this.description,
    required this.tags,
    required this.isConnected,
    required this.logoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: logoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: logoColor.withOpacity(0.3)),
                ),
                child: Icon(Icons.account_balance_wallet_outlined, color: logoColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "$rating",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "$userCount SYNCED",
                          style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? AppColors.jewelGreen : Colors.white12,
                  shape: BoxShape.circle,
                  boxShadow: isConnected ? [BoxShadow(color: AppColors.jewelGreen.withOpacity(0.5), blurRadius: 6)] : [],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.6, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                tag,
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    showDialog(
                      context: context,
                      builder: (context) => BrokerConnectionDialog(brokerName: name),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text("INITIALIZE LOGIN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("CREATE ACCOUNT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
