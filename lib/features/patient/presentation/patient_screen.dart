import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PatientScreen extends ConsumerWidget {
  const PatientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carnet de santé'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Pull to refresh logic
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            Card(
              child: ListTile(
                title: Text('Jean Dupont, 34 ans'),
                subtitle: Text('Groupe sanguin: O+'),
              ),
            ),
            SizedBox(height: 20),
            Text('Historique des passages:'),
            // List of passages
          ],
        ),
      ),
    );
  }
}
