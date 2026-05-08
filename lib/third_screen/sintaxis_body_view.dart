import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/typescript.dart';
import 'package:flutter_highlight/themes/github.dart';

class BodyThirdScreen extends StatelessWidget {
  final String titulo;
  final String cardId;
  const BodyThirdScreen({super.key, required this.titulo, required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Hero (
      tag: cardId ,
      child: Scaffold(
        appBar: AppBar(title: Text(titulo)),
        body: FutureBuilder(
          future: buscarSintaxe(titulo, cardId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('Sem dados'));
            }

            final (titulo, sintaxe) = snapshot.data!;

            return Column(
              children: [
                // Espaçamento simples entre as caixas de input
                SizedBox(height: 20),

                //Widget do input da sintaxe
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),

                    //Usar esse ou o "Container()", os dois fazem a mesma coisa pra ESSE contexto
                    child: SizedBox(
                      height: 600,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(),
                        ),
                        child: codigoView(sintaxe),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget codigoView(String codigo) {

  final controller = CodeController(
    text: codigo,
    language: typescript,
  );

  return Expanded(
    child: CodeTheme(
      data: CodeThemeData(styles: githubTheme),
      child: CodeField(
        expands: true,
        maxLines: null,
        minLines: null,
        controller: controller,
        readOnly: true,
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
        ),
      ),
    ),
  );
}

final user = FirebaseAuth.instance.currentUser;
final uid = user!.uid;

Future<(String titulo, String sintaxe)> buscarSintaxe(String titulo, String cardId) async {
  final result = await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(uid)
      .collection('memorizacoes')
      .doc(cardId)
      .collection("subcards")
      .where("titulo", isEqualTo: titulo)
      .get();

  if (result.docs.isEmpty) {
    throw Exception('Documento não encontrado');
  }

  final data = result.docs.first.data();

  return (
  data['titulo'] as String,
  data['sintaxe'] as String
  );
}
