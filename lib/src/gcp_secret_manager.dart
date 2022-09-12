import 'dart:convert';

import 'package:current_gcp_project/current_gcp_project.dart';
import 'package:googleapis/secretmanager/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

/// {@template secret_manager}
/// A wrapper around the [SecretManagerApi] that is easier to use.
/// {@endtemplate}
class SecretManager {
  /// {@macro secret_manager}
  const SecretManager(this._secretManagerApi, this._projectId);

  /// Creates a new [SecretManager] with
  /// [clientViaApplicationDefaultCredentials]
  static Future<SecretManager> defaultCredentials({
    CurrentGcpProject currentGcpProject = const CurrentGcpProject(),
    Future<AutoRefreshingAuthClient> Function({
      required List<String> scopes,
      Client? baseClient,
    })
        clientGetter = clientViaApplicationDefaultCredentials,
  }) async {
    final client = await clientGetter(
      scopes: [
        SecretManagerApi.cloudPlatformScope,
      ],
    );
    final api = SecretManagerApi(client);
    final currentProjectId = await currentGcpProject.currentProjectId();
    return SecretManager(api, currentProjectId!);
  }

  final SecretManagerApi _secretManagerApi;
  final String _projectId;

  /// Retrieves the latest version of a secret by secret name.
  Future<String> getSecret(String name, {String version = 'latest'}) async {
    final secretsResponse =
        await _secretManagerApi.projects.secrets.versions.access(
      'projects/$_projectId/secrets/$name/versions/$version',
    );

    final rawPayload = secretsResponse.payload?.dataAsBytes;

    if (rawPayload == null) {
      throw StateError('Secret not found');
    }

    return utf8.decode(rawPayload);
  }
}
