# FirebaseAuthService Implementation — TODO (google_sign_in 7.2.0)

## Implementation Steps

- [x] Update constructor: keep `required FirebaseAuth firebaseAuth`; use `GoogleSignIn.instance` (7.2.0 removed the public constructor)
- [x] Add `_ensureGoogleSignInInitialized()` one-time init guard (`GoogleSignIn.initialize()`)
- [x] Rewrite `signInWithGoogle()` for 7.2.0:
  - [x] Use `GoogleSignIn.authenticate()` (replacement for the removed `signIn()`)
  - [x] Extract `GoogleSignInAccount.authentication.idToken`
  - [x] Guard against null `idToken` before building the credential
  - [x] Build credential with `GoogleAuthProvider.credential(idToken: idToken)`
  - [x] Call injected `FirebaseAuth.signInWithCredential`
  - [x] Handle `GoogleSignInExceptionCode.canceled` → `SignInCancelledException`
  - [x] Handle `PlatformException(sign_in_canceled)` → `SignInCancelledException`
  - [x] Handle `PlatformException(CANCELLED)` → `SignInCancelledException`
  - [x] Rethrow all other exceptions
- [x] Keep `signInWithEmail()` / `registerWithEmail()` behavior (`signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, `updateDisplayName`, `reload`)
- [x] Rewrite `signOut()`:
  - [x] Ensure Google initialization first
  - [x] Attempt Google sign-out; capture first error if thrown
  - [x] Always attempt Firebase sign-out even if Google sign-out failed
  - [x] Rethrow first encountered exception after both attempts
- [x] Add comprehensive Dart doc comments explaining why each API is used
- [x] Run `flutter analyze` in `app/` to verify no warnings or errors
