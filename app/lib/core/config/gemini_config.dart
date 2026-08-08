import 'package:google_generative_ai/google_generative_ai.dart';

/// Central configuration for Gemini API access.
abstract final class GeminiConfig {
  /// API key supplied at build time via `--dart-define=GEMINI_API_KEY=...`.
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Whether a non-empty API key was provided at build time.
  static bool get isConfigured => apiKey.isNotEmpty;

  /// Default model used across planner and chat services.
  static const String defaultModel = 'gemini-2.0-flash-exp';

  /// Creates a GenerativeModel instance with the configured API key.
  /// Throws [StateError] if API key is not configured.
  static GenerativeModel createModel() {
    if (!isConfigured) {
      throw StateError(
        'Gemini API key not configured. '
        'Build with --dart-define=GEMINI_API_KEY=your_key',
      );
    }
    return GenerativeModel(
      model: defaultModel,
      apiKey: apiKey,
    );
  }
}
