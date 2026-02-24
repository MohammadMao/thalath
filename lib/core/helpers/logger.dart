import 'package:logging/logging.dart' as logging;

final logger = logging.Logger('thalath');

void setupLogging() {
  logging.Logger.root.level = logging.Level.ALL;
  logging.Logger.root.onRecord.listen((record) {
    print(
      '[${record.loggerName}] ${record.level.name}: ${record.time} - ${record.message}',
    );
  });
}
