// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly'],
);

Future<void> signInWithGoogle() async {
  try {
    // O usuário escolhe a conta do Google
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtem os detalhes (tokens) dessa conta escolhida
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth != null) {
      //Criar uma credencial que o Firebase entende
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Enviar a credencial para o Firebase e ele cria o usuário no console.
      await FirebaseAuth.instance.signInWithCredential(credential);

      print("Agora o usuário está logado no Firebase");
    }
  } catch (e) {
    print("Erro no processo de login: $e");
  }
}

Future<void> singOut() async {
  await _googleSignIn.disconnect();
}
