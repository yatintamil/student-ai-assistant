import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user?.email ?? 'User Account'),
              subtitle: Text('UID: ${user?.id ?? "N/A"}'),
            ),
          ),
          const SizedBox(height: 16),
          Text('AI Assistant Preferences', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.smart_toy_outlined),
                  title: Text('AI Model'),
                  subtitle: Text('Gemini 2.5 Flash (Default)'),
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_active_outlined),
                  title: Text('Intelligent Nudges'),
                  subtitle: Text('Habit reminders & replanning prompts'),
                  trailing: Switch(value: true, onChanged: null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Account & Privacy', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}
