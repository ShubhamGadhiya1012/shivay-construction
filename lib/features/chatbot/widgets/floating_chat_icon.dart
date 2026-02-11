// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/chatbot/screens/chat_screen.dart';

class FloatingChatIcon extends StatefulWidget {
  const FloatingChatIcon({super.key});

  @override
  State<FloatingChatIcon> createState() => _FloatingChatIconState();
}

class _FloatingChatIconState extends State<FloatingChatIcon> {
  final double iconSize = 60;
  final double edgeSize = 22;

  late Size screen;
  late Offset position;
  bool _initialized = false;

  bool hidden = false;
  bool isLeft = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute.isNotEmpty) {
        floatingIconVisible.value = _shouldShowIcon(Get.currentRoute);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      screen = MediaQuery.of(context).size;
      position = Offset(
        screen.width - iconSize - 16,
        screen.height - iconSize - 120,
      );
      _initialized = true;
    } else {
      final newScreen = MediaQuery.of(context).size;
      if (newScreen != screen) {
        screen = newScreen;
        position = Offset(
          position.dx.clamp(0, screen.width - iconSize),
          position.dy.clamp(80, screen.height - iconSize - 80),
        );
      }
    }
  }

  bool _shouldShowIcon(String route) {
    final routeLower = route.toLowerCase();
    final ignoredRoutes = ['splash', 'login', 'register', 'company', 'chat'];

    if (route == '/' || route.isEmpty) {
      return false;
    }

    return !ignoredRoutes.any((keyword) => routeLower.contains(keyword));
  }

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      position += details.delta;

      position = Offset(
        position.dx.clamp(0, screen.width - iconSize),
        position.dy.clamp(80, screen.height - iconSize - 80),
      );

      hidden = false;
    });
  }

  void onPanEnd(DragEndDetails details) {
    setState(() {
      if (position.dx + iconSize / 2 < screen.width / 2) {
        hidden = true;
        isLeft = true;
        position = Offset(0, position.dy);
      } else {
        hidden = true;
        isLeft = false;
        position = Offset(screen.width - edgeSize, position.dy);
      }
    });
  }

  void reveal() {
    setState(() {
      position = isLeft
          ? Offset(16, position.dy)
          : Offset(screen.width - iconSize - 16, position.dy);
      hidden = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: floatingIconVisible,
      builder: (context, visible, child) {
        if (!visible) return const SizedBox.shrink();

        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Material(
            color: Colors.transparent,
            type: MaterialType.transparency,
            child: GestureDetector(
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
              onTap: () {
                if (hidden) {
                  reveal();
                } else {
                  Get.to(() => const ChatScreen());
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: iconSize,
                width: hidden ? edgeSize : iconSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kColorPrimary, kColorPrimary.withBlue(150)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: kColorPrimary.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  hidden ? Icons.drag_handle : Icons.support_agent,
                  color: Colors.white,
                  size: hidden ? 18 : 30,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Global Notifier
final ValueNotifier<bool> floatingIconVisible = ValueNotifier(false);

// Global Observer
class FloatingIconObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _checkRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _checkRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _checkRoute(newRoute);
    }
  }

  void _checkRoute(Route<dynamic> route) {
    final name = route.settings.name ?? '';
    final screenName = name.toLowerCase();

    final ignored = ['splash', 'login', 'register', 'company', 'chat'];

    bool shouldHide = ignored.any((keyword) => screenName.contains(keyword));

    if (name == '/' || name.isEmpty) {
      shouldHide = true;
    }

    floatingIconVisible.value = !shouldHide;
  }
}
