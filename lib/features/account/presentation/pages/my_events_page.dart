import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gala_mobile/core/network/dio_error_message.dart';
import 'package:gala_mobile/features/account/data/models/event.dart';
import 'package:gala_mobile/features/account/presentation/cubit/events_cubit.dart';
import 'package:gala_mobile/features/account/presentation/cubit/events_state.dart';

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(context),
          ),
        ],
      ),
      body: BlocBuilder<EventsCubit, EventsState>(
        builder: (context, state) {
          return switch (state) {
            EventsLoading() =>
              const Center(child: CircularProgressIndicator()),
            EventsError(:final message) => _ErrorView(message: message),
            EventsLoaded(:final events) => events.isEmpty
                ? _EmptyView(onAdd: () => _openForm(context))
                : _EventList(events: events),
          };
        },
      ),
    );
  }

  void _openForm(BuildContext context) {
    context.push(
      '/account/events/new',
      extra: context.read<EventsCubit>(),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<Event> events;

  const _EventList({required this.events});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EventsCubit>();
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: events.length,
        separatorBuilder: (_, _) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final event = events[index];
          return _EventTile(event: event);
        },
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Event event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        MaterialLocalizations.of(context).formatMediumDate(event.date);
    final recurrenceLabel = event.recurrence?.name;

    return ListTile(
      title: Text(event.name),
      subtitle: Row(
        children: [
          Text(dateLabel),
          if (recurrenceLabel != null) ...[
            const SizedBox(width: 8),
            Chip(
              label: Text(recurrenceLabel),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, event),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Event event) async {
    final cubit = context.read<EventsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('"${event.name}" will be removed.'),
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
      await cubit.delete(event.id);
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
            const Text('No events yet'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add event'),
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
              onPressed: () => context.read<EventsCubit>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
