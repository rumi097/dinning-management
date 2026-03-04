import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';

class AdminDashboard extends StatefulWidget {
  final AdminApiService apiService;

  const AdminDashboard({super.key, required this.apiService});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await widget.apiService.getStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load statistics';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(_error!, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final s = _stats!;
    final halls = (s['halls'] as List?) ?? [];

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('System Overview',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Summary cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                icon: Icons.people,
                label: 'Total Users',
                value: '${s['totalUsers'] ?? 0}',
                color: theme.colorScheme.primary,
              ),
              _StatCard(
                icon: Icons.school,
                label: 'Students',
                value: '${s['totalStudents'] ?? 0}',
                color: Colors.blue,
              ),
              _StatCard(
                icon: Icons.restaurant,
                label: 'Meal Managers',
                value: '${s['totalMealManagers'] ?? 0}',
                color: Colors.orange,
              ),
              _StatCard(
                icon: Icons.food_bank,
                label: 'Dining Managers',
                value: '${s['totalDiningManagers'] ?? 0}',
                color: Colors.green,
              ),
              _StatCard(
                icon: Icons.apartment,
                label: 'Halls',
                value: '${s['totalHalls'] ?? 0}',
                color: Colors.purple,
              ),
              _StatCard(
                icon: Icons.verified_user,
                label: 'Verified',
                value: '${s['verifiedUsers'] ?? 0}',
                color: Colors.teal,
              ),
              _StatCard(
                icon: Icons.person_off,
                label: 'Unverified',
                value: '${s['unverifiedUsers'] ?? 0}',
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text('Hall Breakdown',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (halls.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No halls configured')),
              ),
            )
          else
            ...halls.map((h) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primaryContainer,
                      child: Icon(Icons.apartment,
                          color: theme.colorScheme.onPrimaryContainer),
                    ),
                    title: Text(h['name'] ?? 'Unknown'),
                    subtitle: Text(
                      'Students: ${h['studentCount'] ?? 0}  •  '
                      'Meal Mgr: ${h['mealManagerCount'] ?? 0}  •  '
                      'Dining Mgr: ${h['diningManagerCount'] ?? 0}',
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
