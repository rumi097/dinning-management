import 'package:flutter/material.dart';
import '../services/meal_manager_service.dart';

/// Page for the Meal Manager to top-up a student's wallet (add credit).
///
/// API: POST /wallet/topup  { studentId, amount }
class AddCreditPage extends StatefulWidget {
  const AddCreditPage({super.key});

  @override
  State<AddCreditPage> createState() => _AddCreditPageState();
}

class _AddCreditPageState extends State<AddCreditPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _service = MealManagerService();

  bool _submitting = false;
  double? _currentBalance;
  bool _loadingBalance = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ── Fetch student balance for preview ──
  Future<void> _lookupBalance() async {
    final sid = _studentIdController.text.trim();
    if (sid.isEmpty) return;

    setState(() => _loadingBalance = true);
    try {
      final balance = await _service.getStudentBalance(sid);
      if (mounted) setState(() => _currentBalance = balance);
    } catch (_) {
      if (mounted) setState(() => _currentBalance = null);
    } finally {
      if (mounted) setState(() => _loadingBalance = false);
    }
  }

  // ── Submit top‑up ──
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final success = await _service.topUpWallet(
        studentId: _studentIdController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
      );

      if (!mounted) return;

      if (success) {
        _showSnackBar('Credit added successfully!', isSuccess: true);
        _studentIdController.clear();
        _amountController.clear();
        setState(() => _currentBalance = null);
      } else {
        _showSnackBar('Failed to add credit. Try again.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student Credit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card ──
              Card(
                elevation: 0,
                color: Colors.green.withAlpha(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.green.withAlpha(50)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(30),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.credit_card,
                            color: Colors.green, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet Top‑Up',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Add coins to a student wallet',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Student ID ──
              Text('Student ID',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _studentIdController,
                decoration: InputDecoration(
                  hintText: 'e.g. S2021001',
                  prefixIcon: const Icon(Icons.person_outline),
                  suffixIcon: IconButton(
                    onPressed: _lookupBalance,
                    icon: _loadingBalance
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    tooltip: 'Look up balance',
                  ),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a student ID';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _lookupBalance(),
              ),

              // ── Balance preview ──
              if (_currentBalance != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(60),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Current Balance: ৳${_currentBalance!.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Amount ──
              Text('Amount (৳)',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(v.trim());
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // ── Quick amount chips ──
              Wrap(
                spacing: 8,
                children: [100, 200, 500, 1000].map((amt) {
                  return ActionChip(
                    label: Text('৳$amt'),
                    onPressed: () =>
                        _amountController.text = amt.toString(),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // ── Submit button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check),
                  label: Text(_submitting ? 'Processing...' : 'Add Credit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
