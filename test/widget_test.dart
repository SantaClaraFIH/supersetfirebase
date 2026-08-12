import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supersetfirebase/main.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/theme_provider.dart';

void main() {
  testWidgets('builds the application shell', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('🎮 Let\'s Play & Learn! 🎮'), findsOneWidget);
  });
}
