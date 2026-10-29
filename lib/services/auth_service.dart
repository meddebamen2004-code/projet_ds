/// Simulated authentication.
/// Next step: replace the body of signIn() with
/// FirebaseAuth.instance.signInWithEmailAndPassword(...).
/// The provider and the views will not change.
class AuthService {
  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return password == '123456'; // test password
  }
}