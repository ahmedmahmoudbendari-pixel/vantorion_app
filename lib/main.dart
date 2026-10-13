import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const VantorionApp());
}

class VantorionApp extends StatelessWidget {
  const VantorionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vantorion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double balance = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VANTORION'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFF1E1E2C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    const Text('رصيدك الحالي', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text('$balance ج.م', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskScreen()));
              },
              icon: const Icon(Icons.add_task, color: Colors.white),
              label: const Text('بدء مهمة جديدة (7.5 ج)', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String emailToCreate = "vantorion_user101@gmail.com";
    const String passwordToUse = "aass1122";

    return Scaffold(
      appBar: AppBar(title: const Text('المهمة الحالية')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('قم بإنشاء حساب Gmail بالبيانات التالية:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            _buildItem(context, 'البريد المطلوب:', emailToCreate),
            _buildItem(context, 'كلمة السر:', passwordToUse),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال المهمة للمراجعة!')));
                  Navigator.pop(context);
                },
                child: const Text('✅ تم إنشاء الحساب', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2C), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.deepPurpleAccent),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم نسخ $title')));
            },
          )
        ],
      ),
    );
  }
}

