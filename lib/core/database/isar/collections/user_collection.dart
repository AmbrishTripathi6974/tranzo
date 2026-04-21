import 'package:isar_community/isar.dart';

part 'user_collection.g.dart';

/// Cached identity for the signed-in user (Supabase / remote id).
@Collection()
class UserCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String supabaseUserId;

  String? email;
  String? displayName;
  String? shortCode;
  String? avatarUrl;

  DateTime updatedAt = DateTime.now();
}
