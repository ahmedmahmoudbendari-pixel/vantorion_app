import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _isLoading = true;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    setState(() {
      _userEmail = savedEmail;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent)),
      );
    }
    return _userEmail == null ? const LoginScreen() : MainNavigationScreen(userEmail: _userEmail!);
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isRegistering = false;

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة بريد صحيح وكلمة سر 6 أرقام على الأقل')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen(userEmail: email)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.bolt, size: 70, color: Colors.deepPurpleAccent),
              const SizedBox(height: 10),
              const Text('منصة VANTORION', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text('سجل حسابك للبدء في كسب الأرصدة والسحب الفوري', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  filled: true,
                  fillColor: const Color(0xFF1E1E2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة السر',
                  filled: true,
                  fillColor: const Color(0xFF1E1E2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleAuth,
                child: Text(_isRegistering ? 'إنشاء حساب جديد' : 'تسجيل الدخول', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                child: Text(_isRegistering ? 'لديك حساب بالفعل؟ سجل دخولك' : 'حساب جديد؟ انقر هنا للإنشاء', style: const TextStyle(color: Colors.grey)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final String userEmail;
  const MainNavigationScreen({super.key, required this.userEmail});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  double _balance = 0.0;
  int _completedTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _balance = prefs.getDouble('balance_${widget.userEmail}') ?? 0.0;
      _completedTasks = prefs.getInt('tasks_${widget.userEmail}') ?? 0;
    });
  }

  Future<void> _updateBalance(double addedAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final newBal = _balance + addedAmount;
    final newTasks = _completedTasks + 1;
    await prefs.setDouble('balance_${widget.userEmail}', newBal);
    await prefs.setInt('tasks_${widget.userEmail}', newTasks);

    setState(() {
      _balance = newBal;
      _completedTasks = newTasks;
    });
  }

  Future<void> _deductBalance(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final newBal = _balance - amount;
    await prefs.setDouble('balance_${widget.userEmail}', newBal);

    setState(() {
      _balance = newBal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        userEmail: widget.userEmail,
        balance: _balance,
        completedTasks: _completedTasks,
        onNavigateToTasks: () => setState(() => _currentIndex = 1),
        onNavigateToWithdraw: () => setState(() => _currentIndex = 2),
      ),
      TasksScreen(onTaskCompleted: _updateBalance),
      WithdrawScreen(
        userEmail: widget.userEmail,
        balance: _balance,
        onWithdrawSuccess: _deductBalance,
      ),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: IndexedStack(index: _currentIndex, children: screens),
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

class HomeScreen extends StatelessWidget {
  final String userEmail;
  final double balance;
  final int completedTasks;
  final VoidCallback onNavigateToTasks;
  final VoidCallback onNavigateToWithdraw;

  const HomeScreen({
    super.key,
    required this.userEmail,
    required this.balance,
    required this.completedTasks,
    required this.onNavigateToTasks,
    required this.onNavigateToWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فانتوريون | Vantorion'),
        backgroundColor: const Color(0xFF1E1E2C),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_email');
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('مرحباً، $userEmail', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('الرصيد المتاح للسحب', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('${balance.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Divider(color: Colors.white24, height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 5),
                      Text('إجمالي المهام المكتملة: $completedTasks', style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: onNavigateToTasks,
                    icon: const Icon(Icons.add_task, color: Colors.white),
                    label: const Text('بدء مهمة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: onNavigateToWithdraw,
                    icon: const Icon(Icons.output, color: Colors.white),
                    label: const Text('طلب سحب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  final Function(double) onTaskCompleted;
  const TasksScreen({super.key, required this.onTaskCompleted});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {'title': 'إنشاء حساب Gmail جديد', 'reward': 7.5, 'desc': 'قم بإنشاء حساب جوجل بالبيانات المحددة وتسليمه.'},
      {'title': 'إنشاء حساب Outlook جديد', 'reward': 5.0, 'desc': 'قم بإنشاء حساب مايكروسوفت واضغط تأكيد.'},
      {'title': 'الانضمام إلى قناة التليجرام', 'reward': 2.0, 'desc': 'اشترك بالقناة وارفق اليوزر للتأكيد.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('المهام المتاحة'), backgroundColor: const Color(0xFF1E1E2C)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(task['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(task['desc'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: () {
                  onTaskCompleted(task['reward'] as double);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم إنهاء المهمة وإضافة ${task["reward"]} ج.م إلى حسابك!')),
                  );
                },
                child: Text('+${task["reward"]} ج.م', style: const TextStyle(color: Colors.greenAccent)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WithdrawScreen extends StatefulWidget {
  final String userEmail;
  final double balance;
  final Function(double) onWithdrawSuccess;

  const WithdrawScreen({super.key, required this.userEmail, required this.balance, required this.onWithdrawSuccess});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String _selectedMethod = 'فودافون كاش';
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();

  void _submitWithdraw() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final walletNumber = _numberController.text.trim();

    if (walletNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة رقم المحفظة')));
      return;
    }
    if (amount < 50.0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الحد الأدنى للسحب هو 50 ج.م')));
      return;
    }
    if (amount > widget.balance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رصيدك الفعلي لا يكفي لهذا الطلب')));
      return;
    }

    widget.onWithdrawSuccess(amount);
    _numberController.clear();
    _amountController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('تم تسجيل الطلب بنجاح 🚀'),
        content: Text('تم خصم $amount ج.م وتسجيل الطلب برقم المحفظة ($walletNumber) عبر $_selectedMethod وسيتم التحويل قريباً.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً', style: TextStyle(color: Colors.greenAccent))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب سحب الأرصدة'), backgroundColor: const Color(0xFF1E1E2C)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('رصيدك القابل للسحب:'),
                    Text('${widget.balance.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E1E2C), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              dropdownColor: const Color(0xFF1E1E2C),
              items: ['فودافون كاش', 'اتصالات كاش', 'أورانج كاش', 'WE Pay', 'Binance USDT'].map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(hintText: 'رقم المحفظة / العنوان', filled: true, fillColor: const Color(0xFF1E1E2C), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'المبلغ (الحد الأدنى 50 ج.م)', filled: true, fillColor: const Color(0xFF1E1E2C), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _submitWithdraw,
                child: const Text('تأكيد وإرسال الطلب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل المعاملات'), backgroundColor: const Color(0xFF1E1E2C)),
      body: const Center(
        child: Text('لا توجد سحوبات سابقة مكتملة حتى الآن', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
