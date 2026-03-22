import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/core/utils/currency_formatter.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';

class PayBillScreen extends ConsumerStatefulWidget {
  /// Pass a [payment] object for real data, or leave null to show a placeholder
  /// bill (used when navigated via named route without arguments).
  const PayBillScreen({super.key, this.payment});
  final Payment? payment;

  @override
  ConsumerState<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends ConsumerState<PayBillScreen> {
  String _selectedPaymentMethod = 'upi';
  bool _isLoading = false;
  bool _paid = false;

  /// Returns the payment passed as constructor arg or extracted from route args.
  Payment? get _payment {
    if (widget.payment != null) return widget.payment;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Payment) return args;
    return null;
  }

  Future<void> _handlePayNow() async {
    final payment = _payment;
    if (payment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No payment data available.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final transactionRef =
          '${_selectedPaymentMethod.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

      await ref.read(paymentServiceProvider).payPayment(
            payment.id ?? '',
            paymentMethod: _selectedPaymentMethod,
            transactionRef: transactionRef,
          );

      if (mounted) {
        setState(() => _paid = true);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final payment = _payment;

    // Values — real if available, placeholder otherwise
    final amount = payment?.amount ?? 17000;
    final dueDate = payment?.date ?? '';
    final status = payment?.status ?? 'pending';
    final isOverdue = status == 'overdue';
    final title = payment?.title ?? 'Monthly Bill';

    if (_paid) {
      return _SuccessView(amount: amount, onDone: () => Navigator.pop(context));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                if (isOverdue || dueDate.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? const Color(0xFFF44336).withValues(alpha: 0.1)
                          : colorScheme.primary.withValues(alpha: 0.08),
                      border: Border.all(
                        color: isOverdue
                            ? const Color(0xFFF44336).withValues(alpha: 0.3)
                            : colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isOverdue
                                      ? Icons.warning_amber_rounded
                                      : Icons.calendar_today,
                                  color: isOverdue
                                      ? const Color(0xFFF44336)
                                      : colorScheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dueDate.isNotEmpty
                                      ? 'Due: $dueDate'
                                      : 'Payment Due',
                                  style: TextStyle(
                                    color: isOverdue
                                        ? const Color(0xFFF44336)
                                        : colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            if (payment?.description?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 4),
                              Text(
                                payment!.description ?? '',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? const Color(0xFFF44336)
                                    .withValues(alpha: 0.15)
                                : colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: isOverdue
                                  ? const Color(0xFFF44336)
                                  : colorScheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // Payment Summary
                Text(
                  'Payment Summary',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      if (payment != null) ...[
                        _buildSummaryRow(
                          context,
                          (payment.type?.isNotEmpty ?? false)
                              ? _capitalize(payment.type!)
                              : 'Rent',
                          CurrencyFormatter.format(payment.amount ?? 0),
                          _iconForType(payment.type),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        _buildSummaryRow(
                          context,
                          'Rent',
                          CurrencyFormatter.format(15000),
                          Icons.apartment,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          context,
                          'Electricity',
                          CurrencyFormatter.format(1200),
                          Icons.bolt,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          context,
                          'Water',
                          CurrencyFormatter.format(300),
                          Icons.water_drop_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          context,
                          'Maintenance',
                          CurrencyFormatter.format(500),
                          Icons.build_outlined,
                        ),
                        const SizedBox(height: 16),
                      ],
                      Divider(
                          color: theme.colorScheme.outlineVariant, height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Payable',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(amount),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Payment Method
                Text(
                  'Payment Method',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                RadioGroup<String>(
                  groupValue: _selectedPaymentMethod,
                  onChanged: (String? v) {
                    if (v != null) setState(() => _selectedPaymentMethod = v);
                  },
                  child: Column(
                    children: [
                      _buildPaymentMethodOption(
                        context,
                        value: 'upi',
                        title: 'UPI (Google Pay, PhonePe)',
                        icon: Icons.qr_code_2,
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodOption(
                        context,
                        value: 'card',
                        title: 'Credit / Debit Card',
                        icon: Icons.credit_card,
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodOption(
                        context,
                        value: 'netbanking',
                        title: 'Net Banking',
                        icon: Icons.account_balance,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Fixed Bottom Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Grand Total',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(amount),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor:
                                colorScheme.primary.withValues(alpha: 0.4),
                          ),
                          onPressed: _isLoading ? null : _handlePayNow,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Pay Now',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String amount,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    BuildContext context, {
    required String value,
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Radio<String>(
                value: value,
                activeColor: colorScheme.primary,
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return colorScheme.primary;
                  }
                  return theme.colorScheme.onSurface.withValues(alpha: 0.5);
                }),
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              icon,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'rent':
        return Icons.apartment;
      case 'electricity':
        return Icons.bolt;
      case 'maintenance':
        return Icons.build_outlined;
      case 'deposit':
        return Icons.lock_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Payment success view ─────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.amount, required this.onDone});
  final int amount;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF10B981),
                  size: 56,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                CurrencyFormatter.format(amount),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your payment has been processed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onDone,
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
