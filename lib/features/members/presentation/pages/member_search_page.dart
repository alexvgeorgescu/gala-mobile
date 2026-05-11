import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gala_mobile/features/members/data/models/member.dart';
import 'package:gala_mobile/features/members/presentation/cubit/member_search_cubit.dart';
import 'package:gala_mobile/features/members/presentation/cubit/member_search_state.dart';

class MemberSearchPage extends StatefulWidget {
  const MemberSearchPage({super.key});

  @override
  State<MemberSearchPage> createState() => _MemberSearchPageState();
}

class _MemberSearchPageState extends State<MemberSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MemberSearchCubit>();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search people',
            border: InputBorder.none,
          ),
          onChanged: cubit.onQueryChanged,
        ),
        actions: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  cubit.onQueryChanged('');
                  _focusNode.requestFocus();
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MemberSearchCubit, MemberSearchState>(
        builder: (context, state) {
          return switch (state) {
            MemberSearchIdle() => const _IdleView(),
            MemberSearchLoading() =>
              const Center(child: CircularProgressIndicator()),
            MemberSearchLoaded(:final query, :final members) => members.isEmpty
                ? _EmptyView(query: query)
                : _ResultList(members: members),
            MemberSearchError(:final message) => _ErrorView(message: message),
          };
        },
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            const Text(
              'Search for people by name or email',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String query;

  const _EmptyView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No members match "$query"',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  final List<Member> members;

  const _ResultList({required this.members});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (_, _) => const Divider(height: 0),
      itemBuilder: (context, index) => _MemberTile(member: members[index]),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Member member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = member.avatarURL != null && member.avatarURL!.isNotEmpty;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: hasAvatar ? NetworkImage(member.avatarURL!) : null,
        child: hasAvatar ? null : Text(member.initials),
      ),
      title: Text(member.displayName),
      subtitle: (member.email != null && member.email!.isNotEmpty)
          ? Text(member.email!)
          : null,
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
              onPressed: () => context.read<MemberSearchCubit>().retry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
