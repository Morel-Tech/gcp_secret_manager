import 'dart:io';

import 'package:gcp_secret_manager/gcp_secret_manager.dart';

/// {@template local_secret_manager}
/// A [SecretManager] that can be used to read secrets from a fake source
/// (like a local file) instead of the actual Secret Manager, which makes them
/// much easier to use locally.
/// {@endtemplate}
class LocalSecretManager implements SecretManager {
  /// {@macro local_secret_manager}
  const LocalSecretManager(this._secrets);

  /// Creates a new [LocalSecretManager] from a specified file.
  /// The file should have one secret per line, and the name of the secret and
  /// its value should be separated by the equals sign `=`.
  ///
  /// You can define comments using `//`
  ///
  /// For example
  /// ```text
  /// name=testing
  ///
  /// // This secret is really juicy
  /// second-secret=you'll never guess
  /// ```
  ///
  /// For obvious reasons, this secrets file should NEVER be checked into source
  /// control like GitHub.
  static Future<LocalSecretManager> fromFile([
    String filePath = 'secrets.txt',
  ]) async {
    final lines = await File(filePath).readAsLines();

    final filteredLines =
        lines.where((e) => !e.startsWith('//') && e.isNotEmpty);

    final secretsMap = Map<String, String>.fromEntries(
      filteredLines.map((line) {
        final parts = line.split('=');
        return MapEntry(parts[0], parts[1]);
      }),
    );

    return LocalSecretManager(secretsMap);
  }

  final Map<String, String> _secrets;

  @override
  Future<String> getSecret(String name, {String version = 'latest'}) async {
    final secret = _secrets[name];
    if (secret == null) {
      throw StateError('Secret not found');
    }
    return secret;
  }
}
