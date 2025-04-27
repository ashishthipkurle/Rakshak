import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

import 'info.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _loadingTexts = [
    "Getting Ready...",
    "Every Drop Counts...",
    "Connecting Donors..."
  ];
  int _textIndex = 0;
  Timer? _messageTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Cycle through loading messages
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _textIndex = (_textIndex + 1) % _loadingTexts.length;
        });
      }
    });

    // Start loading process with fixed 3-second duration
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    // Record start time
    final startTime = DateTime.now();

    try {
      // Load assets
      await loadAssets(context);

      // Calculate elapsed time
      final elapsedMilliseconds = DateTime.now().difference(startTime).inMilliseconds;

      // If less than 3 seconds have passed, wait for the remainder
      final remainingTime = 3000 - elapsedMilliseconds;
      if (remainingTime > 0) {
        await Future.delayed(Duration(milliseconds: remainingTime));
      }
    } catch (e) {
      // If there's an error, still wait for the minimum time
      await Future.delayed(const Duration(seconds: 3));
      print('Error loading assets: $e');
    }

    // Check if widget is still mounted and hasn't navigated yet
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Info())
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildLoadingUI(),
    );
  }

  Widget buildLoadingUI() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.red.shade50, Colors.white],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App title
            Text(
              "Rakshak",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 60),

            // Blood drop animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + 0.1 * _controller.value,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: _controller.value * 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bloodtype,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Loading spinner
            const SpinKitPulse(
              color: Colors.red,
              size: 40.0,
            ),

            const SizedBox(height: 20),

            // Dynamic loading text
            Text(
              _loadingTexts[_textIndex],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Preserving the original loadAssets function
Future<void> loadAssets(BuildContext context) async {
  // Load images
  const image1 = AssetImage('assets/images/doctor.jpg');
  const image2 = AssetImage('assets/images/donate.jpg');
  const image3 = AssetImage('assets/images/patient.jpg');

  // Pre-cache images
  await precacheImage(image1, context);
  await precacheImage(image2, context);
  await precacheImage(image3, context);
}