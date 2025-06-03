import 'package:flutter/material.dart';

class ButtonState extends ChangeNotifier {
  final Map<String, _ButtonData> _states = {};

  double getScale(String buttonId) => _states[buttonId]?.scale ?? 1.0;
  double getElevation(String buttonId) => _states[buttonId]?.elevation ?? 4.0;
  double getOpacity(String buttonId) => _states[buttonId]?.opacity ?? 1.0;
  double getBorderRadius(String buttonId) =>
      _states[buttonId]?.borderRadius ?? 8.0;
  bool getIsLoading(String buttonId) => _states[buttonId]?.isLoading ?? false;
  bool getIsHovered(String buttonId) => _states[buttonId]?.isHovered ?? false;

  void initButton(String buttonId) {
    if (!_states.containsKey(buttonId)) {
      _states[buttonId] = _ButtonData(
        scale: 1.0,
        elevation: 4.0,
        opacity: 1.0,
        borderRadius: 8.0,
        isLoading: false,
        isHovered: false,
      );
      notifyListeners();
    }
  }

  void onTapDown(String buttonId) {
    initButton(buttonId); // Ensure button is initialized
    if (_states[buttonId]!.isLoading == false) {
      _states[buttonId] = _states[buttonId]!.copyWith(
        scale: 0.95,
        elevation: 2.0,
        opacity: 0.85,
        borderRadius: 10.0,
      );
      notifyListeners();
    }
  }

  void onTapUp(String buttonId) {
    initButton(buttonId); // Ensure button is initialized
    if (_states[buttonId]!.isLoading == false) {
      _states[buttonId] = _states[buttonId]!.copyWith(
        scale: _states[buttonId]!.isHovered ? 1.02 : 1.0,
        elevation: _states[buttonId]!.isHovered ? 6.0 : 4.0,
        opacity: 1.0,
        borderRadius: 8.0,
      );
      notifyListeners();
    }
  }

  void onTapCancel(String buttonId) {
    initButton(buttonId); // Ensure button is initialized
    if (_states[buttonId]!.isLoading == false) {
      _states[buttonId] = _states[buttonId]!.copyWith(
        scale: _states[buttonId]!.isHovered ? 1.02 : 1.0,
        elevation: _states[buttonId]!.isHovered ? 6.0 : 4.0,
        opacity: 1.0,
        borderRadius: 8.0,
      );
      notifyListeners();
    }
  }

  void onHover(String buttonId, bool isHovered) {
    initButton(buttonId); // Ensure button is initialized
    if (_states[buttonId]!.isLoading == false) {
      _states[buttonId] = _states[buttonId]!.copyWith(
        isHovered: isHovered,
        scale: isHovered ? 1.02 : 1.0,
        elevation: isHovered ? 6.0 : 4.0,
        opacity: 1.0,
        borderRadius: 8.0,
      );
      notifyListeners();
    }
  }

  void setLoading(String buttonId, bool isLoading) {
    initButton(buttonId); // Ensure button is initialized
    _states[buttonId] = _states[buttonId]!.copyWith(
      isLoading: isLoading,
      opacity: isLoading ? 0.7 : 1.0,
      elevation: isLoading ? 2.0 : 4.0,
    );
    notifyListeners();
  }
}

class _ButtonData {
  final double scale;
  final double elevation;
  final double opacity;
  final double borderRadius;
  final bool isLoading;
  final bool isHovered;

  _ButtonData({
    required this.scale,
    required this.elevation,
    required this.opacity,
    required this.borderRadius,
    required this.isLoading,
    required this.isHovered,
  });

  _ButtonData copyWith({
    double? scale,
    double? elevation,
    double? opacity,
    double? borderRadius,
    bool? isLoading,
    bool? isHovered,
  }) {
    return _ButtonData(
      scale: scale ?? this.scale,
      elevation: elevation ?? this.elevation,
      opacity: opacity ?? this.opacity,
      borderRadius: borderRadius ?? this.borderRadius,
      isLoading: isLoading ?? this.isLoading,
      isHovered: isHovered ?? this.isHovered,
    );
  }
}
