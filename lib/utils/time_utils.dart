import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart'; // For FilterParams

String formatDateRange(FilterParams params, String period) {
  final dateFormatter = DateFormat('MMM d, yyyy');

  if (period == 'daily') {
    return dateFormatter.format(params.start);
  } else if (period == 'weekly') {
    final startStr = dateFormatter.format(params.start);
    final endStr = dateFormatter.format(params.end.subtract(const Duration(days: 1)));
    return '$startStr – $endStr';
  } else if (period == 'monthly') {
    final monthFormatter = DateFormat('MMMM yyyy');
    return monthFormatter.format(params.start);
  } else {
    // fallback
    final startStr = dateFormatter.format(params.start);
    final endStr = dateFormatter.format(params.end);
    return '$startStr – $endStr';
  }
}
