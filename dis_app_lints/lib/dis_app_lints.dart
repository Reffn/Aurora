import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/no_direct_gps_access.dart';
import 'src/no_direct_notification_plugin.dart';
import 'src/no_clock_in_reminder_rules.dart';
import 'src/no_future_in_build.dart';
import 'src/no_direct_service_access.dart';
import 'src/no_raw_tracking_flag.dart';
import 'src/no_saved_events_listener.dart';

/// Entry point for custom lint rules
PluginBase createPlugin() => _DisAppLints();

class _DisAppLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const NoDirectServiceAccess(),
        const NoSavedEventsListener(),
        const NoDirectGpsAccess(),
        const NoDirectNotificationPlugin(),
        const NoFutureInBuild(),
        const NoClockInReminderRules(),
        const NoRawTrackingFlag(),
      ];
}
