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
      curve: Curves.easeOut,
    );
  }

  BorderRadius _loginRadius(bool isActive) {
    return const BorderRadius.only(
      topLeft: Radius.circular(0),
      bottomLeft: Radius.circular(0),
      topRight: Radius.circular(40),
      bottomRight: Radius.circular(40),
    );
  }

  BorderRadius _registerRadius(bool isActive) {
    return const BorderRadius.only(
      topLeft: Radius.circular(40),
      bottomLeft: Radius.circular(40),
      topRight: Radius.circular(0),
      bottomRight: Radius.circular(0),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0F0F1E);
    const darkBlue = Color(0xFF141A33);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 34, 36),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 420,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -250,
                    left: -80,
                    right: -80,
                    child: Container(
                      height: 500,
                      decoration: const BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(400),
                          bottomRight: Radius.circular(400),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    child: CircleAvatar(
                      radius: 140,
                      backgroundColor: primary,
                      child: ClipOval(
                        child: Image.asset(
                          'images/gymlife.png',
                          width: 1000,
                          height: 1000,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: () => _switchTo(0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentIndex == 0 ? 180 : 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _currentIndex == 1 ? primary : darkBlue,
                          borderRadius: _loginRadius(_currentIndex == 0),
                          boxShadow: _currentIndex == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Visibility(
                              visible: _currentIndex == 0,
                              maintainState: false,
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Positioned(
                              right: _currentIndex == 0 ? 8 : 7.5,
                              child: Container(
                                width: 35,
                                height: 35,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  _currentIndex == 0
                                      ? Icons.arrow_back_ios_new
                                      : Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: () => _switchTo(1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentIndex == 1 ? 180 : 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _currentIndex == 0 ? primary : darkBlue,
                          borderRadius: _registerRadius(_currentIndex == 1),
                          boxShadow: _currentIndex == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: _currentIndex == 1 ? 8 : 7.5,
                              child: Container(
                                width: 35,
                                height: 35,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  _currentIndex == 1
                                      ? Icons.arrow_forward_ios
                                      : Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _currentIndex == 1,
                              maintainState: false,
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                physics: const NeverScrollableScrollPhysics(),
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
