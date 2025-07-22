import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class FunLoadingWidget extends StatelessWidget {
  const FunLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fun animation or bouncing icon
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 1),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -10 * (1 - value.abs().sign)),
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            onEnd: () => {},
          ),
          const SizedBox(height: 24),
          // Animated text shimmer
          SizedBox(
            width: 200,
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  TyperAnimatedText('Loading your travel world...'),
                  TyperAnimatedText('Packing your profile...'),
                  TyperAnimatedText('Almost ready to go!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
