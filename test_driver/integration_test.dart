import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// драйвер для flutter drive: зберігає скриншоти з інтеграційного тесту
/// у папку report_screens/ в корені проєкту
Future<void> main() => integrationDriver(
      onScreenshot: (name, bytes, [args]) async {
        final file = File('report_screens/$name.png');
        await file.create(recursive: true);
        await file.writeAsBytes(bytes);
        return true;
      },
    );
