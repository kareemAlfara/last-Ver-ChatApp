import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lastu_pdate_chat_app/src/presentation/screens/loginScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int currentPage = 0;

  late AnimationController _floatController;

  final List<List<Color>> bgColors = [
    [Colors.blue.shade700, Colors.purple.shade400],
    [Colors.pink.shade500, Colors.orange.shade300],
    [Colors.green.shade500, Colors.blue.shade300],
  ];

  final List<String> lottieAnimations = [
    'assets/3d_message.json',
    'assets/3d_chat.json',
    'assets/3d_secure.json',
    
  ];

  final List<String> titles = [
    "Welcome to Chat App",
    "Real-time Messaging",
    "Secure & Private"
  ];

  final List<String> subtitles = [
    "Connect with friends and family anytime, anywhere",
    "Send messages instantly and stay connected",
    "Your conversations are encrypted and safe"
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgColors[currentPage],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemCount: titles.length,
                  itemBuilder: (context, index) {
                    return _buildPage(
                      lottieAnimations[index],
                      titles[index],
                      subtitles[index],
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: titles.length,
                  effect: WormEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.3),
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 12,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  onPressed: () {
                    if (currentPage < titles.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Loginscreen()),
                      );
                    }
                  },
                  child: Text(
                    currentPage < titles.length - 1
                        ? "Next"
                        : "Get Started",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(String animationPath, String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            double tilt = sin(_floatController.value * 2 * pi) * 0.05;
            double floatY = sin(_floatController.value * 2 * pi) * 10;
            return Transform.translate(
              offset: Offset(0, floatY),
              child: Transform.rotate(
                angle: tilt,
                child: Lottie.asset(
                  animationPath,
                  height: 250,
                  repeat: true,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 40),

        // Glassmorphism Text Container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.85),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
