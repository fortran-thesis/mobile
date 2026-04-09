import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moldify/l10n/app_localizations.dart';
import 'package:moldify/pages/farmer/report/content_tab/report_disease_cycle_impact_tab.dart';
import 'package:moldify/pages/farmer/report/content_tab/report_hosts_symptoms_tab.dart';
import 'package:moldify/pages/farmer/report/content_tab/report_overview_tab.dart';

Widget _wrapForTest(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('overview tab renders canonical overview labels', (tester) async {
    await tester.pumpWidget(
      _wrapForTest(
        const ReportOverviewTab(
          sections: [],
        ),
      ),
    );

    expect(find.text('OVERVIEW'), findsOneWidget);
    expect(find.text('HEALTH RISKS'), findsOneWidget);
    expect(find.text('DETAILED DESCRIPTION'), findsNothing);
    expect(find.text('HEALTH & SAFETY RISK'), findsNothing);
  });

  testWidgets('hosts tab renders canonical host and symptom labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapForTest(
        const ReportHostsSymptomsTab(
          sections: [],
        ),
      ),
    );

    expect(find.text('AFFECTED HOSTS'), findsOneWidget);
    expect(find.text('SYMPTOMS AND SIGNS'), findsOneWidget);
    expect(find.text('SIGNS IN ONIONS'), findsNothing);
    expect(find.text('SIGNS IN POSTHARVEST FRUIT'), findsNothing);
  });

  testWidgets('disease cycle tab renders canonical section label only', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapForTest(
        const ReportDiseaseCycleImpactTab(
          sections: [],
        ),
      ),
    );

    expect(find.text('DISEASE CYCLE / SPREAD / IMPACT'), findsOneWidget);
    expect(find.text('PEANUT-SPECIFIC IMPACT'), findsNothing);
    expect(find.text('SOIL INOCULUM DETAILS'), findsNothing);
    expect(find.text('MYCOTOXIN RISK ASSESSMENT'), findsNothing);
  });
}
