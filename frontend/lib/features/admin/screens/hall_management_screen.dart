import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';

class HallManagementScreen extends StatefulWidget {
  final AdminApiService apiService;

  const HallManagementScreen({super.key, required this.apiService});

  @override
  State<HallManagementScreen> createState() => _HallManagementScreenState();
}

class _HallManagementScreenState extends State<HallManagementScreen> {
  bool _loading = true;
  List<dynamic> _halls = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHalls();
  }

  Future<void> _loadHalls() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final halls = await widget.apiService.getAllHalls();
      if (!mounted) return;
      setState(() {
        _halls = halls;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load halls';
        _loading = false;
      });
    }
  }

  void _showAddHallDialog() {
    final nameCtl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Hall'),
        content: TextField(
          controller: nameCtl,
          decoration: const InputDecoration(
            labelText: 'Hall Name',
            prefixIcon: Icon(Icons.apartment),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              try {
                await widget.apiService.addHall(nameCtl.text.trim());
                _loadHalls();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hall added successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: ${_extractError(e)}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _extractError(dynamic e) {
    final s = e.toString();
    if (s.contains('already exists')) return 'Hall name already exists';
    return s.length > 80 ? s.substring(0, 80) : s;
  }

  Future<void> _confirmDelete(int hallId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Hall'),
        content: Text('Delete "$name"? Only empty halls can be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await widget.apiService.deleteHall(hallId);
        _loadHalls();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hall deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: ${_extractError(e)}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _loadHalls,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadHalls,
        child: _halls.isEmpty
            ? const Center(child: Text('No halls configured'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _halls.length,
                itemBuilder: (_, i) {
                  final h = _halls[i] as Map<String, dynamic>;
                  final id = (h['id'] as num).toInt();
                  final name = h['name'] as String? ?? 'Unknown';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                        child: Icon(Icons.apartment,
                            color: theme.colorScheme.onPrimaryContainer),
                      ),
                      title: Text(name),
                      subtitle: Text('ID: $id'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: theme.colorScheme.error),
                        onPressed: () => _confirmDelete(id, name),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHallDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Hall'),
      ),
    );
  }
}
