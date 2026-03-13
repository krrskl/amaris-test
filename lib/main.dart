import 'package:amaris_test/presentation/startup/startup.dart';
import 'package:amaris_test/presentation/startup/startup_app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: StartupWidget(onLoaded: _onLoaded)));
}

Widget _onLoaded(BuildContext context) => const StartupApp();
