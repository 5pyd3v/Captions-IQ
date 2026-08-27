import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/history_item.dart';
import '../../state/history_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/summary_result_view.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final HistoryItem item;
  const HistoryDetailScreen({super.key, required this.item});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this summary?'),
        content: const Text('This will permanently remove it from your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(historyProvider.notifier).delete(item.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        AppSnackbar.show(context, 'Summary deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SummaryResultView(item: item),
    );
  }
}
