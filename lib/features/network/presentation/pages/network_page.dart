import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NetworkPage extends StatelessWidget {
  const NetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search people',
            onPressed: () => context.push('/network/search'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Your feed will appear here'),
      ),
    );
  }
}
