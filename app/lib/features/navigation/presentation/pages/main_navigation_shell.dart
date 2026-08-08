import 'package:flutter/material.dart';

import '../../../ai_assistant/presentation/pages/ai_chat_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../goals/presentation/pages/goal_list_page.dart';
import '../../../habits/presentation/pages/habit_list_page.dart';
import '../../../planner/presentation/pages/today_plan_page.dart';
import '../../../tasks/presentation/pages/task_list_page.dart';

/// Root shell with bottom navigation (mobile) or rail (wide screens).
///
/// Tab order matches [_pages] indices exactly:
/// 0 Chief of Staff · 1 Goals · 2 Tasks · 3 Habits · 4 Today's Plan · 5 AI Assistant
///
/// Journal, Knowledge, and Settings are reachable via GoRouter deep links.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  static const int _tabCount = 6;

  final List<Widget> _pages = const [
    DashboardPage(),
    GoalListPage(),
    TaskListPage(),
    HabitListPage(),
    TodayPlanPage(),
    AiChatPage(),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Chief of Staff',
    ),
    NavigationDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag),
      label: 'Goals',
    ),
    NavigationDestination(
      icon: Icon(Icons.check_circle_outline),
      selectedIcon: Icon(Icons.check_circle),
      label: 'Tasks',
    ),
    NavigationDestination(
      icon: Icon(Icons.repeat_outlined),
      selectedIcon: Icon(Icons.repeat),
      label: 'Habits',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_today_outlined),
      selectedIcon: Icon(Icons.calendar_today),
      label: "Today's Plan",
    ),
    NavigationDestination(
      icon: Icon(Icons.smart_toy_outlined),
      selectedIcon: Icon(Icons.smart_toy),
      label: 'AI Assistant',
    ),
  ];

  static const List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Chief of Staff'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag),
      label: Text('Goals'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.check_circle_outline),
      selectedIcon: Icon(Icons.check_circle),
      label: Text('Tasks'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.repeat_outlined),
      selectedIcon: Icon(Icons.repeat),
      label: Text('Habits'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.calendar_today_outlined),
      selectedIcon: Icon(Icons.calendar_today),
      label: Text("Today's Plan"),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.smart_toy_outlined),
      selectedIcon: Icon(Icons.smart_toy),
      label: Text('AI Assistant'),
    ),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index.clamp(0, _tabCount - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.sizeOf(context).width >= 700;

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              labelType: NavigationRailLabelType.all,
              destinations: _railDestinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: _destinations,
      ),
    );
  }
}
