import 'package:realm/realm.dart';
import 'package:donation/utils/realm_migration_utility.dart';
import 'package:donation/realm/schemas.dart' as realm_schemas;

class MigrateRealmDataCommand {
  final String realmPath;
  late final Configuration _config;
  late final Realm _realm;

  MigrateRealmDataCommand({required this.realmPath}) {
    _config = Configuration.local(
      [
        realm_schemas.Member.schema,
        realm_schemas.Donation.schema,
        realm_schemas.SpecialEvent.schema,
        realm_schemas.DonarRecord.schema,
        realm_schemas.ExpensesRecord.schema,
        realm_schemas.RequestGive.schema,
        realm_schemas.Noti.schema,
        realm_schemas.Post.schema,
        realm_schemas.Reaction.schema,
        realm_schemas.Comment.schema,
      ],
      path: realmPath,
    );
    _realm = Realm(_config);
  }

  Future<MigrationResult> execute() async {
    final utility = RealmMigrationUtility(realm: _realm);

    try {
      // Migrate members first
      final memberResults = await utility.migrateMembersToBackend();
      if (memberResults.hasErrors) {
        print('Warning: Some members failed to migrate:');
        print(memberResults.toString());
      }

      // Validate the migration
      try {
        await utility.validateMigration();
        print('Migration validation successful!');
      } catch (e) {
        print('Warning: Migration validation failed: $e');
      }

      return memberResults;
    } finally {
      _realm.close();
    }
  }

  static Future<void> run({required String realmPath}) async {
    final command = MigrateRealmDataCommand(realmPath: realmPath);
    try {
      final results = await command.execute();
      print('\nMigration completed!');
      print(results.toString());
    } catch (e) {
      print('Error during migration: $e');
      rethrow;
    }
  }
}
