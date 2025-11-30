import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../main.dart'; // For AppGradients and AppColors
import 'analytics_detail_screen.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayTotalProvider);
    final weekAsync = ref.watch(weekTotalProvider);
    final monthAsync = ref.watch(monthTotalProvider);

    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Analytics Overview'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Spending Summary",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.violetPrimary,
                ),
              ),
              const SizedBox(height: 20),

              _buildAnalyticsCard(
                context,
                'Today\'s Spend',
                todayAsync,
                AppGradients.cardBackground,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AnalyticsDetailScreen(period: 'daily'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildAnalyticsCard(
                context,
                'This Week\'s Spend',
                weekAsync,
                AppGradients.cardBackground,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AnalyticsDetailScreen(period: 'weekly'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildAnalyticsCard(
                context,
                'This Month\'s Spend',
                monthAsync,
                AppGradients.cardBackground,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AnalyticsDetailScreen(period: 'monthly'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    AsyncValue<double> asyncValue,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return asyncValue.when(
      data: (value) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.violetPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '₹${value.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Error: $err',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
