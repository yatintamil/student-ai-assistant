# TODO

## AuthState Implementation

- [x] Create `lib/features/authentication/presentation/states/auth_state.dart`
  - [x] Immutable `AuthState` class with `user`, `isLoading`, `errorMessage` fields
  - [x] Const primary constructor
  - [x] `copyWith()` (simple, no sentinel)
  - [x] Const factory constructors: `initial`, `authenticated`, `loading`, `unauthenticated`, `failure`
  - [x] Manual `==` and `hashCode` overrides (no Equatable)
  - [x] Dart documentation comments and Effective Dart style
- [x] Run `flutter analyze` and confirm zero issues
- [x] Explain why each factory constructor exists
- [x] Explain why immutable state is preferred over multiple booleans
