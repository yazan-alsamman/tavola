import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/core/navigation/app_navigation.dart';

class _StackLog extends NavigatorObserver {
  final List<Route<dynamic>> stack = <Route<dynamic>>[];

  List<String?> get names =>
      stack.map((Route<dynamic> route) => route.settings.name).toList();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    stack.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    stack.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    stack.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final int index = oldRoute == null ? -1 : stack.indexOf(oldRoute);
    if (index >= 0 && newRoute != null) {
      stack[index] = newRoute;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _StackLog log;

  setUp(AppNavigation.resetShellRouteTracker);

  Future<NavigatorState> pumpNavigator(WidgetTester tester) async {
    log = _StackLog();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: <NavigatorObserver>[
          AppNavigation.shellRouteTracker,
          log,
        ],
        home: const Text('home'),
      ),
    );
    return tester.state<NavigatorState>(find.byType(Navigator));
  }

  Future<Route<void>> pushTab(
    WidgetTester tester,
    NavigatorState navigator,
    String name,
  ) async {
    final Route<void> route = MaterialPageRoute<void>(
      settings: RouteSettings(name: name),
      builder: (_) => Text(name),
    );
    navigator.push<void>(route);
    await tester.pumpAndSettle();
    return route;
  }

  testWidgets('switching tabs leaves only the latest tab', (tester) async {
    final NavigatorState navigator = await pumpNavigator(tester);
    const List<String> tabs = <String>[
      '/map',
      '/booking',
      '/chat',
      '/profile',
      '/home',
    ];

    for (final String tab in tabs) {
      final Route<void> route = await pushTab(tester, navigator, tab);
      AppNavigation.removeRoutesBelow(navigator, route);
      await tester.pumpAndSettle();
      expect(log.names, <String?>[tab]);
    }
  });

  testWidgets('rapid pushes collapse to the last tab', (tester) async {
    final NavigatorState navigator = await pumpNavigator(tester);
    final List<Route<void>> pushed = <Route<void>>[];
    for (final String tab in <String>['/map', '/booking', '/chat']) {
      pushed.add(await pushTab(tester, navigator, tab));
    }
    expect(log.stack.length, 4);

    AppNavigation.removeRoutesBelow(navigator, pushed.last);
    await tester.pumpAndSettle();

    expect(log.names, <String?>['/chat']);
  });

  testWidgets('a screen opened above the tab survives cleanup and back', (
    tester,
  ) async {
    final NavigatorState navigator = await pumpNavigator(tester);
    final Route<void> shell = await pushTab(tester, navigator, '/profile');
    await pushTab(tester, navigator, '/restaurant');

    AppNavigation.removeRoutesBelow(navigator, shell);
    await tester.pumpAndSettle();
    expect(log.names, <String?>['/profile', '/restaurant']);

    navigator.pop();
    await tester.pumpAndSettle();
    expect(log.names, <String?>['/profile']);
    expect(find.text('/profile'), findsOneWidget);
  });

  testWidgets('cleanup is a no-op when the tab is already the base route', (
    tester,
  ) async {
    final NavigatorState navigator = await pumpNavigator(tester);
    final Route<dynamic> home = log.stack.single;

    AppNavigation.removeRoutesBelow(navigator, home);
    await tester.pumpAndSettle();

    expect(log.names, <String?>['/']);
    expect(
      AppNavigation.shellRouteTracker.routes.map(
        (Route<dynamic> route) => route.settings.name,
      ),
      <String?>['/'],
    );
    expect(tester.takeException(), isNull);
  });
}
