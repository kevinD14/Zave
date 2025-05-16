import 'dart:convert';
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/event_bus.dart';

class BackupService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveScope],
  );

  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    return account;
  }

  static Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Manejo del error
    }
  }

  static Future<drive.DriveApi?> getDriveApi() async {
    var account = _googleSignIn.currentUser;
    account ??=
        await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

    if (account == null) {
      return null;
    }
    final authHeaders = await account.authHeaders;
    return drive.DriveApi(GoogleAuthClient(authHeaders));
  }

  static Future<File> getLocalBackupFile({bool useTimestamp = false}) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '-',
    );
    final filename = useTimestamp
        ? 'transactions_backup_$timestamp.json'
        : 'transactions_backup.json';
    final path = join(dir.path, filename);
    final directory = Directory(dir.path);
    if (!await directory.exists()) await directory.create(recursive: true);
    return File(path);
  }

  static Future<File?> createBackupFile() async {
    final txs = await TransactionDB().getAllTransactions();
    if (txs.isEmpty) {
      return null;
    }

    final jsonStr = jsonEncode(
      txs
          .map(
            (t) => {
              'id': t['id'],
              'amount': t['amount'],
              'category': t['category'],
              'date': t['date'],
              'type': t['type'],
              'description': t['description'],
            },
          )
          .toList(),
    );

    final file = await getLocalBackupFile(useTimestamp: true);
    await file.writeAsString(jsonStr, flush: true);
    return file;
  }

  static Future<Map<String, dynamic>?> getLastBackupInfo() async {
    final api = await getDriveApi();
    if (api == null) return null;

    final folderId = await getOrCreateFolder('Backups');
    if (folderId == null) return null;

    final resp = await api.files.list(
      q: "'$folderId' in parents and name contains 'transactions_backup' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id, name, createdTime, size)',
      orderBy: 'createdTime desc',
      pageSize: 1,
    );

    if ((resp.files ?? []).isEmpty) return null;

    final file = resp.files!.first;
    return {
      'name': file.name,
      'createdTime': file.createdTime?.toLocal().toString(),
      'size': int.tryParse(file.size ?? '0') ?? 0,
    };
  }

  static Future<Map<String, dynamic>?> getStorageInfo() async {
    final api = await getDriveApi();

    if (api == null) return null;

    try {
      final response = await api.about.get($fields: 'storageQuota');

      final storageQuota = response.storageQuota;

      if (storageQuota != null) {
        final totalBytes = int.tryParse(storageQuota.limit ?? '0') ?? 0;
        final usedBytes = int.tryParse(storageQuota.usage ?? '0') ?? 0;

        return {'totalBytes': totalBytes, 'usedBytes': usedBytes};
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getOrCreateFolder(String folderName) async {
    final api = await getDriveApi();
    if (api == null) return null;
    final resp = await api.files.list(
      q: "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id,name)',
    );
    if ((resp.files ?? []).isNotEmpty) {
      return resp.files!.first.id;
    }
    final folderMetadata = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';
    final folder = await api.files.create(folderMetadata);
    return folder.id;
  }

  static Future<void> uploadBackupToDrive() async {
    final api = await getDriveApi();
    if (api == null) return;

    final folderId = await getOrCreateFolder('Backups');
    if (folderId == null) {
      return;
    }

    final file = await createBackupFile();
    if (file == null || !await file.exists()) {
      return;
    }

    final previousFiles = await api.files.list(
      q: "'$folderId' in parents and name contains 'transactions_backup' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id,name)',
    );

    for (final old in previousFiles.files ?? []) {
      try {
        await api.files.delete(old.id!);
      } catch (e) {
        // Manejo del error
      }
    }

    final bytes = await file.readAsBytes();
    final media = drive.Media(Stream.fromIterable([bytes]), bytes.length);

    final driveFile = drive.File()
      ..name = basename(file.path)
      ..parents = [folderId];

    try {
      await api.files.create(driveFile, uploadMedia: media);
    } catch (e) {
      // Manejo del error
    }
  }

  static Future<void> restoreBackupFromDrive() async {
    final api = await getDriveApi();
    if (api == null) return;

    final folderId = await getOrCreateFolder('Backups');
    if (folderId == null) {
      return;
    }

    final resp = await api.files.list(
      q: "'$folderId' in parents and name contains 'transactions_backup' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id,name), files(createdTime)',
      orderBy: 'createdTime desc',
      pageSize: 1,
    );

    if ((resp.files ?? []).isEmpty) {
      return;
    }

    final fileId = resp.files!.first.id!;

    try {
      final media =
          await api.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final bytes = <int>[];
      await for (var chunk in media.stream) {
        bytes.addAll(chunk);
      }

      final file = await getLocalBackupFile();
      await file.writeAsBytes(bytes, flush: true);

      await TransactionDB().deleteAllTransactions();
      final jsonStr = await file.readAsString();
      var listTx = jsonDecode(jsonStr) as List<dynamic>;

      listTx = listTx.reversed.toList();

      for (var t in listTx) {
        await TransactionDB().addTransaction(
          t['amount'],
          t['category'],
          t['date'],
          t['type'],
          t['description'],
        );
      }

      EventBus().notifyTransactionsUpdated();
    } catch (e) {
      // Manejo del error
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest req) {
    req.headers.addAll(_headers);
    return _client.send(req);
  }

  @override
  void close() => _client.close();
}
