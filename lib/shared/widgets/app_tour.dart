import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

class AppTour extends StatefulWidget {
  final VoidCallback onFinish;
  const AppTour({super.key, required this.onFinish});

  @override
  State<AppTour> createState() => _AppTourState();
}

class _AppTourState extends State<AppTour> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _steps = [
    {
      "title": "Welcome to Crypto Arth",
      "desc": "Your AI-powered companion for crypto trading and strategy building.",
      "icon": "🚀"
    },
    {
      "title": "AI Strategy Builder",
      "desc": "Describe your trading ideas in plain English. AI handles the code.",
      "icon": "🤖"
    },
    {
      "title": "Live Marketplace",
      "desc": "Explore and deploy high-performing strategies from our marketplace.",
      "icon": "📈"
    },
    {
      "title": "Secure Execution",
      "desc": "Connect your favorite brokers and execute trades with precision.",
      "icon": "🔒"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(step['icon']!, style: const TextStyle(fontSize: 80)),
                        const SizedBox(height: 40),
                        Text(
                          step['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step['desc']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == i ? AppColors.primary : Colors.white10,
                  shape: BoxShape.circle,
                ),
              )),
            ),
            
            const SizedBox(height: 32),
            
            // Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentIndex < _steps.length - 1)
                    TextButton(
                      onPressed: widget.onFinish, 
                      child: Text("Skip", style: TextStyle(color: Colors.white.withOpacity(0.3))),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex < _steps.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } else {
                        widget.onFinish();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(_currentIndex == _steps.length - 1 ? "Get Started" : "Next", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
