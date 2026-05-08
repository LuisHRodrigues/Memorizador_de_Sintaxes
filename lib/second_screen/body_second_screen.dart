import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BodySecondScreen extends StatefulWidget {
  final String cardId;
  const BodySecondScreen({super.key, required this.cardId});

  @override
  State<BodySecondScreen> createState() => _BodyState();
}

class _BodyState extends State<BodySecondScreen> {
  final TextEditingController controllerSintaxe = TextEditingController();
  final TextEditingController controllerTitulo = TextEditingController();

  @override
  void dispose() {
    controllerSintaxe.dispose();
    controllerTitulo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar nova sintaxe")),
      body: Card(
        child: Column(
          children: [
            // Widget do Titulo
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Titulo",

                  //Aqui é como é o campo de input padrão, como deve aparecer para o usuário
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),

                  //Aqui é ativado quando o usuario clica na caixa de input
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                controller: controllerTitulo,
              ),
            ),

            // Espaçamento simples entre as caixas de input
            SizedBox(height: 20),

            //Widget do input da sintaxe
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: 10,
                horizontal: 20,
              ),

              //Usar esse ou o "Container()", os dois fazem a mesma coisa pra ESSE contexto
              child: SizedBox(
                //Esse carinha define o tamanho da caixa de texto da sintaxe
                height: 280,
                child: TextField(
                  maxLines: null,
                  //Permite o usuario rolar verticalmente  dentro do campo a medida de que o mesmo cresce veriticalmente
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: "Sintaxe ...",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  controller: controllerSintaxe,
                ),
              ),
            ),

            Spacer(), //Esse comando faz com que tudo que esteja dps dele vá para o rodapé

            ElevatedButton(
              //Botão para salvar no BD
              onPressed: () async {
                salvarNoBd(widget.cardId,controllerTitulo.text, controllerSintaxe.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
                foregroundColor: Colors.white,
                minimumSize: Size(200, 40),
              ),
              child: Text("Salvar Sintaxe"),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> salvarNoBd(
    String cardId,
    String titulo,
    String sintaxe,
    ) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(user.uid)
      .collection('memorizacoes')
      .doc(cardId)
      .collection('subcards')
      .add({
    'titulo': titulo,
    'sintaxe': sintaxe,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
