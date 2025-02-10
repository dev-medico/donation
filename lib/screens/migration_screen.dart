import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/commands/migrate_realm_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

final migrationStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

class MigrationScreen extends ConsumerWidget {
  const MigrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final migrationState = ref.watch(migrationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Migration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Migration Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'This process will migrate your existing data from the local Realm database to the new backend server. '
                      'Please ensure you have a stable internet connection before proceeding.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Note: This process may take several minutes depending on the amount of data.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            migrationState.when(
              data: (_) => ElevatedButton(
                onPressed: () => _startMigration(ref),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'Start Migration',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              loading: () => const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Migration in progress...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              error: (error, _) => Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _startMigration(ref),
                    child: const Text('Retry Migration'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startMigration(WidgetRef ref) async {
    final notifier = ref.read(migrationStateProvider.notifier);
    notifier.state = const AsyncValue.loading();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final realmPath = path.join(appDir.path, 'default.realm');

      await MigrateRealmDataCommand.run(realmPath: realmPath);

      notifier.state = const AsyncValue.data(null);

      // Show success dialog
      if (ref.context.mounted) {
        showDialog(
          context: ref.context,
          builder: (context) => AlertDialog(
            title: const Text('Migration Complete'),
            content: const Text(
              'Your data has been successfully migrated to the new backend server.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error, stackTrace) {
      notifier.state = AsyncValue.error(error, stackTrace);
    }
  }
}
