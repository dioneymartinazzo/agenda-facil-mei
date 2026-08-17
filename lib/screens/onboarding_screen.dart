import 'package:flutter/material.dart';
import 'home_screen.dart';
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.calendar_month, size:100, color: Colors.deepPurple),
      const SizedBox(height:20),
      const Text('Agenda Facil MEI', style: TextStyle(fontSize:28, fontWeight: FontWeight.bold)),
      const SizedBox(height:20),
      ElevatedButton(onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeScreen())), child: const Text('Comecar')),
    ])));
  }
}
