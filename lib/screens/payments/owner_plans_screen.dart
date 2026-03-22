import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/buttons/primary_button.dart';

// Hardcoded fallback plans used when the API is unavailable.
const _fallbackPlans = [
  _PlanData(
    id: 'free',
    name: 'Small PG',
    price: 0,
    features: ['Up to 5 tenants', 'Basic reporting'],
    isPopular: false,
  ),
  _PlanData(
    id: 'medium',
    name: 'Medium PG',
    price: 199,
    features: [
      'Up to 20 tenants',
      'Automated rent reminders',
      'Digital rent receipts',
    ],
    isPopular: true,
  ),
  _PlanData(
    id: 'large',
    name: 'Large PG',
    price: 499,
    features: ['Up to 50 tenants', 'Multi-property support'],
    isPopular: false,
  ),
  _PlanData(
    id: 'enterprise',
    name: 'Enterprise',
    price: 999,
    features: ['100+ tenants', 'Dedicated account manager'],
    isPopular: false,
  ),
];

class OwnerPlansScreen extends ConsumerWidget {
  const OwnerPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plansAsync = ref.watch(plansProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          'Set up your PG or Property',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            icon: Icon(Icons.help_outline, color: theme.colorScheme.onSurface),
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
                Text(
                  'Choose based on how many tenants you manage',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a plan that fits your current needs. You can scale as you grow.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Plan cards — API data or fallback
                plansAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => _buildPlanList(
                    context,
                    _fallbackPlans,
                    currentPlanId: null,
                  ),
                  data: (apiPlans) {
                    if (apiPlans.isEmpty) {
                      return _buildPlanList(
                        context,
                        _fallbackPlans,
                        currentPlanId: null,
                      );
                    }
                    final planData = apiPlans.map(_PlanData.fromPlan).toList();
                    final currentPlanId = apiPlans
                        .firstWhere(
                          (p) => p.isCurrent ?? false,
                          orElse: () => const Plan(),
                        )
                        .id;
                    return _buildPlanList(
                      context,
                      planData,
                      currentPlanId: currentPlanId,
                    );
                  },
                ),

                const SizedBox(height: 32),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'You can change plans anytime',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Fixed Bottom Footer CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: PrimaryButton(
                    text: 'Continue as Owner',
                    icon: Icons.chevron_right,
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanList(
    BuildContext context,
    List<_PlanData> plans, {
    required String? currentPlanId,
  }) {
    return Column(
      children: [
        for (int i = 0; i < plans.length; i++) ...[
          _PlanCard(
            plan: plans[i],
            isCurrentPlan: plans[i].id == currentPlanId,
          ),
          if (i < plans.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isCurrentPlan});
  final _PlanData plan;
  final bool isCurrentPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isHighlighted = plan.isPopular || isCurrentPlan;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surface.withValues(alpha: 0.5)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted
                  ? colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: isHighlighted ? 2 : 1,
            ),
            boxShadow: isHighlighted && !isDark
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name.toUpperCase(),
                style: TextStyle(
                  color: isHighlighted
                      ? colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    plan.price == 0 ? 'Free' : '₹${plan.price}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (plan.price > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '/month',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              ...plan.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: colorScheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isHighlighted)
          Positioned(
            top: 0,
            right: 24,
            child: FractionalTranslation(
              translation: const Offset(0, -0.5),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isCurrentPlan ? 'CURRENT' : 'RECOMMENDED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Lightweight DTO used internally to unify API [Plan] and fallback data.
class _PlanData {
  const _PlanData({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    required this.isPopular,
  });

  factory _PlanData.fromPlan(Plan p) {
    return _PlanData(
      id: p.id ?? '',
      name: p.name ?? '',
      price: p.price ?? 0,
      features: p.features ?? [],
      isPopular: p.isPopular ?? false,
    );
  }

  final String id;
  final String name;
  final int price;
  final List<String> features;
  final bool isPopular;
}
