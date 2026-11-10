import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../features/orders/orders_list_page.dart';
import '../features/orders/order_detail_page.dart';
import '../features/diagnostic/diagnostic_page.dart';
import '../features/tyres/tyres_page.dart';
import '../features/photos/photos_page.dart';
import '../features/vehicle/vehicle_page.dart';
import '../features/vehicle/history_page.dart';
import '../features/scanner/vin_scanner_page.dart';
import '../features/tools/tools_page.dart';
import '../features/settings/settings_page.dart';

/// Routage déclaratif go_router. Toutes les routes mènent à du code original + données fictives.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/orders', builder: (_, __) => const OrdersListPage()),
    GoRoute(
      path: '/orders/:id',
      builder: (_, state) => OrderDetailPage(orderId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/diagnostic', builder: (_, __) => const DiagnosticPage()),
    GoRoute(path: '/tyres', builder: (_, __) => const TyresPage()),
    GoRoute(path: '/photos', builder: (_, __) => const PhotosPage()),
    GoRoute(path: '/vehicle', builder: (_, __) => const VehiclePage()),
    GoRoute(path: '/history', builder: (_, __) => const VehicleHistoryPage()),
    GoRoute(path: '/scanner', builder: (_, __) => const VinScannerPage()),
    GoRoute(path: '/tools', builder: (_, __) => const ToolsPage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
  ],
);
