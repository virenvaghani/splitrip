import 'dart:async';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import '../../data/constants.dart';

class SplashScreenController extends GetxController {
  late final AppLinks _appLinks;
  bool _hasNavigated = false;
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _pendingLink;
  RxString appName = "Splitrip".obs;

  @override
  void onInit() {
    super.onInit();
    _processStartupLogic();
  }

  @override
  void onClose() {
    _linkSubscription?.cancel(); // Clean up the subscription
    super.onClose();
  }

  Future<void> _processStartupLogic() async {
    try {
      _appLinks = AppLinks();

      // Listen for deep links (e.g., from WhatsApp)
      _linkSubscription = _appLinks.uriLinkStream.listen(
            (Uri? link) {
          if (!_hasNavigated && link != null) {
            print('SplashScreenController: Received deep link in stream: $link');
            _pendingLink = link; // Store the link for processing after delay
          }
        },
        onError: (e) {
          print('SplashScreenController: Error in deep link stream: $e');
        },
      );

      // Check for initial deep link
      final Uri? initialLink = await _appLinks.getInitialAppLink();
      if (initialLink != null) {
        print('SplashScreenController: Received initial deep link: $initialLink');
        _pendingLink = initialLink; // Store the initial link
      }

      // Always wait for the full splash screen duration
      await Future.delayed(const Duration(milliseconds: 1000));

      // Process the deep link after the delay
      if (!_hasNavigated && _pendingLink != null) {
        _handleDeepLink(_pendingLink!);
      }

      // Fallback to Dashboard if no navigation occurred
      if (!_hasNavigated) {
        print('SplashScreenController: No valid deep link after delay → Navigating to Dashboard');
        _navigateToDashboard();
      }
    } catch (e) {
      print('SplashScreenController: Error in startup logic: $e → Navigating to Dashboard');
      if (!_hasNavigated) {
        _navigateToDashboard();
      }
    }
  }

  void _handleDeepLink(Uri link) {
    // Check for supported schemes (https or app), host, and path
    if ((link.scheme == 'https' || link.scheme == 'app') &&
        link.host == 'expense.jayamsoft.net' &&
        link.path == '/trip') {
      final tripIdStr = link.queryParameters['id'] ?? link.queryParameters['tripId'];
      if (tripIdStr != null && tripIdStr.isNotEmpty) {
        final tripId = int.tryParse(tripIdStr);
        if (tripId != null) {
          print('SplashScreenController: Valid deep link from WhatsApp with tripId: $tripId → Navigating to SelectionPage');
          _navigateToSelectionPage(tripId);
          return;
        }
      }
    }
    // Log invalid cases but don't navigate here; let the caller handle the fallback
    if (link.scheme != 'https' && link.scheme != 'app') {
      print('SplashScreenController: Invalid deep link scheme: ${link.scheme} → Will navigate to Dashboard');
    } else if (link.host != 'expense.jayamsoft.net') {
      print('SplashScreenController: Invalid deep link host: ${link.host} → Will navigate to Dashboard');
    } else if (link.path != '/trip') {
      print('SplashScreenController: Invalid deep link path: ${link.path} → Will navigate to Dashboard');
    } else {
      print('SplashScreenController: Invalid or missing tripId in deep link: $link → Will navigate to Dashboard');
    }
  }

  void _navigateToDashboard() {
    if (!_hasNavigated) {
      _hasNavigated = true;
      try {
        Get.offAllNamed(PageConstant.dashboard);
        print('SplashScreenController: Navigated to Dashboard');
      } catch (e) {
        print('SplashScreenController: Navigation to Dashboard failed: $e');
      }
    }
  }

  void _navigateToSelectionPage(int tripId) {
    if (!_hasNavigated) {
      _hasNavigated = true;
      try {
        Get.toNamed(PageConstant.selectionPage, parameters: {
          'tripId': tripId.toString(),
        });
        print('SplashScreenController: Navigated to SelectionPage with tripId: $tripId');
      } catch (e) {
        print('SplashScreenController: Navigation to SelectionPage failed: $e → Fallback to Dashboard');
        _navigateToDashboard();
      }
    }
  }
}