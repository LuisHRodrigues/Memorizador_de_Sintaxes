import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sintaxismemorizer/login_screen/login_screen.dart';
import '../ideiasRandom/CardsDeCategorias.dart';

class Authgate extends StatelessWidget {
  const Authgate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // Estado de carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        //Usuário logado
        if (snapshot.hasData) {
          return const CardsDeCategorias();
        }

        //Usuário não logado
        return const Login();
      },
    );
  }
}