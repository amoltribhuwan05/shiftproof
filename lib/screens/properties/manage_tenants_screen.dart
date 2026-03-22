import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/data/models/tenant_model.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/cards/tenant_card.dart';

class ManageTenantsScreen extends ConsumerWidget {
  const ManageTenantsScreen({super.key, this.propertyId = ''});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tenantsAsync = ref.watch(tenantsProvider(propertyId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          'Manage Tenants',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: tenantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              const Text('Failed to load tenants'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(tenantsProvider(propertyId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allTenants) {
          final paidTenants =
              allTenants.where((t) => t.isPaid).toList();
          final overdueTenants =
              allTenants.where((t) => t.status == 'overdue').toList();

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: colorScheme.primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: 'All (${allTenants.length})'),
                    Tab(text: 'Paid (${paidTenants.length})'),
                    Tab(text: 'Overdue (${overdueTenants.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTenantList(context, allTenants),
                      _buildTenantList(context, paidTenants),
                      _buildTenantList(context, overdueTenants),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'manage_tenants_fab',
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => _InviteTenantSheet(
              propertyId: propertyId,
              onInvited: () => ref.invalidate(tenantsProvider(propertyId)),
            ),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildTenantList(BuildContext context, List<Tenant> tenants) {
    if (tenants.isEmpty) {
      return const Center(child: Text('No tenants found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tenants.length,
      itemBuilder: (context, index) => TenantCard(tenant: tenants[index]),
    );
  }
}

// ─── Invite Tenant Bottom Sheet ───────────────────────────────────────────────

class _InviteTenantSheet extends ConsumerStatefulWidget {
  const _InviteTenantSheet({
    required this.propertyId,
    required this.onInvited,
  });

  final String propertyId;
  final VoidCallback onInvited;

  @override
  ConsumerState<_InviteTenantSheet> createState() => _InviteTenantSheetState();
}

class _InviteTenantSheetState extends ConsumerState<_InviteTenantSheet> {
  final _rentController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedRoomId;
  DateTime? _leaseStart;
  DateTime? _leaseEnd;
  bool _isLoading = false;
  String? _generatedCode;

  @override
  void dispose() {
    _rentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_leaseStart ?? now) : (_leaseEnd ?? now),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _leaseStart = picked;
      } else {
        _leaseEnd = picked;
      }
    });
  }

  Future<void> _handleInvite() async {
    final roomId = _selectedRoomId;
    final leaseStart = _leaseStart;
    final leaseEnd = _leaseEnd;
    final rentText = _rentController.text.trim();

    if (roomId == null || roomId.isEmpty) {
      _showSnack('Please select a room.');
      return;
    }
    if (leaseStart == null) {
      _showSnack('Please select a lease start date.');
      return;
    }
    if (leaseEnd == null) {
      _showSnack('Please select a lease end date.');
      return;
    }
    if (rentText.isEmpty || int.tryParse(rentText) == null) {
      _showSnack('Please enter a valid rent amount.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final request = InviteTenantRequest(
        roomId: roomId,
        leaseStart: leaseStart.toIso8601String().split('T').first,
        leaseEnd: leaseEnd.toIso8601String().split('T').first,
        rentAmount: int.parse(rentText),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );
      final response = await ref
          .read(tenantServiceProvider)
          .inviteTenant(widget.propertyId, request);
      setState(() => _generatedCode = response.inviteCode);
      widget.onInvited();
    } on Exception catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final roomsAsync = ref.watch(roomsProvider(widget.propertyId));

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invite Tenant',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // If code was generated, show it instead of form
          if (_generatedCode != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: colorScheme.primary, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Invite Code Generated',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generatedCode!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share this code with your tenant so they can join.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else ...[
            // Room dropdown
            Text('Room',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            roomsAsync.when(
              loading: () => const SizedBox(
                height: 48,
                child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => const Text('Failed to load rooms'),
              data: (rooms) => DropdownButtonFormField<String>(
                initialValue: _selectedRoomId,
                hint: const Text('Select a room'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                items: rooms.map((r) {
                  return DropdownMenuItem<String>(
                    value: r.id,
                    child: Text(
                      'Room ${r.roomNumber ?? ''}'
                      ' (${r.type ?? ''},'
                      ' ₹${r.rentAmount ?? 0}/mo)',
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedRoomId = v),
              ),
            ),
            const SizedBox(height: 14),

            // Lease start / end
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Lease Start',
                    value: _leaseStart,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Lease End',
                    value: _leaseEnd,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Rent amount
            Text('Monthly Rent (₹)',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _rentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 8000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Optional email
            Text('Tenant Email (optional)',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'tenant@example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _handleInvite,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isLoading ? 'Generating...' : 'Generate Invite Code',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Helper date field ─────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final text = value == null
        ? 'Select date'
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: value == null
                          ? colorScheme.onSurface.withValues(alpha: 0.4)
                          : colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
