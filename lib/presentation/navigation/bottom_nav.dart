import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({required this.child, super.key});

  final Widget child;

  static const List<String> _paths = <String>[
    '/home',
    '/transfer',
    '/history',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final int currentIndex = _indexForLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          if (index == currentIndex) {
            return;
          }
          context.go(_paths[index]);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            label: 'Transfer',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _indexForLocation(String location) {
    if (location.startsWith('/transfer')) {
      return 1;
    }
    if (location.startsWith('/history')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }
}
