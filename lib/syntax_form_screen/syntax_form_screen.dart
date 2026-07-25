import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class SyntaxFormScreen extends StatefulWidget {
  final String cardId;
  final String? subcardId;
  final String? initialTitulo;
  final String? initialSintaxe;

  const SyntaxFormScreen({
    super.key,
    required this.cardId,
    this.subcardId,
    this.initialTitulo,
    this.initialSintaxe,
  });

  bool get isEditing => subcardId != null;

  @override
  State<SyntaxFormScreen> createState() => _SyntaxFormScreenState();
}

class _SyntaxFormScreenState extends State<SyntaxFormScreen> {
  final TextEditingController controllerSintaxe = TextEditingController();
  final TextEditingController controllerTitulo = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controllerTitulo.text = widget.initialTitulo ?? '';
    controllerSintaxe.text = widget.initialSintaxe ?? '';
  }

  @override
  void dispose() {
    controllerSintaxe.dispose();
    controllerTitulo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Editar sintaxe" : "Adicionar nova sintaxe"),
      ),
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
                vertical: 0,
                horizontal: 20,
              ),

              //Usar esse ou o "Container()", os dois fazem a mesma coisa pra ESSE contexto
                child: LayoutBuilder(

                  builder: (context, constraints) {

                    final bool mobile =
                        constraints.maxWidth < 700;

                    //Logica para a tecla TAB funncionar dentro do campo de input no desktop
                    return Focus(
                      onKeyEvent: (node, event) {

                        if (event is KeyDownEvent &&
                        event.logicalKey ==
                        LogicalKeyboardKey.tab) {

                          final text =
                              controllerSintaxe.text;

                          final selection =
                              controllerSintaxe.selection;

                          //Aqui define quantos espaços vão ser inseridos ao clicar a tecla TAB
                          const tabSpaces = '    ';

                          final newText =
                          text.replaceRange(
                            selection.start,
                            selection.end,
                            tabSpaces,
                          );

                          controllerSintaxe.text =
                              newText;

                          controllerSintaxe.selection =
                              TextSelection.collapsed(
                                offset:
                                selection.start +
                                    tabSpaces.length,
                              );

                          return KeyEventResult.handled;
                        }

                        return KeyEventResult.ignored;
                      },

                      //Esse "child" está DENTRO do widget Focus
                      child: SizedBox(

                        height: mobile ? 280 : 600,

                        child: TextField(

                          controller:
                          controllerSintaxe,

                          focusNode: focusNode,

                          expands: true,

                          maxLines: null,

                          keyboardType:
                          TextInputType.multiline,

                          textAlignVertical:
                          TextAlignVertical.top,

                          decoration: InputDecoration(

                            hintText: "Sintaxe ...",

                            contentPadding:
                            EdgeInsets.only(
                              top: 12,
                              left: 12,
                              right: 12,
                            ),

                            border:
                            OutlineInputBorder(),
                          ),
                        ),
                      ),
                    );
                  },
                )
            ),

            Spacer(), //Esse comando faz com que tudo que esteja dps dele vá para o rodapé

            ElevatedButton(
              //Botão para salvar no BD
              onPressed: () async {
                if (widget.isEditing) {
                  await atualizarNoBd(
                    widget.cardId,
                    widget.subcardId!,
                    controllerTitulo.text,
                    controllerSintaxe.text,
                  );
                } else {
                  await salvarNoBd(widget.cardId, controllerTitulo.text, controllerSintaxe.text);
                }
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
                foregroundColor: Colors.white,
                minimumSize: Size(200, 40),
              ),
              child: Text(widget.isEditing ? "Salvar Alterações" : "Salvar Sintaxe"),
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

Future<void> atualizarNoBd(
    String cardId,
    String subcardId,
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
      .doc(subcardId)
      .update({
    'titulo': titulo,
    'sintaxe': sintaxe,
  });
}
