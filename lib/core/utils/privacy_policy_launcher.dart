import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const privacyPolicyUrl = 'https://thomasmshkv.github.io/vaytoday-privacy/';
const _privacyPolicyOpenError =
    '\u041d\u0435 \u0443\u0434\u0430\u043b\u043e\u0441\u044c \u043e\u0442\u043a\u0440\u044b\u0442\u044c \u043f\u043e\u043b\u0438\u0442\u0438\u043a\u0443 \u043a\u043e\u043d\u0444\u0438\u0434\u0435\u043d\u0446\u0438\u0430\u043b\u044c\u043d\u043e\u0441\u0442\u0438';

Future<void> openPrivacyPolicy(BuildContext context) async {
  final uri = Uri.parse(privacyPolicyUrl);
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (opened || !context.mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text(_privacyPolicyOpenError)));
}
