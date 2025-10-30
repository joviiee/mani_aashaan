import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/expense_viewmodel.dart';
import 'analytics_detail_screen.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayTotalProvider);
    final weekAsync = ref.watch(weekTotalProvider);
    final monthAsync = ref.watch(monthTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAnalyticsCard(
              context,
              'Today\'s Spend',
              todayAsync,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AnalyticsDetailScreen(period: 'daily'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildAnalyticsCard(
              context,
              'This Week\'s Spend',
              weekAsync,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AnalyticsDetailScreen(period: 'weekly'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildAnalyticsCard(
              context,
              'This Month\'s Spend',
              monthAsync,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AnalyticsDetailScreen(period: 'monthly'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    AsyncValue<double> asyncValue,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return asyncValue.when(
      data: (value) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(
                  '₹${value.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
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
