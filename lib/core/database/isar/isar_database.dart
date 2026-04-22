import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'collections/file_collection.dart';
import 'collections/queued_transfer_collection.dart';
import 'collections/sender_trust_collection.dart';
import 'collections/transfer_collection.dart';
import 'collections/transfer_progress_collection.dart';
import 'collections/user_collection.dart';

const String _isarName = 'tranzo';

/// Opens the app Isar instance with all transfer-related collections.
Future<Isar> openTranzoIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    <CollectionSchema<dynamic>>[
      UserCollectionSchema,
      TransferCollectionSchema,
      FileCollectionSchema,
      TransferProgressCollectionSchema,
      QueuedTransferCollectionSchema,
      SenderTrustCollectionSchema,
    ],
    directory: dir.path,
    name: _isarName,
  );
}
