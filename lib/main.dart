import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pilot_mocker/model/aircraft.dart';
import 'package:pilot_mocker/model/api.dart';
import 'package:pilot_mocker/model/thing.dart';
import 'package:pilot_mocker/model/third_cloud.dart';
import 'package:pilot_mocker/model/ws.dart';
import 'package:pilot_mocker/page/cloud_service_page.dart';
import 'package:pilot_mocker/page/home_page.dart';
import 'package:pilot_mocker/page/thirdpart_cloud_page.dart';
import 'package:pilot_mocker/page/web_view_page.dart';
import 'package:provider/provider.dart';
import 'package:pilot_mocker/job/thing/aircraft_report_task.dart';
import 'package:pilot_mocker/job/task_manager.dart';
import 'package:pilot_mocker/client/shared_client_isolate.dart';

WebViewEnvironment? webViewEnvironment;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    final availableVersion = await WebViewEnvironment.getAvailableVersion();
    assert(
      availableVersion != null,
      'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.',
    );

    webViewEnvironment = await WebViewEnvironment.create(
      settings: WebViewEnvironmentSettings(userDataFolder: 'YOUR_CUSTOM_PATH'),
    );
  }
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final TaskManager _taskManager;
  bool _tasksStarted = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AircraftModel>(
          create: (_) => AircraftModel(),
        ),
        ChangeNotifierProvider<ThingModel>(
          create: (_) => ThingModel(),
        ),
        ChangeNotifierProvider<ApiModel>(
          create: (_) => ApiModel(),
        ),
        ChangeNotifierProvider<WsModel>(
          create: (_) => WsModel(),
        ),
        ChangeNotifierProvider<ThirdCloudModel>(
          create: (_) => ThirdCloudModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Pilot 2 Mocker',
        theme: ThemeData(brightness: Brightness.light, primaryColor: Colors.blue),
        builder: (context, child) {
          if (!_tasksStarted) {
            _taskManager = TaskManager();
            final aircraft = Provider.of<AircraftModel>(context, listen: false);
            final client = SharedClientIsolate();
            _taskManager.register(AircraftReportTask(aircraft, client));
            _taskManager.startAll();
            _tasksStarted = true;
          }
          return child!;
        },
        home: const HomePage(),
        routes: {
          '/home': (context) => const HomePage(),
          '/thirdpart_cloud': (context) => const ThirdPartCloudPage(),
          '/cloud_service': (context) => const CloudServicePage(),
        },
        onGenerateRoute:
            (settings) => MaterialPageRoute(
              builder: (context) {
                if (settings.name == '/web_view') {
                  final args = settings.arguments as Map<String, dynamic>?;
                  final url = args?['url'] as String?;
                  return WebViewPage(url: url ?? '');
                }
                return const HomePage();
              },
            ),
      ),
    );
  }
}
