// ignore_for_file: unused_local_variable

import 'package:gcp_secret_manager/gcp_secret_manager.dart';

void main() async {
  final secretManager = await SecretManager.defaultCredentials();
  final secret = await secretManager.getSecret('my-secret');
  // use secret...
}
