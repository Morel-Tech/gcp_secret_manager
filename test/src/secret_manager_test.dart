// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:current_gcp_project/current_gcp_project.dart';
import 'package:gcp_secret_manager/gcp_secret_manager.dart';
import 'package:googleapis/secretmanager/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockSecretManagerApi extends Mock implements SecretManagerApi {}

class MockProjectsResource extends Mock implements ProjectsResource {}

class MockProjectsSecretsResource extends Mock
    implements ProjectsSecretsResource {}

class MockProjectsSecretsVersionsResource extends Mock
    implements ProjectsSecretsVersionsResource {}

class MockAccessSecretVersionResponse extends Mock
    implements AccessSecretVersionResponse {}

class MockSecretPayload extends Mock implements SecretPayload {}

class MockCurrentGcpProject extends Mock implements CurrentGcpProject {}

class MockAutoRefreshingAuthClient extends Mock
    implements AutoRefreshingAuthClient {}

void main() {
  group('SecretManager', () {
    test('can be instantiated', () {
      expect(SecretManager(MockSecretManagerApi(), ''), isNotNull);
    });

    group('getSecret', () {
      test('retrieves the latest secret', () async {
        final secretManagerApi = MockSecretManagerApi();
        final projects = MockProjectsResource();
        final secrets = MockProjectsSecretsResource();
        final versions = MockProjectsSecretsVersionsResource();
        final response = MockAccessSecretVersionResponse();
        final payload = MockSecretPayload();
        when(() => secretManagerApi.projects).thenReturn(projects);
        when(() => projects.secrets).thenReturn(secrets);
        when(() => secrets.versions).thenReturn(versions);
        when(
          () => versions.access(
            'projects/project-id/secrets/test/versions/latest',
          ),
        ).thenAnswer((_) async => response);
        when(() => response.payload).thenReturn(payload);
        when(() => payload.dataAsBytes).thenReturn(utf8.encode('test-secret'));

        final secretManager = SecretManager(secretManagerApi, 'project-id');
        expect(await secretManager.getSecret('test'), 'test-secret');
      });
      test('throws state error if payload is null', () async {
        final secretManagerApi = MockSecretManagerApi();
        final projects = MockProjectsResource();
        final secrets = MockProjectsSecretsResource();
        final versions = MockProjectsSecretsVersionsResource();
        final response = MockAccessSecretVersionResponse();
        when(() => secretManagerApi.projects).thenReturn(projects);
        when(() => projects.secrets).thenReturn(secrets);
        when(() => secrets.versions).thenReturn(versions);
        when(
          () => versions.access(
            'projects/project-id/secrets/test/versions/latest',
          ),
        ).thenAnswer((_) async => response);
        when(() => response.payload).thenReturn(null);

        final secretManager = SecretManager(secretManagerApi, 'project-id');
        await expectLater(
          () => secretManager.getSecret('test'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('defaultCredentials', () {
      test('returns a new secret manager', () async {
        final proj = MockCurrentGcpProject();
        when(proj.currentProjectId).thenAnswer((_) async => 'proj');
        expect(
          await SecretManager.defaultCredentials(
            currentGcpProject: proj,
            clientGetter: ({
              required List<String> scopes,
              Client? baseClient,
            }) async =>
                MockAutoRefreshingAuthClient(),
          ),
          isA<SecretManager>(),
        );
      });
    });
  });
}
