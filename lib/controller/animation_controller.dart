import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimationProvider extends ChangeNotifier with Diagnosticable {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  AnimationProvider(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Animation<double> get fadeAnimation => _fadeAnimation;

  void triggerAnimation() {
    _animationController.forward(from: 0);
    notifyListeners();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AnimationProvider(fadeAnimation: $_fadeAnimation)';
  }

  @override
  DiagnosticsNode toDiagnosticsNode({String? name, DiagnosticsTreeStyle? style}) {
    return DiagnosticableNode<AnimationProvider>(
      name: name,
      value: this,
      style: style,
    );
  }

  @override
  String toStringShort() {
    return 'AnimationProvider';
  }
}