import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';

class UserManagementScreen extends StatefulWidget {
  final AdminApiService apiService;

  const UserManagementScreen({super.key, required this.apiService});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _loading = true;
  List<dynamic> _users = [];
  List<dynamic> _halls = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        widget.apiService.getAllUsers(),
        widget.apiService.getAllHalls(),
      ]);
      if (!mounted) return;
      setState(() {
        _users = results[0];
        _halls = results[1];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load users';
        _loading = false;
      });
    }
  }

  void _showAddUserDialog() {
    final emailCtl = TextEditingController();
    String selectedRole = 'STUDENT';
    int? selectedHallId = _halls.isNotEmpty ? (_halls[0]['id'] as num).toInt() : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailCtl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'STUDENT', child: Text('Student')),
                    DropdownMenuItem(
                        value: 'MEAL_MANAGER', child: Text('Meal Manager')),
                    DropdownMenuItem(
                        value: 'DINING_MANAGER',
                        child: Text('Dining Manager')),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selectedRole = v ?? 'STUDENT'),
                ),
                const SizedBox(height: 16),
                if (_halls.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: selectedHallId,
                    decoration: const InputDecoration(
                      labelText: 'Hall',
                      prefixIcon: Icon(Icons.apartment),
                    ),
                    items: _halls
                        .map((h) => DropdownMenuItem<int>(
                              value: (h['id'] as num).toInt(),
                              child: Text(h['name'] as String),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedHallId = v),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (emailCtl.text.trim().isEmpty || selectedHallId == null) {
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await widget.apiService.addUser(
                    email: emailCtl.text.trim(),
                    role: selectedRole,
                    hallId: selectedHallId!,
                  );
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User added successfully')),
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
      ),
    );
  }

  String _extractError(dynamic e) {
    if (e.toString().contains('DuplicateEmail') ||
        e.toString().contains('already registered')) {
      return 'Email already registered';
    }
    return e.toString().length > 80 ? e.toString().substring(0, 80) : e.toString();
  }

  Future<void> _confirmDelete(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete user $email? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
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
        await widget.apiService.deleteUser(email);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${_extractError(e)}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Color _roleColor(String? role) {
    switch (role) {
      case 'MEAL_MANAGER':
        return Colors.orange;
      case 'DINING_MANAGER':
        return Colors.green;
      case 'STUDENT':
        return Colors.blue;
      default:
        return Colors.grey;
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
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _users.isEmpty
            ? const Center(child: Text('No users yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _users.length,
                itemBuilder: (_, i) {
                  final u = _users[i] as Map<String, dynamic>;
                  final role = u['role'] as String? ?? 'STUDENT';
                  final verified = u['isVerified'] == true;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _roleColor(role).withValues(alpha: 0.15),
                        child: Icon(
                          role == 'STUDENT'
                              ? Icons.school
                              : role == 'MEAL_MANAGER'
                                  ? Icons.restaurant
                                  : Icons.food_bank,
                          color: _roleColor(role),
                        ),
                      ),
                      title: Text(u['name'] ?? 'Unnamed'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u['email'] ?? ''),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _roleColor(role).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  role.replaceAll('_', ' '),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _roleColor(role),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                verified
                                    ? Icons.verified
                                    : Icons.pending,
                                size: 16,
                                color: verified
                                    ? Colors.teal
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                verified ? 'Verified' : 'Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: verified
                                      ? Colors.teal
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: theme.colorScheme.error),
                        onPressed: () =>
                            _confirmDelete(u['email'] as String? ?? ''),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
      ),
    );
  }
}
