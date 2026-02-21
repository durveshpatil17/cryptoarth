import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Strategy Templates',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'AI-powered strategy blueprints ready to use',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
           Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.purple.withOpacity(0.5)),
                color: AppColors.purple.withOpacity(0.1),
              ),
              child: const Icon(Icons.lightbulb_outline, color: AppColors.purple, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
               children: [
                  Expanded(
                     child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                           color: AppColors.cardSurface,
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: TextField(
                           controller: _searchController,
                           style: const TextStyle(color: Colors.white),
                           decoration: InputDecoration(
                              hintText: "Search templates...",
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.3)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           ),
                        ),
                     ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                     height: 48,
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                     ),
                     child: Row(
                        children: [
                           Icon(Icons.filter_list, color: Colors.white.withOpacity(0.7), size: 20),
                           const SizedBox(width: 8),
                           Text(
                              "Indicators", 
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold)
                           ),
                        ],
                     ),
                  ),
               ],
            ),
          ),
          
          // Grid
          Expanded(
            child: ref.watch(dashboardStrategyProvider).when(
              data: (strategies) {
                if (strategies.isEmpty) {
                  return const Center(child: Text("No templates available", style: TextStyle(color: Colors.white54)));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 Columns
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75, // Adjust card aspect ratio for better fit
                  ),
                  itemCount: strategies.length,
                  itemBuilder: (context, index) {
                    return _buildTemplateCard(strategies[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
              error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(StrategyModel template) {
    // Extract tags
    final List<String> tags = ["AI", "Auto"];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            template.strategyName.isNotEmpty ? template.strategyName : "Template",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
           
          const SizedBox(height: 8),
          
          // Compact Tags
          Wrap(
             spacing: 4,
             runSpacing: 4,
             children: tags.map<Widget>((tag) {
                return Container(
                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                   decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.purple.withOpacity(0.2)),
                   ),
                   child: Text(
                      tag,
                      style: const TextStyle(color: AppColors.purple, fontSize: 9, fontWeight: FontWeight.bold),
                   ),
                );
             }).toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Expanded(
             child: Text(
                template.strategyCode.isNotEmpty ? template.strategyCode : "No description",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, height: 1.3),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
             ),
          ),
          
          const SizedBox(height: 12),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 28,
            child: ElevatedButton(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Selected template: ${template.strategyName}")),
                 );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan.withOpacity(0.1),
                foregroundColor: AppColors.cyan,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), 
                  side: BorderSide(color: AppColors.cyan.withOpacity(0.2))
                ),
              ),
              child: const Text(
                "Use Template",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
