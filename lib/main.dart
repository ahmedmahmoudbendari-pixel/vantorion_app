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
        cardColor: const Color(0xFF1E1E2C),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  double _balance = 45.0;
  double _pendingBalance = 15.0;
  int _completedTasks = 6;

  void _addBalance(double amount) {
    setState(() {
      _balance += amount;
      _completedTasks += 1;
    });
  }

  void _withdraw(double amount) {
    setState(() {
      _balance -= amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        balance: _balance,
        pendingBalance: _pendingBalance,
        completedTasks: _completedTasks,
        onNavigateToTasks: () => setState(() => _currentIndex = 1),
        onNavigateToWithdraw: () => setState(() => _currentIndex = 2),
      ),
      TasksScreen(onTaskCompleted: _addBalance),
      WithdrawScreen(
        balance: _balance,
        onWithdrawSuccess: _withdraw,
      ),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF1E1E2C),
          selectedItemColor: Colors.deepPurpleAccent,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'المهام'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'السحب'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'السجل'),
          ],
        ),
      ),
    );
  }
}

// --- الرئيسية والرصيد ---
class HomeScreen extends StatelessWidget {
  final double balance;
  final double pendingBalance;
  final int completedTasks;
  final VoidCallback onNavigateToTasks;
  final VoidCallback onNavigateToWithdraw;

  const HomeScreen({
    super.key,
    required this.balance,
    required this.pendingBalance,
    required this.completedTasks,
    required this.onNavigateToTasks,
    required this.onNavigateToWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فانتوريون | Vantorion', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  const Text('الرصيد المتاح للسحب', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('${balance.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Divider(color: Colors.white24, height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('رصيد معلق', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          Text('${pendingBalance.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('المهام المكتملة', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          Text('$completedTasks مهمة', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onNavigateToTasks,
                    icon: const Icon(Icons.add_task, color: Colors.white),
                    label: const Text('بدء مهمة', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onNavigateToWithdraw,
                    icon: const Icon(Icons.output, color: Colors.white),
                    label: const Text('طلب سحب', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const ListTile(
                leading: Icon(Icons.notifications_active, color: Colors.amber),
                title: Text('إشعار هام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('الحد الأدنى للسحب هو 50 ج.م على فودافون كاش والمحافظ الإلكترونية.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- قسم المهام ---
class TasksScreen extends StatelessWidget {
  final Function(double) onTaskCompleted;

  const TasksScreen({super.key, required this.onTaskCompleted});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {'title': 'إنشاء حساب Gmail جديد', 'reward': 7.5, 'desc': 'قم بإنشاء حساب جوجل وتوفير البيانات المطلوبة.'},
      {'title': 'إنشاء حساب Outlook / Hotmail', 'reward': 5.0, 'desc': 'قم بإنشاء حساب مايكروسوفت وتسليم الكود.'},
      {'title': 'الاشتراك في قناة التليجرام', 'reward': 2.0, 'desc': 'انضم للقناة وارفق يوزر حسابك للتأكيد.'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المهام المتاحة'),
        backgroundColor: const Color(0xFF1E1E2C),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(task['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text('+${task['reward']} ج.م', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(task['desc'] as String, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                      onPressed: () {
                        _showTaskDetailsDialog(context, task['title'] as String, task['reward'] as double);
                      },
                      child: const Text('تنفيذ المهمة', style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, String title, double reward) {
    final emailController = TextEditingController(text: "vantorion_${DateTime.now().millisecondsSinceEpoch ~/ 1000}@gmail.com");
    final passController = TextEditingController(text: "VantorionPass2026");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20, left: 20, right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('قم بإدخال البيانات التالية أثناء إنشاء الحساب:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              _buildCopyTile(context, 'البريد الإلكتروني:', emailController.text),
              _buildCopyTile(context, 'كلمة السر:', passController.text),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    onTaskCompleted(reward);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم إرسال مهمة ($title) للمراجعة وإضافة $reward ج.م!')),
                    );
                  },
                  child: const Text('✅ تأكيد وإرسال المهمة', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildCopyTile(BuildContext context, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.deepPurpleAccent, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم نسخ $label')));
            },
          )
        ],
      ),
    );
  }
}

// --- قسم السحب ---
class WithdrawScreen extends StatefulWidget {
  final double balance;
  final Function(double) onWithdrawSuccess;

  const WithdrawScreen({super.key, required this.balance, required this.onWithdrawSuccess});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String _selectedMethod = 'فودافون كاش';
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قسم طلب السحب'),
        backgroundColor: const Color(0xFF1E1E2C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('رصيدك المتاح:', style: TextStyle(fontSize: 16)),
                    Text('${widget.balance.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('اختر طريقة السحب:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              dropdownColor: const Color(0xFF1E1E2C),
              items: ['فودافون كاش', 'اتصالات كاش', 'أورانج كاش', 'WE Pay', 'Binance USDT'].map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
            const SizedBox(height: 15),

            const Text('رقم المحفظة / العنوان:', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'ادخل رقم المحفظة هنا',
                filled: true,
                fillColor: const Color(0xFF1E1E2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),

            const Text('المبلغ المطلوب (ج.م):', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'الحد الأدنى 50 ج.م',
                filled: true,
                fillColor: const Color(0xFF1E1E2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleWithdrawSubmit,
                child: const Text('تأكيد طلب السحب', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleWithdrawSubmit() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final number = _numberController.text.trim();

    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة رقم المحفظة')));
      return;
    }

    if (amount < 50.0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الحد الأدنى للسحب هو 50 ج.م')));
      return;
    }

    if (amount > widget.balance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رصيدك الحالي غير كافٍ')));
      return;
    }

    widget.onWithdrawSuccess(amount);
    _numberController.clear();
    _amountController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('تم إرسال الطلب بنجاح 🚀'),
        content: Text('تم تسجيل طلب سحب مبلغ $amount ج.م عبر $_selectedMethod وسيتم التحويل خلال 24 ساعة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(color: Colors.greenAccent)),
          )
        ],
      ),
    );
  }
}

// --- قسم سجل المعاملات ---
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyItems = [
      {'title': 'سحب فودافون كاش', 'amount': '-50.0 ج.م', 'date': 'اليوم 01:15 PM', 'status': 'مقبول ✅', 'color': Colors.greenAccent},
      {'title': 'إتمام مهمة Gmail', 'amount': '+7.5 ج.م', 'date': 'أمس 04:30 PM', 'status': 'تم الاعتماد', 'color': Colors.blueAccent},
      {'title': 'إتمام مهمة تليجرام', 'amount': '+2.0 ج.م', 'date': 'منذ يومين', 'status': 'تم الاعتماد', 'color': Colors.blueAccent},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المعاملات'),
        backgroundColor: const Color(0xFF1E1E2C),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.withOpacity(0.3),
                child: const Icon(Icons.swap_horiz, color: Colors.white),
              ),
              title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item['date']} | ${item['status']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: Text(item['amount'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: item['color'] as Color)),
            ),
          );
        },
      ),
    );
  }
}
