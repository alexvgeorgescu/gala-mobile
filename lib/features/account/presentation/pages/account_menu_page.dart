import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_cubit.dart';

class AccountMenuPage extends StatelessWidget {
  const AccountMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/account/profile'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('My Events'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/account/events'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
    );
  }
}
