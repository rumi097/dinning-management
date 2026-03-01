import 'package:flutter/material.dart';
import '../models/meal_config.dart';
import '../services/meal_manager_service.dart';

/// Page for the Meal Manager to set tomorrow's lunch & dinner menu.
///
/// API: POST /meals/config  |  PUT /meals/config/{id}
class SetMenuPage extends StatefulWidget {
  const SetMenuPage({super.key});

  @override
  State<SetMenuPage> createState() => _SetMenuPageState();
}

class _SetMenuPageState extends State<SetMenuPage>
    with SingleTickerProviderStateMixin {
  final _service = MealManagerService();
  late TabController _tabController;

  bool _loading = true;
  bool _saving = false;

  // Lunch menu items
  final List<String> _lunchItems = [];
  final _lunchItemController = TextEditingController();

  // Dinner menu items
  final List<String> _dinnerItems = [];
  final _dinnerItemController = TextEditingController();

  List<MealConfig> _configs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMenu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lunchItemController.dispose();
    _dinnerItemController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu() async {
    setState(() => _loading = true);
    try {
      final configs = await _service.getTomorrowConfig();
      _configs = configs;

      for (final c in configs) {
        final items = c.menu
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (c.mealType == MealType.lunch) {
          _lunchItems
            ..clear()
            ..addAll(items);
        } else {
          _dinnerItems
            ..clear()
            ..addAll(items);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _addItem(List<String> items, TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      items.add(text);
      controller.clear();
    });
  }

  void _removeItem(List<String> items, int index) {
    setState(() => items.removeAt(index));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateStr =
          '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      final lunchConfig = _configs.firstWhere(
        (c) => c.mealType == MealType.lunch,
        orElse: () => MealConfig(
            date: dateStr,
            mealType: MealType.lunch,
            price: 55.0,
            menu: ''),
      );
      final dinnerConfig = _configs.firstWhere(
        (c) => c.mealType == MealType.dinner,
        orElse: () => MealConfig(
            date: dateStr,
            mealType: MealType.dinner,
            price: 65.0,
            menu: ''),
      );

      final updatedLunch =
          lunchConfig.copyWith(menu: _lunchItems.join(', '));
      final updatedDinner =
          dinnerConfig.copyWith(menu: _dinnerItems.join(', '));

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

      if (mounted) _showSnackBar('Menu saved successfully!', isSuccess: true);
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
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
        title: const Text('Set Menu'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.wb_sunny_outlined),
              text: 'Lunch',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: const Icon(Icons.nightlight_outlined),
              text: 'Dinner',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMenuTab(
                        theme: theme,
                        items: _lunchItems,
                        controller: _lunchItemController,
                        color: Colors.blue,
                        emptyMessage: 'No lunch items yet. Add some below!',
                      ),
                      _buildMenuTab(
                        theme: theme,
                        items: _dinnerItems,
                        controller: _dinnerItemController,
                        color: Colors.orange,
                        emptyMessage: 'No dinner items yet. Add some below!',
                      ),
                    ],
                  ),
                ),

                // ── Save button (always visible at bottom) ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                          color: theme.colorScheme.outlineVariant.withAlpha(80)),
                    ),
                  ),
                  child: SafeArea(
                    child: SizedBox(
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
                        label:
                            Text(_saving ? 'Saving...' : 'Save Menu'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMenuTab({
    required ThemeData theme,
    required List<String> items,
    required TextEditingController controller,
    required Color color,
    required String emptyMessage,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Add item form ──
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Add menu item…',
                    prefixIcon: const Icon(Icons.restaurant_menu),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addItem(items, controller),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () => _addItem(items, controller),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  minimumSize: const Size(52, 52),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Item list ──
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu,
                            size: 48,
                            color:
                                theme.colorScheme.onSurfaceVariant.withAlpha(80)),
                        const SizedBox(height: 12),
                        Text(
                          emptyMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    itemCount: items.length,
                    onReorder: (oldIdx, newIdx) {
                      setState(() {
                        if (newIdx > oldIdx) newIdx--;
                        final item = items.removeAt(oldIdx);
                        items.insert(newIdx, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      return Card(
                        key: ValueKey('${items[index]}_$index'),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: color.withAlpha(50)),
                        ),
                        color: color.withAlpha(12),
                        child: ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                          title: Text(items[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: theme.colorScheme.error,
                            onPressed: () => _removeItem(items, index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
