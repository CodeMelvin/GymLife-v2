import 'package:flutter/material.dart';

import 'sign_in_page.dart';
import 'sign_up_page.dart';

class AuthSliderPage extends StatefulWidget {
  const AuthSliderPage({super.key});

  @override
  State<AuthSliderPage> createState() => _AuthSliderPageState();
}

class _AuthSliderPageState extends State<AuthSliderPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchTo(int index) {
    if (!mounted) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Image.asset(
              'images/gymlife.png',
              width: 96,
              height: 96,
            ),
            const SizedBox(height: 8),
            Text(
              'GymLife',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3357A4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Jalani hidup sehat bersama GymLife',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            // Login / Register tab switcher
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEFF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _TabButton(
                    label: 'Login',
                    active: _currentIndex == 0,
                    onTap: () => _switchTo(0),
                  ),
                  _TabButton(
                    label: 'Register',
                    active: _currentIndex == 1,
                    onTap: () => _switchTo(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                children: [
                  SignInPage(onSwitchToIndex: _switchTo),
                  SignUpPage(onSwitchToIndex: _switchTo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF4C7FFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF3357A4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
