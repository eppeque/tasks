import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> handleSignIn([String accessToken, String idToken]) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: accessToken ?? googleAuth.accessToken,
      idToken: idToken ?? googleAuth.idToken,
    );

    if (accessToken == null && idToken == null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', googleAuth.accessToken);
      prefs.setString('idToken', googleAuth.idToken);
    }

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  void signOut() {
    _googleSignIn.signOut();
  }
}

final auth = Auth();