import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'empty_state.dart';

/// Handles loading / error / data for an AsyncValue.
class AsyncView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  const AsyncView({super.key, required this.value, required this.data, this.onRetry});
  @override
  Widget build(BuildContext context) => value.when(
        data: data,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Something went wrong',
          message: '$e',
          action: onRetry == null ? null : OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      );
}
