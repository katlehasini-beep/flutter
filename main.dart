import 'package:flutter/material.dart';

// ============================================================================
// 1. DATA MODELS & ENUMS
// ============================================================================

enum IncomeFrequency { daily, weekly, monthly, yearly, oneTime }

enum ExpenseCategory {
  grocery,
  rent,
  transport,
  utilities,
  education,
  medical,
  debtEmi,
  family,
  personal,
  lifestyle,
  emergency,
  other
}

enum ExpenseClassification { essential, important, flexible, optional, debt }

enum GoalType { education, vehicle, house, emergencyFund, travel, other }

class UserProfile {
  String name;
  int age;
  String occupation;
  String location;
  int adults;
  int children;
  int parents;
  int otherDependents;

  UserProfile({
    required this.name,
    required this.age,
    required this.occupation,
    required this.location,
    required this.adults,
    required this.children,
    required this.parents,
    required this.otherDependents,
  });

  int get totalFamilyMembers => adults + children + parents + otherDependents;
}

class IncomeEntry {
  final String id;
  final String title;
  final double amount;
  final IncomeFrequency frequency;

  IncomeEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.frequency,
  });

  /// Step 3: Income Normalization to Monthly Value
  double get monthlyAmount {
    switch (frequency) {
      case IncomeFrequency.daily:
        return amount * 30;
      case IncomeFrequency.weekly:
        return amount * 4.33;
      case IncomeFrequency.monthly:
        return amount;
      case IncomeFrequency.yearly:
        return amount / 12;
      case IncomeFrequency.oneTime:
        return amount / 12;
    }
  }
}

class ExpenseEntry {
  final String id;
  final String title;
  double plannedAmount;
  double actualAmount;
  final ExpenseCategory category;
  final ExpenseClassification classification;

  ExpenseEntry({
    required this.id,
    required this.title,
    required this.plannedAmount,
    this.actualAmount = 0.0,
    required this.category,
    required this.classification,
  });
}

class FinancialGoal {
  final String id;
  final String title;
  final GoalType type;
  final double targetAmount;
  double savedAmount;
  final int targetMonths;

  FinancialGoal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetMonths,
  });

  double get remainingAmount => targetAmount - savedAmount;
  double get requiredMonthly => targetMonths > 0 ? (remainingAmount / targetMonths) : 0;
}

class TripPlan {
  final String destination;
  final int monthsToTrip;
  final double transportCost;
  final double hotelCost;
  final double foodCost;
  final double activitiesCost;
  double savedAmount;

  TripPlan({
    required this.destination,
    required this.monthsToTrip,
    required this.transportCost,
    required this.hotelCost,
    required this.foodCost,
    required this.activitiesCost,
    this.savedAmount = 0.0,
  });

  double get totalCost => transportCost + hotelCost + foodCost + activitiesCost;
  double get remainingCost => totalCost - savedAmount;
  double get requiredMonthly => monthsToTrip > 0 ? (remainingCost / monthsToTrip) : 0;
}


class BudgetAccount {
  final UserProfile profile;
  final List<IncomeEntry> incomes;
  final List<ExpenseEntry> expenses;
  final List<FinancialGoal> goals;
  final TripPlan activeTrip;

  BudgetAccount({
    required this.profile,
    List<IncomeEntry>? incomes,
    List<ExpenseEntry>? expenses,
    List<FinancialGoal>? goals,
    TripPlan? activeTrip,
  })  : incomes = incomes ?? <IncomeEntry>[],
        expenses = expenses ?? <ExpenseEntry>[],
        goals = goals ?? <FinancialGoal>[],
        activeTrip = activeTrip ?? TripPlan(
          destination: 'My Trip', monthsToTrip: 12,
          transportCost: 0, hotelCost: 0, foodCost: 0, activitiesCost: 0,
        );
}

// ============================================================================
// 2. MAIN APP ENTRY POINT
// ============================================================================

void main() {
  runApp(const SimpleBudgetPlannerApp());
}

