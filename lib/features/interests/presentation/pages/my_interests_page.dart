import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gala_mobile/core/network/dio_error_message.dart';
import 'package:gala_mobile/features/interests/data/models/interest.dart';
import 'package:gala_mobile/features/interests/presentation/cubit/interests_cubit.dart';
import 'package:gala_mobile/features/interests/presentation/cubit/interests_state.dart';

class MyInterestsPage extends StatelessWidget {
  const MyInterestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Interests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(context),
          ),
        ],
      ),
      body: BlocBuilder<InterestsCubit, InterestsState>(
        builder: (context, state) {
          return switch (state) {
            InterestsLoading() =>
              const Center(child: CircularProgressIndicator()),
            InterestsError(:final message) => _ErrorView(message: message),
            InterestsLoaded(:final interests) => interests.isEmpty
                ? _EmptyView(onAdd: () => _openForm(context))
                : _InterestList(interests: interests),
          };
        },
      ),
    );
  }

  void _openForm(BuildContext context) {
    context.push(
      '/interests/new',
      extra: context.read<InterestsCubit>(),
    );
  }
}

class _InterestList extends StatelessWidget {
  final List<Interest> interests;

  const _InterestList({required this.interests});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InterestsCubit>();
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: interests.length,
        separatorBuilder: (_, _) => const Divider(height: 0),
        itemBuilder: (context, index) {
          return _InterestTile(interest: interests[index]);
        },
      ),
    );
  }
}

class _InterestTile extends StatelessWidget {
  final Interest interest;

  const _InterestTile({required this.interest});

  @override
  Widget build(BuildContext context) {
    final typeLabel = interest.type?.name;
    return ListTile(
      title: Text(interest.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (interest.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 4),
              child: Text(interest.description),
            ),
          if (typeLabel != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(typeLabel),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
      isThreeLine: interest.description.isNotEmpty,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, interest),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Interest interest) async {
    final cubit = context.read<InterestsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete interest?'),
        content: Text('"${interest.name}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await cubit.delete(interest.id);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyDioError(e))));
    }
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No interests yet'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add interest'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $message', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<InterestsCubit>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
