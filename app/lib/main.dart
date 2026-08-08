import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    // ignore: deprecated_member_use
    await FirebaseAppCheck.instance.activate(
      // ignore: deprecated_member_use
      androidProvider: AndroidProvider.debug,
      // ignore: deprecated_member_use
      appleProvider: AppleProvider.debug,

      providerWeb: ReCaptchaV3Provider('6LcMe3gtAAAAAA47glEdk8n-gtE0c88lgSjkF4AT'),
    );
  } catch (e) {
    debugPrint('App Check initialization note: $e');
  }

  runApp(
    const ProviderScope(
      child: StudentAIAssistantApp(),
    ),
  );
}