class SimpleBudgetPlannerApp extends StatelessWidget {
  const SimpleBudgetPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Budget Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      home: const MainDashboardScreen(),
    );
  }
}

// ============================================================================
// 3. DASHBOARD & ARCHITECTURE IMPLEMENTATION SCREEN
// ============================================================================

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // Each person has an independent budget account. Selecting a profile switches
  // the income, expenses, goals, trip and reports shown throughout the app.
  late final List<BudgetAccount> _accounts = [
    BudgetAccount(
      profile: UserProfile(
        name: 'Rahul Sharma', age: 32, occupation: 'Software Engineer',
        location: 'Hyderabad', adults: 2, children: 1, parents: 1,
        otherDependents: 0,
      ),
      incomes: [
        IncomeEntry(id: '1', title: 'Primary Salary', amount: 60000, frequency: IncomeFrequency.monthly),
        IncomeEntry(id: '2', title: 'Freelance Consulting', amount: 2000, frequency: IncomeFrequency.weekly),
      ],
      expenses: [
        ExpenseEntry(id: '1', title: 'Groceries', plannedAmount: 12000, actualAmount: 13200, category: ExpenseCategory.grocery, classification: ExpenseClassification.essential),
        ExpenseEntry(id: '2', title: 'House Rent', plannedAmount: 18000, actualAmount: 18000, category: ExpenseCategory.rent, classification: ExpenseClassification.essential),
        ExpenseEntry(id: '3', title: 'Utilities & Wifi', plannedAmount: 3500, actualAmount: 3200, category: ExpenseCategory.utilities, classification: ExpenseClassification.essential),
        ExpenseEntry(id: '4', title: 'Car Loan EMI', plannedAmount: 7500, actualAmount: 7500, category: ExpenseCategory.debtEmi, classification: ExpenseClassification.debt),
        ExpenseEntry(id: '5', title: 'Dining & Movies', plannedAmount: 6000, actualAmount: 4500, category: ExpenseCategory.lifestyle, classification: ExpenseClassification.optional),
      ],
      goals: [
        FinancialGoal(id: '1', title: 'Child Education', type: GoalType.education, targetAmount: 200000, savedAmount: 50000, targetMonths: 24),
        FinancialGoal(id: '2', title: 'Emergency Reserve', type: GoalType.emergencyFund, targetAmount: 100000, savedAmount: 60000, targetMonths: 10),
      ],
      activeTrip: TripPlan(destination: 'Goa Holiday', monthsToTrip: 8, transportCost: 12000, hotelCost: 16000, foodCost: 8000, activitiesCost: 4000, savedAmount: 8000),
    ),
  ];

  int _selectedAccountIndex = 0;
  BudgetAccount get _currentAccount => _accounts[_selectedAccountIndex];
  UserProfile get _profile => _currentAccount.profile;
  List<IncomeEntry> get _incomes => _currentAccount.incomes;
  List<ExpenseEntry> get _expenses => _currentAccount.expenses;
  List<FinancialGoal> get _goals => _currentAccount.goals;
  TripPlan get _activeTrip => _currentAccount.activeTrip;

  // --------------------------------------------------------------------------
  // Step 8: Financial Calculation Engine
  // --------------------------------------------------------------------------
  double get _totalNormalizedMonthlyIncome => _incomes.fold(0.0, (sum, i) => sum + i.monthlyAmount);

  double get _totalPlannedExpenses => _expenses.fold(0.0, (sum, e) => sum + e.plannedAmount);

  double get _totalActualExpenses => _expenses.fold(0.0, (sum, e) => sum + e.actualAmount);

  double get _essentialExpenses => _expenses
      .where((e) => e.classification == ExpenseClassification.essential)
      .fold(0.0, (sum, e) => sum + e.actualAmount);

  double get _debtObligations => _expenses
      .where((e) => e.classification == ExpenseClassification.debt)
      .fold(0.0, (sum, e) => sum + e.actualAmount);

  double get _availableIncome => _totalNormalizedMonthlyIncome - _totalActualExpenses;

  // Fixed fold initial values to 0.0 so double is expected
  double get _totalRequiredMonthlyGoals => _goals.fold(0.0, (sum, g) => sum + g.requiredMonthly) + _activeTrip.requiredMonthly;

  // --------------------------------------------------------------------------
  // Step 13: Rule-Based AI Engine
  // --------------------------------------------------------------------------
  List<String> _generateAIInsights() {
    List<String> insights = [];

    double debtRatio = (_debtObligations / _totalNormalizedMonthlyIncome) * 100;
    if (debtRatio > 40) {
      insights.add('⚠️ High Debt Warning: Your debt obligations take up ${debtRatio.toStringAsFixed(1)}% of income.');
    } else {
      insights.add('✅ Healthy Debt Level: Debt EMI is within manageable limits.');
    }

    double diff = _totalActualExpenses - _totalPlannedExpenses;
    if (diff > 0) {
      insights.add('🚨 Budget Overrun: You spent ₹${diff.toStringAsFixed(0)} more than planned this month.');
    } else if (diff < 0) {
      insights.add('🎉 Savings Boost: You are under budget by ₹${diff.abs().toStringAsFixed(0)} this month!');
    } else {
      insights.add('🎯 Perfect Alignment: Actual spending matches the planned budget exact.');
    }

    if (_availableIncome < _totalRequiredMonthlyGoals) {
      insights.add('💡 Rebalance Suggested: Available balance (₹${_availableIncome.toStringAsFixed(0)}) is lower than total goal targets (₹${_totalRequiredMonthlyGoals.toStringAsFixed(0)}). Consider extending target dates.');
    } else {
      insights.add('🌟 Goal Capable: You have enough remaining capacity to fund all monthly goal targets.');
    }

    return insights;
  }

  // --------------------------------------------------------------------------
  // Step 17: Smart Budget Rebalancing Engine
  // --------------------------------------------------------------------------
  void _executeSmartRebalance() {
    setState(() {
      double totalSurplusDeficit = 0.0;

      for (var expense in _expenses) {
        totalSurplusDeficit += (expense.actualAmount - expense.plannedAmount);
      }

      if (totalSurplusDeficit > 0) {
        for (var expense in _expenses) {
          if (expense.classification == ExpenseClassification.optional || expense.classification == ExpenseClassification.flexible) {
            double trimAmount = (totalSurplusDeficit > 1000) ? 1000 : totalSurplusDeficit;
            if (expense.plannedAmount > trimAmount) {
              expense.plannedAmount -= trimAmount;
              totalSurplusDeficit -= trimAmount;
            }
          }
          if (totalSurplusDeficit <= 0) break;
        }
      } else if (totalSurplusDeficit < 0) {
        if (_goals.isNotEmpty) {
          _goals.first.savedAmount += totalSurplusDeficit.abs();
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Smart Budget Rebalance executed successfully!')),
    );
  }

  // ==========================================================================
  // UI BUILDERS
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Budget Planner'),
          elevation: 2,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Income & Expense'),
              Tab(icon: Icon(Icons.flag), text: 'Goals & Trips'),
              Tab(icon: Icon(Icons.analytics), text: 'AI Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDashboardTab(),
            _buildIncomeExpenseTab(),
            _buildGoalsTripTab(),
            _buildAIReportsTab(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAB 1: Step 18 - Financial Dashboard
  // --------------------------------------------------------------------------
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('${_profile.name} (${_profile.age} yrs)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${_profile.occupation} • ${_profile.location}\nFamily Size: ${_profile.totalFamilyMembers} Members (${_profile.children} Children, ${_profile.parents} Parents)'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: List.generate(_accounts.length, (index) {
                          final account = _accounts[index];
                          return ChoiceChip(
                            avatar: const Icon(Icons.person, size: 16),
                            label: Text(account.profile.name),
                            selected: index == _selectedAccountIndex,
                            onSelected: (_) => setState(() => _selectedAccountIndex = index),
                          );
                        }),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _showAddPersonDialog,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Add Person'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Financial Overview (Monthly Normalized)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatCard('Income', '₹${_totalNormalizedMonthlyIncome.toStringAsFixed(0)}', Colors.green),
              _buildStatCard('Expenses', '₹${_totalActualExpenses.toStringAsFixed(0)}', Colors.red),
            ],
          ),
          Row(
            children: [
              _buildStatCard('Available Balance', '₹${_availableIncome.toStringAsFixed(0)}', _availableIncome >= 0 ? Colors.teal : Colors.orange),
              _buildStatCard('Goal Targets', '₹${_totalRequiredMonthlyGoals.toStringAsFixed(0)}', Colors.blue),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _executeSmartRebalance,
              icon: const Icon(Icons.autorenew),
              label: const Text('Execute Smart Budget Rebalance'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('AI Budget Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Divider(),
                  ..._generateAIInsights().map((insight) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(insight, style: const TextStyle(fontSize: 13)),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAB 2: Step 2 to 7 - Income & Expense Management
  // --------------------------------------------------------------------------
  Widget _buildIncomeExpenseTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Incomes (Step 2 & 3)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: _showAddIncomeDialog),
          ],
        ),
        ..._incomes.map((i) => Card(
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: Text(i.title),
                subtitle: Text('${i.frequency.name.toUpperCase()} (Normalized: ₹${i.monthlyAmount.toStringAsFixed(0)}/mo)'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₹${i.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    PopupMenuButton<String>(
                      tooltip: 'Manage income',
                      onSelected: (action) {
                        if (action == 'edit') _showEditIncomeDialog(i);
                        if (action == 'delete') _confirmDeleteIncome(i);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                        PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete'))),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Expenses (Step 5 - 7 & 16)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add_circle, color: Colors.red), onPressed: _showAddExpenseDialog),
          ],
        ),
        ..._expenses.map((e) => Card(
              child: ListTile(
                title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Category: ${e.category.name} | Type: ${e.classification.name.toUpperCase()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Plan: ₹${e.plannedAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Actual: ₹${e.actualAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: e.actualAmount > e.plannedAmount ? Colors.red : Colors.green,
                            )),
                      ],
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Manage expense',
                      onSelected: (action) {
                        if (action == 'edit') _showEditExpenseDialog(e);
                        if (action == 'delete') _confirmDeleteExpense(e);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                        PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete'))),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // TAB 3: Step 11 & 12 - Financial Goals & Trip Planner
  // --------------------------------------------------------------------------
  Widget _buildGoalsTripTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Financial Goals (Step 11)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            FilledButton.icon(
              onPressed: _showAddFinancialGoalDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Goal'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_goals.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No financial goals yet. Tap “Add Goal” to create your first goal.'),
            ),
          ),
        ..._goals.map((g) {
          double progress = (g.savedAmount / g.targetAmount).clamp(0.0, 1.0);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(g.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Target: ₹${g.targetAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: Colors.teal),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saved: ₹${g.savedAmount.toStringAsFixed(0)} (${(progress * 100).toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 11)),
                      Text('Req. Monthly: ₹${g.requiredMonthly.toStringAsFixed(0)}/mo', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const Divider(height: 32),
        const Text('Trip Planner (Step 12)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          color: Colors.amber.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_activeTrip.destination, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Chip(label: Text('${_activeTrip.monthsToTrip} months away', style: const TextStyle(fontSize: 10))),
                  ],
                ),
                Text('Total Cost: ₹${_activeTrip.totalCost.toStringAsFixed(0)} | Saved: ₹${_activeTrip.savedAmount.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                Text('Required Monthly Contribution: ₹${_activeTrip.requiredMonthly.toStringAsFixed(0)}/mo',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // TAB 4: Step 19 - Reports & Final Result
  // --------------------------------------------------------------------------
  Widget _buildAIReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('Final Financial Status Report (Step 19)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildReportRow('Total Income (Normalized)', '₹${_totalNormalizedMonthlyIncome.toStringAsFixed(0)}'),
                _buildReportRow('Essential Expenses', '₹${_essentialExpenses.toStringAsFixed(0)}'),
                _buildReportRow('Debt / Loan Obligations', '₹${_debtObligations.toStringAsFixed(0)}'),
                _buildReportRow('Other Expenses', '₹${(_totalActualExpenses - _essentialExpenses - _debtObligations).toStringAsFixed(0)}'),
                const Divider(),
                _buildReportRow('Net Available Surplus', '₹${_availableIncome.toStringAsFixed(0)}', isBold: true),
                _buildReportRow('Total Goals Allocation', '₹${_totalRequiredMonthlyGoals.toStringAsFixed(0)}', isBold: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // ==========================================================================
  // DIALOGS
  // ==========================================================================

  void _showAddPersonDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final occupationController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create a Separate Budget'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameController, textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name')),
            TextField(controller: ageController, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age')),
            TextField(controller: occupationController,
              decoration: const InputDecoration(labelText: 'Occupation')),
            TextField(controller: locationController,
              decoration: const InputDecoration(labelText: 'City / Location')),
            const SizedBox(height: 8),
            const Text("This creates a separate budget. It will not be added to Rahul Sharma's family."),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final age = int.tryParse(ageController.text.trim()) ?? 0;
              if (name.isEmpty || age <= 0) return;
              setState(() {
                _accounts.add(BudgetAccount(
                  profile: UserProfile(
                    name: name, age: age,
                    occupation: occupationController.text.trim().isEmpty ? 'Not specified' : occupationController.text.trim(),
                    location: locationController.text.trim().isEmpty ? 'Not specified' : locationController.text.trim(),
                    adults: 1, children: 0, parents: 0, otherDependents: 0,
                  ),
                ));
                _selectedAccountIndex = _accounts.length - 1;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Separate budget created for $name')),
              );
            },
            child: const Text('Create Budget'),
          ),
        ],
      ),
    );
  }

  void _showAddFinancialGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final savedController = TextEditingController(text: '0');
    final monthsController = TextEditingController(text: '12');
    GoalType selectedType = GoalType.other;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Financial Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Goal name', hintText: 'e.g. Buy a car'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<GoalType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Goal category'),
                  items: GoalType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(_goalTypeLabel(type)),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedType = value);
                  },
                ),
                TextField(
                  controller: targetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Target amount (₹)'),
                ),
                TextField(
                  controller: savedController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount already saved (₹)'),
                ),
                TextField(
                  controller: monthsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target timeline (months)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final target = double.tryParse(targetController.text.trim()) ?? 0;
                final saved = double.tryParse(savedController.text.trim()) ?? 0;
                final months = int.tryParse(monthsController.text.trim()) ?? 0;
                if (title.isEmpty || target <= 0 || saved < 0 || months <= 0 || saved > target) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a goal name, valid target/saved amounts, and a timeline greater than zero.')),
                  );
                  return;
                }
                setState(() {
                  _goals.add(FinancialGoal(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    title: title,
                    type: selectedType,
                    targetAmount: target,
                    savedAmount: saved,
                    targetMonths: months,
                  ));
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Financial goal "$title" added')),
                );
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }

  String _goalTypeLabel(GoalType type) {
    switch (type) {
      case GoalType.education:
        return 'Education';
      case GoalType.vehicle:
        return 'Vehicle';
      case GoalType.house:
        return 'House';
      case GoalType.emergencyFund:
        return 'Emergency Fund';
      case GoalType.travel:
        return 'Travel';
      case GoalType.other:
        return 'Other';
    }
  }

  void _confirmDeleteIncome(IncomeEntry income) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete income?'),
        content: Text('Remove "${income.title}" from your income entries?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _incomes.removeWhere((item) => item.id == income.id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteExpense(ExpenseEntry expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Remove "${expense.title}" from your expenses?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _expenses.removeWhere((item) => item.id == expense.id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditIncomeDialog(IncomeEntry income) {
    final titleController = TextEditingController(text: income.title);
    final amountController = TextEditingController(text: income.amount.toStringAsFixed(0));
    IncomeFrequency frequency = income.frequency;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Income'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (₹)')),
              DropdownButtonFormField<IncomeFrequency>(
                value: frequency, isExpanded: true, decoration: const InputDecoration(labelText: 'Frequency'),
                items: IncomeFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.name.toUpperCase()))).toList(),
                onChanged: (value) { if (value != null) setDialogState(() => frequency = value); },
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (titleController.text.trim().isEmpty || amount == null || amount <= 0) return;
                setState(() {
                  final index = _incomes.indexWhere((item) => item.id == income.id);
                  if (index != -1) _incomes[index] = IncomeEntry(
                    id: income.id, title: titleController.text.trim(), amount: amount, frequency: frequency);
                });
                Navigator.pop(ctx);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditExpenseDialog(ExpenseEntry expense) {
    final titleController = TextEditingController(text: expense.title);
    final plannedController = TextEditingController(text: expense.plannedAmount.toStringAsFixed(0));
    final actualController = TextEditingController(text: expense.actualAmount.toStringAsFixed(0));
    ExpenseCategory category = expense.category;
    ExpenseClassification classification = expense.classification;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Expense'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Expense name')),
              TextField(controller: plannedController, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Planned amount (₹)')),
              TextField(controller: actualController, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Actual amount (₹)')),
              DropdownButtonFormField<ExpenseCategory>(
                value: category, isExpanded: true, decoration: const InputDecoration(labelText: 'Category'),
                items: ExpenseCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
                onChanged: (value) { if (value != null) setDialogState(() => category = value); },
              ),
              DropdownButtonFormField<ExpenseClassification>(
                value: classification, isExpanded: true, decoration: const InputDecoration(labelText: 'Classification'),
                items: ExpenseClassification.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
                onChanged: (value) { if (value != null) setDialogState(() => classification = value); },
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final planned = double.tryParse(plannedController.text);
                final actual = double.tryParse(actualController.text);
                if (titleController.text.trim().isEmpty || planned == null || actual == null || planned < 0 || actual < 0) return;
                setState(() {
                  expense.plannedAmount = planned;
                  expense.actualAmount = actual;
                  // Category and classification are final fields, so replace the entry.
                  final index = _expenses.indexWhere((item) => item.id == expense.id);
                  if (index != -1) _expenses[index] = ExpenseEntry(
                    id: expense.id, title: titleController.text.trim(), plannedAmount: planned,
                    actualAmount: actual, category: category, classification: classification);
                });
                Navigator.pop(ctx);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddIncomeDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    IncomeFrequency frequency = IncomeFrequency.monthly;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Income Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹)')),
              DropdownButton<IncomeFrequency>(
                value: frequency,
                isExpanded: true,
                items: IncomeFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.name.toUpperCase()))).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => frequency = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (titleController.text.isNotEmpty && amount > 0) {
                  setState(() {
                    _incomes.add(IncomeEntry(
                      id: DateTime.now().toIso8601String(),
                      title: titleController.text,
                      amount: amount,
                      frequency: frequency,
                    ));
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Add'),
            )
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final plannedController = TextEditingController();
    final actualController = TextEditingController();
    ExpenseCategory category = ExpenseCategory.grocery;
    ExpenseClassification classification = ExpenseClassification.essential;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Expense Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: plannedController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Planned Amount (₹)')),
                TextField(controller: actualController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Actual Amount (₹)')),
                DropdownButton<ExpenseCategory>(
                  value: category,
                  isExpanded: true,
                  items: ExpenseCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
                DropdownButton<ExpenseClassification>(
                  value: classification,
                  isExpanded: true,
                  items: ExpenseClassification.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => classification = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final planned = double.tryParse(plannedController.text) ?? 0;
                final actual = double.tryParse(actualController.text) ?? 0;
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _expenses.add(ExpenseEntry(
                      id: DateTime.now().toIso8601String(),
                      title: titleController.text,
                      plannedAmount: planned,
                      actualAmount: actual,
                      category: category,
                      classification: classification,
                    ));
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Add'),
            )
          ],
        ),
      ),
    );
  }
}