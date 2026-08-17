import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/agenda_provider.dart';
import 'screens/onboarding_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=>AgendaProvider(),
      child: MaterialApp(title: 'Agenda Facil MEI', debugShowCheckedModeBanner: false, theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true), home: const OnboardingScreen()),
    );
  }
}
