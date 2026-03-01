import 'package:flutter/material.dart';
import '../models/meal_config.dart';
import '../services/meal_manager_service.dart';

/// Page for the Meal Manager to set/update lunch & dinner prices
/// and purchase deadlines for tomorrow.
///
/// API: POST /meals/config  |  PUT /meals/config/{id}
class SetPricePage extends StatefulWidget {
  const SetPricePage({super.key});

  @override
  State<SetPricePage> createState() => _SetPricePageState();
}

class _SetPricePageState extends State<SetPricePage> {
  final _service = MealManagerService();

  final _lunchPriceController = TextEditingController();
  final _dinnerPriceController = TextEditingController();
  final _lunchDeadlineController = TextEditingController();
  final _dinnerDeadlineController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  List<MealConfig> _configs = [];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _lunchPriceController.dispose();
    _dinnerPriceController.dispose();
    _lunchDeadlineController.dispose();
    _dinnerDeadlineController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _loading = true);
    try {
      final configs = await _service.getTomorrowConfig();
      _configs = configs;

      for (final c in configs) {
        if (c.mealType == MealType.lunch) {
          _lunchPriceController.text = c.price.toStringAsFixed(0);
          _lunchDeadlineController.text = c.purchaseDeadline ?? '';
        } else {
          _dinnerPriceController.text = c.price.toStringAsFixed(0);
          _dinnerDeadlineController.text = c.purchaseDeadline ?? '';
        }
      }
    } catch (_) {
      // keep defaults
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final lunchPrice = double.tryParse(_lunchPriceController.text.trim());
    final dinnerPrice = double.tryParse(_dinnerPriceController.text.trim());

    if (lunchPrice == null || dinnerPrice == null) {
      _showSnackBar('Please enter valid prices');
      return;
    }

    setState(() => _saving = true);
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateStr =
          '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      // Find existing config IDs or create new
      final lunchConfig = _configs.firstWhere(
        (c) => c.mealType == MealType.lunch,
        orElse: () => MealConfig(
            date: dateStr,
            mealType: MealType.lunch,
            price: 0,
            menu: ''),
      );
      final dinnerConfig = _configs.firstWhere(
        (c) => c.mealType == MealType.dinner,
        orElse: () => MealConfig(
            date: dateStr,
            mealType: MealType.dinner,
            price: 0,
            menu: ''),
      );

      final updatedLunch = lunchConfig.copyWith(
        price: lunchPrice,
        purchaseDeadline: _lunchDeadlineController.text.trim(),
      );
      final updatedDinner = dinnerConfig.copyWith(
        price: dinnerPrice,
        purchaseDeadline: _dinnerDeadlineController.text.trim(),
      );

      if (lunchConfig.id != null) {
        await _service.updateMealConfig(lunchConfig.id!, updatedLunch);
      } else {
        await _service.createMealConfig(updatedLunch);
      }

      if (dinnerConfig.id != null) {
        await _service.updateMealConfig(dinnerConfig.id!, updatedDinner);
      } else {
        await _service.createMealConfig(updatedDinner);
      }

      if (mounted) _showSnackBar('Prices saved successfully!', isSuccess: true);
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final initial = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      controller.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
      appBar: AppBar(title: const Text('Set Meal Prices')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header card ──
                  Card(
                    elevation: 0,
                    color: Colors.purple.withAlpha(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.purple.withAlpha(50)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.withAlpha(30),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.attach_money,
                                color: Colors.purple, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tomorrow's Pricing",
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Set token prices & purchase deadlines',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Lunch Section ──
                  _mealPriceSection(
                    theme: theme,
                    label: 'Lunch',
                    color: Colors.blue,
                    icon: Icons.wb_sunny_outlined,
                    priceController: _lunchPriceController,
                    deadlineController: _lunchDeadlineController,
                  ),

                  const SizedBox(height: 24),

                  Divider(color: theme.colorScheme.outlineVariant.withAlpha(80)),

                  const SizedBox(height: 24),

                  // ── Dinner Section ──
                  _mealPriceSection(
                    theme: theme,
                    label: 'Dinner',
                    color: Colors.orange,
                    icon: Icons.nightlight_outlined,
                    priceController: _dinnerPriceController,
                    deadlineController: _dinnerDeadlineController,
                  ),

                  const SizedBox(height: 36),

                  // ── Save button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save),
                      label: Text(_saving ? 'Saving...' : 'Save Prices'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _mealPriceSection({
    required ThemeData theme,
    required String label,
    required Color color,
    required IconData icon,
    required TextEditingController priceController,
    required TextEditingController deadlineController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              '$label Settings',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Price
        Text('Price (৳)',
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: priceController,
          decoration: InputDecoration(
            hintText: 'e.g. 55',
            prefixIcon: const Icon(Icons.attach_money),
            suffixText: '৳',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),

        const SizedBox(height: 14),

        // Deadline
        Text('Purchase Deadline',
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: deadlineController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Tap to pick time',
            prefixIcon: const Icon(Icons.access_time),
            suffixIcon: IconButton(
              icon: const Icon(Icons.schedule),
              onPressed: () => _pickTime(deadlineController),
            ),
          ),
          onTap: () => _pickTime(deadlineController),
        ),
      ],
    );
  }
}
