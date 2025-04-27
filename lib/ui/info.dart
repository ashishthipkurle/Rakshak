import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Move these methods inside the class
  Widget makePage({
    required String image,
    required String title,
    required String content,
    bool reverse = false,
    required BuildContext context,
    required Animation<double> controller,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 60, top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (!reverse)
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 40),

          FadeIn(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 300),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          FadeIn(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 600),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ),

          if (reverse)
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 400),
              child: Container(
                margin: const EdgeInsets.only(top: 40),
                height: MediaQuery.of(context).size.height * 0.32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 30 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(5),
        boxShadow: isActive ? [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
    );
  }

  List<Widget> _buildIndicator(int currentIndex) {
    List<Widget> indicators = [];
    for (int i = 0; i < 3; i++) {
      indicators.add(_indicator(currentIndex == i));
    }
    return indicators;
  }

  void _animateToPage(int page) {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    ).then((_) {
      setState(() => _isAnimating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        // Remove the title property completely
        automaticallyImplyLeading: false, // Ensures no back button appears
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 5),
            child: FadeIn(
              delay: const Duration(milliseconds: 500),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => Login(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            onPageChanged: (int page) {
              if (currentIndex != page) {
                setState(() {
                  currentIndex = page;
                  // Only reset animation if page actually changed
                  _animationController.reset();
                  _animationController.forward();
                });
              }
            },
            controller: _pageController,
            children: <Widget>[
              makePage(
                image: 'assets/images/donate.jpg',
                title: 'Welcome to \nRakshak Blood Donation App',
                content: 'We are here to help you track your blood donations.',
                context: context,
                controller: _animation,
              ),
              makePage(
                reverse: true,
                image: 'assets/images/patient.jpg',
                title: 'Donate blood and save lives',
                content: 'One blood donation can potentially save up to three lives.',
                context: context,
                controller: _animation,
              ),
              makePage(
                image: 'assets/images/doctor.jpg',
                title: 'Blood donation \nhas many benefits',
                content: 'Donating blood reduces the risk of heart disease, lowers the risk of cancer, burns calories, and improves liver health.',
                context: context,
                controller: _animation,
              ),
            ],
          ),

          // Navigation buttons
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (currentIndex > 0)
                  FadeInLeft(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.red),
                      onPressed: () {
                        _animateToPage(currentIndex - 1);
                      },
                    ),
                  ),
                if (currentIndex < 2)
                  FadeInRight(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.red),
                      onPressed: () {
                        _animateToPage(currentIndex + 1);
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Page indicator
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: FadeInUp(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildIndicator(currentIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}