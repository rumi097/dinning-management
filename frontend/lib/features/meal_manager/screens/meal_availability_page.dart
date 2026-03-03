import 'package:flutter/material.dart';
import '../models/meal_availability.dart';
import '../services/meal_manager_service.dart';

/// Page where the Meal Manager picks a date and toggles:
///   - Whether meals are available at all on that date
///   - Whether lunch is available
///   - Whether dinner is available
///
/// API: GET /meals/availability/{date}  |  PUT /meals/availability/{date}
class MealAvailabilityPage extends StatefulWidget {
  const MealAvailabilityPage({super.key});

  @override
  State<MealAvailabilityPage> createState() => _MealAvailabilityPageState();
}

class _MealAvailabilityPageState extends State<MealAvailabilityPage> {
  final _service = MealManagerService();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  MealAvailability? _availability;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  String _dateToString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dateToDisplay(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
      'Saturday', 'Sunday',
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _loadAvailability() async {
    setState(() => _loading = true);
    try {
      final data =
          await _service.getMealAvailability(_dateToString(_selectedDate));
      if (mounted) setState(() => _availability = data);
    } catch (_) {
      if (mounted) {
        setState(() {
          _availability = MealAvailability(
            date: _dateToString(_selectedDate),
          );
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadAvailability();
    }
  }

  Future<void> _save() async {
    if (_availability == null) return;
    setState(() => _saving = true);
    try {
      final success =
          await _service.updateMealAvailability(_availability!);
      if (mounted) {
        _showSnackBar(
          success ? 'Availability updated!' : 'Failed to update.',
          isSuccess: success,
        );
      }
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
      appBar: AppBar(title: const Text('Meal Availability')),
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
                    color: theme.colorScheme.primaryContainer.withAlpha(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: theme.colorScheme.primary.withAlpha(50)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.event_available,
                                color: theme.colorScheme.primary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Meal Availability',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Toggle meal availability for a date',
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

                  const SizedBox(height: 24),

                  // ── Date picker ──
                  Text(
                    'Select Date',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dateToDisplay(_selectedDate),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_drop_down,
                              color: theme.colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Master toggle ──
                  _buildToggleCard(
                    theme: theme,
                    title: 'Meal Available',
                    subtitle: _availability!.isMealAvailable
                        ? 'Meals are ON for this date'
                        : 'All meals are OFF for this date',
                    icon: Icons.restaurant,
                    color: _availability!.isMealAvailable
                        ? Colors.green
                        : Colors.red,
                    value: _availability!.isMealAvailable,
                    onChanged: (v) {
                      setState(() {
                        _availability = _availability!.copyWith(
                          isMealAvailable: v,
                          // When master is off, turn both off
                          isLunchAvailable:
                              v ? _availability!.isLunchAvailable : false,
                          isDinnerAvailable:
                              v ? _availability!.isDinnerAvailable : false,
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Lunch toggle ──
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _availability!.isMealAvailable ? 1.0 : 0.4,
                    child: IgnorePointer(
                      ignoring: !_availability!.isMealAvailable,
                      child: _buildToggleCard(
                        theme: theme,
                        title: 'Lunch Available',
                        subtitle: _availability!.isLunchAvailable
                            ? 'Lunch is ON'
                            : 'Lunch is OFF',
                        icon: Icons.wb_sunny_outlined,
                        color: _availability!.isLunchAvailable
                            ? Colors.blue
                            : Colors.grey,
                        value: _availability!.isLunchAvailable,
                        onChanged: (v) {
                          setState(() {
                            _availability = _availability!
                                .copyWith(isLunchAvailable: v);
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Dinner toggle ──
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _availability!.isMealAvailable ? 1.0 : 0.4,
                    child: IgnorePointer(
                      ignoring: !_availability!.isMealAvailable,
                      child: _buildToggleCard(
                        theme: theme,
                        title: 'Dinner Available',
                        subtitle: _availability!.isDinnerAvailable
                            ? 'Dinner is ON'
                            : 'Dinner is OFF',
                        icon: Icons.nightlight_outlined,
                        color: _availability!.isDinnerAvailable
                            ? Colors.orange
                            : Colors.grey,
                        value: _availability!.isDinnerAvailable,
                        onChanged: (v) {
                          setState(() {
                            _availability = _availability!
                                .copyWith(isDinnerAvailable: v);
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

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
                      label: Text(
                          _saving ? 'Saving...' : 'Save Availability'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildToggleCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withAlpha(60)),
      ),
      color: color.withAlpha(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
