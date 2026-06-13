import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/product.dart';
import 'models/transaction.dart';
import 'models/debt.dart';
import 'models/expense.dart';
import 'models/purchase_order.dart';
import 'models/business_profile.dart';
import 'providers/product_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/purchase_order_provider.dart';
import 'providers/business_profile_provider.dart';
import 'screens/terminal_screen.dart';
import 'screens/stock_screen.dart';
import 'screens/buy_list_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/history_screen.dart';
import 'screens/debts_screen.dart';
import 'screens/expenditure_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(TransactionItemAdapter());
  Hive.registerAdapter(DebtAdapter());
  Hive.registerAdapter(DebtPaymentAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(PurchaseOrderAdapter());
  Hive.registerAdapter(PurchaseOrderItemAdapter());
  Hive.registerAdapter(BusinessProfileAdapter());
  await Hive.openBox<Product>('products');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Debt>('debts');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<PurchaseOrder>('purchase_orders');
  await Hive.openBox<BusinessProfile>('business_profile');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseOrderProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Local POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFC107),
            primary: const Color(0xFFFFC107),
            secondary: const Color(0xFF00897B),
            surface: Colors.white,
            error: const Color(0xFFF44336),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F7F7),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TerminalScreen(),
    const StockScreen(),
    const BuyListScreen(),
    const ReportsScreen(),
    const HistoryScreen(),
    const DebtsScreen(),
    const ExpenditureScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: const Color(0xFF9E9E9E),
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Termi...',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Buy List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Debts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Expend...',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
