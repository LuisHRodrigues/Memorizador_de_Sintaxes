import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/typescript.dart';
import 'package:flutter_highlight/themes/github.dart';

class SyntaxViewerScreen extends StatefulWidget {
  final String titulo;
  final String cardId;
  const SyntaxViewerScreen({super.key, required this.titulo, required this.cardId});

  @override
  State<SyntaxViewerScreen> createState() => _SyntaxViewerScreenState();
}

class _SyntaxViewerScreenState extends State<SyntaxViewerScreen> {
  CodeController? _codeController;
  late final Future<(String titulo, String sintaxe)> _sintaxeFuture;

  @override
  void initState() {
    super.initState();
    _sintaxeFuture = buscarSintaxe(widget.titulo, widget.cardId);
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.cardId,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.titulo)),
        body: FutureBuilder(
          future: _sintaxeFuture,
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

            final (_, sintaxe) = snapshot.data!;
            final codeController =
                _codeController ??= CodeController(text: sintaxe, language: typescript);
            // O pacote marca searchController como @internal, mas não expõe
            // outra forma pública de destacar todas as ocorrências e navegar
            // entre elas — é o mesmo motor usado pela busca embutida do pacote.
            // ignore: invalid_use_of_internal_member
            final buscaController = codeController.searchController;

            return Column(
              children: [
                const SizedBox(height: 12),

                // Caixa de pesquisa fixa, entre o título da tela e a caixa da sintaxe
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ValueListenableBuilder(
                    valueListenable: buscaController.navigationController,
                    builder: (context, navState, _) {
                      final patternController =
                          buscaController.settingsController.patternController;

                      return TextField(
                        controller: patternController,
                        focusNode: buscaController.patternFocusNode,
                        onTap: codeController.showSearch,
                        onChanged: (_) => codeController.showSearch(),
                        decoration: InputDecoration(
                          hintText: "Pesquisar na sintaxe ...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: patternController.text.isEmpty
                              ? null
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(navState.currentMatchIndex ?? -1) + 1}/${navState.totalMatchCount}',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.keyboard_arrow_up),
                                      onPressed: navState.totalMatchCount == 0
                                          ? null
                                          : buscaController.navigationController.movePrevious,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.keyboard_arrow_down),
                                      onPressed: navState.totalMatchCount == 0
                                          ? null
                                          : buscaController.navigationController.moveNext,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: patternController.clear,
                                    ),
                                  ],
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                //Widget do input da sintaxe
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),

                    child: InputDecorator(
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(),
                      ),
                      child: codigoView(codeController),
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

Widget codigoView(CodeController controller) {
  return CodeTheme(
    data: CodeThemeData(styles: githubTheme),
    child: CodeField(
      expands: true,
      maxLines: null,
      minLines: null,
      controller: controller,
      readOnly: true,
      textStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
      ),
    ),
  );
}

Future<(String titulo, String sintaxe)> buscarSintaxe(String titulo, String cardId) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('Usuário não autenticado');
  }

  final result = await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(user.uid)
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
