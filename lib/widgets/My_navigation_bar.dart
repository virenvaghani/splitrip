import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/appPageController/app_page_controller.dart';

class MyNavigationBar extends StatelessWidget {
  const MyNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppPageController pageController = Get.find<AppPageController>();

    final items = [
      {'icon': Icons.group, 'label': 'Friends'},
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.person, 'label': 'Profile'},
    ];

    return Obx(() {
      final selectedIndex = pageController.pageIndex.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final itemWidth = totalWidth / items.length;
            return Container(
              height: 80,
              clipBehavior: Clip.none,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Sliding background indicator behind the row only
                  Positioned.fill(
                    child: Row(
                      children: List.generate(items.length, (index) {
                        final isSelected = selectedIndex == index;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Foreground content
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(items.length, (index) {
                      final isSelected = selectedIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => pageController.changePage(index),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                items[index]['icon'] as IconData,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.iconTheme.color?.withValues(alpha: 0.6),
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                items[index]['label'].toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.textTheme.labelSmall!.color
                                      ?.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
